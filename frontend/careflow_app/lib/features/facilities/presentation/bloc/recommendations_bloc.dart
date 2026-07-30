import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../domain/usecases/facility_usecases.dart';

// ----------------------------------------------------------------- events

sealed class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class RecommendationsRequested extends RecommendationsEvent {
  const RecommendationsRequested();
}

// ------------------------------------------------------------------ state

class RecommendationsState extends Equatable {
  const RecommendationsState({
    this.status = BlocStatus.initial,
    this.recommendations = const <FacilityRecommendation>[],
    this.errorMessage,
  });

  final BlocStatus status;
  final List<FacilityRecommendation> recommendations;
  final String? errorMessage;

  /// "3 matches near you"
  String get matchCountLabel {
    final int count = recommendations.length;
    return '$count ${count == 1 ? 'match' : 'matches'} near you';
  }

  @override
  List<Object?> get props => <Object?>[status, recommendations, errorMessage];
}

// ------------------------------------------------------------------- bloc

class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc({required GetRecommendations getRecommendations})
    : _getRecommendations = getRecommendations,
      super(const RecommendationsState()) {
    on<RecommendationsRequested>(_onRequested);
  }

  final GetRecommendations _getRecommendations;

  Future<void> _onRequested(
    RecommendationsRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    emit(const RecommendationsState(status: BlocStatus.loading));
    try {
      final List<FacilityRecommendation> results = await _getRecommendations(
        const NoParams(),
      );
      emit(
        RecommendationsState(
          status: BlocStatus.success,
          recommendations: results,
        ),
      );
    } on Failure catch (failure) {
      emit(
        RecommendationsState(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
