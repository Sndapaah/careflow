import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../domain/usecases/facility_usecases.dart';

enum MapViewMode { overview, facility }

// ----------------------------------------------------------------- events

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class MapStarted extends MapEvent {
  const MapStarted({this.focusFacilityId});

  /// Opens straight onto a facility when arriving from a recommendation.
  final String? focusFacilityId;

  @override
  List<Object?> get props => <Object?>[focusFacilityId];
}

final class MapFacilitySelected extends MapEvent {
  const MapFacilitySelected(this.facilityId);

  final String facilityId;

  @override
  List<Object?> get props => <Object?>[facilityId];
}

final class MapOverviewRequested extends MapEvent {
  const MapOverviewRequested();
}

final class MapUserPositionUpdated extends MapEvent {
  const MapUserPositionUpdated(this.position);

  final LatLng position;

  @override
  List<Object?> get props => <Object?>[position];
}

final class MapRouteResolved extends MapEvent {
  const MapRouteResolved({
    required this.distanceLabel,
    required this.durationLabel,
  });

  final String distanceLabel;
  final String durationLabel;

  @override
  List<Object?> get props => <Object?>[distanceLabel, durationLabel];
}

// ------------------------------------------------------------------ state

class MapState extends Equatable {
  const MapState({
    this.status = BlocStatus.initial,
    this.recommendations = const <FacilityRecommendation>[],
    this.mode = MapViewMode.overview,
    this.selectedId,
    this.errorMessage,
    this.userPosition = const LatLng(6.6885, -1.6244), // KNUST default
    this.sheetVisible = false,
    this.routeDistanceLabel,
    this.routeDurationLabel,
    this.routeRequestId = 0,
  });

  final BlocStatus status;
  final List<FacilityRecommendation> recommendations;
  final MapViewMode mode;
  final String? selectedId;
  final String? errorMessage;
  final LatLng userPosition;
  final bool sheetVisible;
  final String? routeDistanceLabel;
  final String? routeDurationLabel;
  final int routeRequestId;

  /// The highest-ranked recommendation — the card at the top of the sheet.
  FacilityRecommendation? get topMatch =>
      recommendations.isEmpty ? null : recommendations.first;

  FacilityRecommendation? get selected {
    if (selectedId == null) return topMatch;
    for (final FacilityRecommendation r in recommendations) {
      if (r.facility.id == selectedId) return r;
    }
    return topMatch;
  }

  /// The facility whose pin is called out on the map.
  Facility? get pinnedFacility => selected?.facility;

  MapState copyWith({
    BlocStatus? status,
    List<FacilityRecommendation>? recommendations,
    MapViewMode? mode,
    String? selectedId,
    String? errorMessage,
    LatLng? userPosition,
    bool? sheetVisible,
    String? routeDistanceLabel,
    String? routeDurationLabel,
    int? routeRequestId,
    bool clearSelection = false,
    bool clearError = false,
    bool clearRoute = false,
  }) => MapState(
    status: status ?? this.status,
    recommendations: recommendations ?? this.recommendations,
    mode: mode ?? this.mode,
    selectedId: clearSelection ? null : selectedId ?? this.selectedId,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    userPosition: userPosition ?? this.userPosition,
    sheetVisible: sheetVisible ?? this.sheetVisible,
    routeDistanceLabel: clearRoute
        ? null
        : routeDistanceLabel ?? this.routeDistanceLabel,
    routeDurationLabel: clearRoute
        ? null
        : routeDurationLabel ?? this.routeDurationLabel,
    routeRequestId: routeRequestId ?? this.routeRequestId,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    recommendations,
    mode,
    selectedId,
    errorMessage,
    userPosition,
    sheetVisible,
    routeDistanceLabel,
    routeDurationLabel,
    routeRequestId,
  ];
}

// ------------------------------------------------------------------- bloc

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required GetRecommendations getRecommendations})
    : _getRecommendations = getRecommendations,
      super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MapFacilitySelected>(_onFacilitySelected);
    on<MapOverviewRequested>(_onOverviewRequested);
    on<MapUserPositionUpdated>(_onUserPositionUpdated);
    on<MapRouteResolved>(_onRouteResolved);
  }

  final GetRecommendations _getRecommendations;
  StreamSubscription<Position>? _positionSub;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));

    // 1. Immediately clean up past streams to prevent background leaks
    await _positionSub?.cancel();
    _positionSub = null;

    // Location tracking can initialize alongside the recommendations request.
    unawaited(_establishLocationPipeline());

    try {
      final List<FacilityRecommendation> results = await _getRecommendations(
        const NoParams(),
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          status: BlocStatus.success,
          recommendations: results,
          selectedId: event.focusFacilityId,
          mode: event.focusFacilityId == null
              ? MapViewMode.overview
              : MapViewMode.facility,
          sheetVisible: true,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  /// Handles permissions, fetches the instant location fix, and attaches the listener safely.
  Future<void> _establishLocationPipeline() async {
    try {
      // Guard: Check if physical system settings are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled || isClosed) return;

      // Guard: Validate and request platform-level runtime permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          isClosed) {
        return;
      }

      // Grab the rapid, single-frame position fix immediately
      final Position initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      if (!isClosed) {
        add(
          MapUserPositionUpdated(
            LatLng(initialPosition.latitude, initialPosition.longitude),
          ),
        );
      }

      // Safeguard against overlapping double-initialization triggers during async gaps
      if (_positionSub != null || isClosed) return;

      // Track shifting locations continuously across long periods
      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 25,
            ),
          ).listen(
            (Position position) {
              if (!isClosed) {
                add(
                  MapUserPositionUpdated(
                    LatLng(position.latitude, position.longitude),
                  ),
                );
              }
            },
            onError: (_) {
              // Graceful background tracking capture fallback
            },
          );
    } catch (_) {
      // Handle exceptions or time-outs safely without disrupting the UI
    }
  }

  void _onFacilitySelected(MapFacilitySelected event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        selectedId: event.facilityId,
        mode: MapViewMode.facility,
        sheetVisible: true,
        clearRoute: true,
        routeRequestId: state.routeRequestId + 1,
      ),
    );
  }

  void _onOverviewRequested(
    MapOverviewRequested event,
    Emitter<MapState> emit,
  ) {
    emit(
      state.copyWith(
        mode: MapViewMode.overview,
        clearSelection: true,
        sheetVisible: true,
        clearRoute: true,
      ),
    );
  }

  void _onUserPositionUpdated(
    MapUserPositionUpdated event,
    Emitter<MapState> emit,
  ) {
    final bool hasSelectedFacility = state.selectedId != null;
    emit(
      state.copyWith(
        userPosition: event.position,
        // Retry a pending route once a real location replaces the fallback.
        routeRequestId: hasSelectedFacility
            ? state.routeRequestId + 1
            : state.routeRequestId,
      ),
    );
  }

  void _onRouteResolved(MapRouteResolved event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        routeDistanceLabel: event.distanceLabel,
        routeDurationLabel: event.durationLabel,
      ),
    );
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
