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

/// The map sheet has two shapes: the ranked overview, and a single facility
/// with its live telemetry and call/navigate actions.
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
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    recommendations,
    mode,
    selectedId,
    errorMessage,
    sheetVisible,
    routeDistanceLabel,
    routeDurationLabel,
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

  void _onRouteResolved(MapRouteResolved event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        routeDistanceLabel: event.distanceLabel,
        routeDurationLabel: event.durationLabel,
      ),
    );
  }

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));

    // FIXED: Call the method asynchronously without 'await' and without nested logic
    // to instantly prevent main thread lockups on app startup.
    _initLocationTracking();

    try {
      final List<FacilityRecommendation> results = await _getRecommendations(
        const NoParams(),
      );
      emit(
        state.copyWith(
          status: BlocStatus.success,
          recommendations: results,
          selectedId: event.focusFacilityId,
          mode: event.focusFacilityId == null
              ? MapViewMode.overview
              : MapViewMode.facility,
          sheetVisible: event.focusFacilityId != null,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _initLocationTracking() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // FIXED: Using LocationSettings inside getCurrentPosition to clear the deprecation warning
      final Position currentPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
        timeLimit: const Duration(seconds: 5),
      );

      add(
        MapUserPositionUpdated(
          LatLng(currentPos.latitude, currentPos.longitude),
        ),
      );

      await _positionSub?.cancel();

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position position) {
            add(
              MapUserPositionUpdated(
                LatLng(position.latitude, position.longitude),
              ),
            );
          });
    } catch (_) {
      // Graceful isolation fallback container
    }
  }

  void _onFacilitySelected(MapFacilitySelected event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        selectedId: event.facilityId,
        mode: MapViewMode.facility,
        sheetVisible: true,
        clearRoute: true,
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
        sheetVisible: false,
        clearRoute: true,
      ),
    );
  }

  void _onUserPositionUpdated(
    MapUserPositionUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(userPosition: event.position));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
