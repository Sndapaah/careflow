import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

// ------------------------------------------------------------------ state

class MapState extends Equatable {
  const MapState({
    this.status = BlocStatus.initial,
    this.recommendations = const <FacilityRecommendation>[],
    this.mode = MapViewMode.overview,
    this.selectedId,
    this.errorMessage,
  });

  final BlocStatus status;
  final List<FacilityRecommendation> recommendations;
  final MapViewMode mode;
  final String? selectedId;
  final String? errorMessage;

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
    bool clearSelection = false,
    bool clearError = false,
  }) => MapState(
    status: status ?? this.status,
    recommendations: recommendations ?? this.recommendations,
    mode: mode ?? this.mode,
    selectedId: clearSelection ? null : selectedId ?? this.selectedId,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
  }

  final GetRecommendations _getRecommendations;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
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
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
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
}
