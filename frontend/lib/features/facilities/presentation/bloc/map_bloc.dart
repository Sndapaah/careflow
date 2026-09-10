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
import '../../../../core/network/api_config.dart';
import '../../../../core/network/token_storage.dart';

enum MapViewMode { overview, facility }

class ActiveRoute extends Equatable {
  const ActiveRoute({required this.distance, required this.duration});
  final String distance;
  final String duration;
  @override
  List<Object?> get props => <Object?>[distance, duration];
}

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

final class MapRouteViewRequested extends MapEvent {
  const MapRouteViewRequested();
}

// ------------------------------------------------------------------ state

class MapState extends Equatable {
  const MapState({
    this.status = BlocStatus.initial,
    this.recommendations = const <FacilityRecommendation>[],
    this.mode = MapViewMode.overview,
    this.selectedId,
    this.errorMessage,
    // No geographic fallback: the map must represent the device position.
    this.userPosition = const LatLng(0, 0),
    this.sheetVisible = false,
    this.activeRoute,
    this.routeViewRequested = false,
    this.routeRequestId = 0,
  });

  final BlocStatus status;
  final List<FacilityRecommendation> recommendations;
  final MapViewMode mode;
  final String? selectedId;
  final String? errorMessage;
  final LatLng userPosition;
  final bool sheetVisible;
  final ActiveRoute? activeRoute;
  final bool routeViewRequested;
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
    ActiveRoute? activeRoute,
    int? routeRequestId,
    bool? routeViewRequested,
    bool clearSelection = false,
    bool clearError = false,
    bool clearRoute = false,
    bool clearRouteViewRequested = false,
  }) => MapState(
    status: status ?? this.status,
    recommendations: recommendations ?? this.recommendations,
    mode: mode ?? this.mode,
    selectedId: clearSelection ? null : selectedId ?? this.selectedId,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    userPosition: userPosition ?? this.userPosition,
    sheetVisible: sheetVisible ?? this.sheetVisible,
    activeRoute: clearRoute ? null : activeRoute ?? this.activeRoute,
    routeViewRequested: clearRouteViewRequested
        ? false
        : routeViewRequested ?? this.routeViewRequested,
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
    activeRoute,
    routeViewRequested,
    routeRequestId,
  ];
}

// ------------------------------------------------------------------- bloc

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required GetNearbyFacilities getNearbyFacilities,
    required TokenStorage tokenStorage,
  }) : _getNearbyFacilities = getNearbyFacilities,
       _tokenStorage = tokenStorage,
       super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MapFacilitySelected>(_onFacilitySelected);
    on<MapOverviewRequested>(_onOverviewRequested);
    on<MapUserPositionUpdated>(_onUserPositionUpdated);
    on<MapRouteResolved>(_onRouteResolved);
    on<MapRouteViewRequested>(_onRouteViewRequested);
  }

  final GetNearbyFacilities _getNearbyFacilities;
  final TokenStorage _tokenStorage;
  StreamSubscription<Position>? _positionSub;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    final Map<String, dynamic>? saved = await _tokenStorage.readMapState();
    final double? lat = (saved?['latitude'] as num?)?.toDouble();
    final double? lng = (saved?['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      emit(
        state.copyWith(
          userPosition: LatLng(lat, lng),
          selectedId: saved?['selectedId'] as String?,
        ),
      );
    }

    // 1. Immediately clean up past streams to prevent background leaks
    await _positionSub?.cancel();
    _positionSub = null;

    // Location tracking can initialize alongside the recommendations request.
    if (ApiConfig.demoMode) {
      emit(
        state.copyWith(
          userPosition: LatLng(ApiConfig.demoLatitude, ApiConfig.demoLongitude),
        ),
      );
    } else {
      await _establishLocationPipeline();
    }

    try {
      final List<Facility> nearby = await _getNearbyFacilities(
        const NoParams(),
      );
      final List<FacilityRecommendation> results = <FacilityRecommendation>[
        for (int index = 0; index < nearby.length; index++)
          FacilityRecommendation(
            facility: nearby[index],
            rank: index == 0
                ? MatchRank.top
                : index == 1
                ? MatchRank.alternative
                : MatchRank.last,
            confidence: ConfidenceLevel.medium,
            confidenceScore: 50,
            reasons: const <String>['Near your current location'],
          ),
      ];

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
          routeRequestId: event.focusFacilityId == null
              ? state.routeRequestId
              : state.routeRequestId + 1,
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
      if (permission == LocationPermission.deniedForever || isClosed) {
        return;
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse)
          return;
      }

      // Start listening before requesting a one-off fix. Some emulators time
      // out on getCurrentPosition even though their location stream is live.
      if (_positionSub != null || isClosed) return;

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 5,
            ),
          ).listen(
            (Position position) {
              final DateTime? timestamp = position.timestamp;
              final bool isFresh =
                  timestamp == null ||
                  DateTime.now().difference(timestamp).abs() <
                      const Duration(minutes: 10);
              if (!isClosed && isFresh) {
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

      try {
        final Position currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 30),
          ),
        );
        final DateTime? timestamp = currentPosition.timestamp;
        final bool isFresh =
            timestamp == null ||
            DateTime.now().difference(timestamp).abs() <
                const Duration(minutes: 10);
        if (!isClosed && isFresh) {
          add(
            MapUserPositionUpdated(
              LatLng(currentPosition.latitude, currentPosition.longitude),
            ),
          );
        }
      } on TimeoutException {
        // The active stream remains subscribed and will update the map when
        // the emulator or device publishes its next location fix.
      }
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
        clearRouteViewRequested: true,
        routeRequestId: state.routeRequestId + 1,
      ),
    );
    _persistMapState(state.userPosition, event.facilityId);
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
        clearRouteViewRequested: true,
      ),
    );
    _persistMapState(state.userPosition, null);
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
    _persistMapState(event.position, state.selectedId);
  }

  void _onRouteResolved(MapRouteResolved event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        activeRoute: ActiveRoute(
          distance: event.distanceLabel,
          duration: event.durationLabel,
        ),
      ),
    );
  }

  void _onRouteViewRequested(
    MapRouteViewRequested event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(routeViewRequested: true));
  }

  Future<void> _persistMapState(LatLng position, String? selectedId) =>
      _tokenStorage.saveMapState(
        position.latitude,
        position.longitude,
        selectedId,
      );

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
