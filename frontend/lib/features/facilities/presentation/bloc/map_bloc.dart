import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../domain/usecases/facility_usecases.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

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

// ------------------------------------------------------------------ state

class MapState extends Equatable {
  const MapState({
    this.status = BlocStatus.initial,
    this.recommendations = const <FacilityRecommendation>[],
    this.mode = MapViewMode.overview,
    this.selectedId,
    this.errorMessage,
    this.userPosition = const LatLng(6.6885, -1.6244), // KNUST default
  });

  final BlocStatus status;
  final List<FacilityRecommendation> recommendations;
  final MapViewMode mode;
  final String? selectedId;
  final String? errorMessage;
  final LatLng userPosition;

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
    bool clearSelection = false,
    bool clearError = false,
  }) => MapState(
    status: status ?? this.status,
    recommendations: recommendations ?? this.recommendations,
    mode: mode ?? this.mode,
    selectedId: clearSelection ? null : selectedId ?? this.selectedId,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    userPosition: userPosition ?? this.userPosition,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    recommendations,
    mode,
    selectedId,
    errorMessage,
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
  }

  final GetRecommendations _getRecommendations;
  StreamSubscription<Position>? _positionSub;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));

    // Grab a one-off fix so the map isn't stuck on the KNUST fallback.
try {
  final Position position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 6),
    ),
  );
  emit(state.copyWith(userPosition: LatLng(position.latitude, position.longitude)));
} on TimeoutException {
  // Keep the KNUST fallback rather than blocking on a stuck fix.
} catch (_) {
  // No fix available yet — keep fallback.
}

    // Then keep listening as the user moves.
    await _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25, // meters — don't spam updates for tiny jitter
      ),
    ).listen((Position position) {
      add(MapUserPositionUpdated(LatLng(position.latitude, position.longitude)));
    });

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
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(status: BlocStatus.failure, errorMessage: failure.message),
      );
    }
  }

  void _onUserPositionUpdated(
    MapUserPositionUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(userPosition: event.position));
  }

  void _onFacilitySelected(MapFacilitySelected event, Emitter<MapState> emit) {
    emit(
      state.copyWith(selectedId: event.facilityId, mode: MapViewMode.facility),
    );
  }

  void _onOverviewRequested(
    MapOverviewRequested event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(mode: MapViewMode.overview, clearSelection: true));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}