import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../../symptoms/domain/entities/symptom_analysis.dart';
import '../../domain/usecases/facility_usecases.dart';

// ----------------------------------------------------------------- events

sealed class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class EmergencyMatchRequested extends EmergencyEvent {
  const EmergencyMatchRequested({this.analysis});

  final SymptomAnalysis? analysis;

  @override
  List<Object?> get props => <Object?>[analysis];
}

// ------------------------------------------------------------------ state

class EmergencyState extends Equatable {
  const EmergencyState({
    this.status = BlocStatus.initial,
    this.match,
    this.errorMessage,
  });

  final BlocStatus status;
  final FacilityRecommendation? match;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, match, errorMessage];
}

// ------------------------------------------------------------------- bloc

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  EmergencyBloc({required GetEmergencyMatch getEmergencyMatch})
    : _getEmergencyMatch = getEmergencyMatch,
      super(const EmergencyState()) {
    on<EmergencyMatchRequested>(_onRequested);
  }

  final GetEmergencyMatch _getEmergencyMatch;

  Future<void> _onRequested(
  EmergencyMatchRequested event,
  Emitter<EmergencyState> emit,
) async {
  emit(const EmergencyState(status: BlocStatus.loading));
  try {
    final FacilityRecommendation match = await _getEmergencyMatch(
      const NoParams(), // still NoParams for now — see note below
    );
    emit(EmergencyState(status: BlocStatus.success, match: match));
  } on Failure catch (failure) {
    emit(
      EmergencyState(status: BlocStatus.failure, errorMessage: failure.message),
    );
  }
}
}
