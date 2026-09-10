import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../../domain/usecases/symptom_usecases.dart';

// ----------------------------------------------------------------- events

sealed class SymptomAnalysisEvent extends Equatable {
  const SymptomAnalysisEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class SymptomAnalysisRequested extends SymptomAnalysisEvent {
  const SymptomAnalysisRequested(this.request);

  final SymptomCheckRequest request;

  @override
  List<Object?> get props => <Object?>[request];
}

/// The patient can correct the severity the model inferred.
final class SymptomSeverityOverridden extends SymptomAnalysisEvent {
  const SymptomSeverityOverridden(this.severity);

  final SeverityLevel severity;

  @override
  List<Object?> get props => <Object?>[severity];
}

// ------------------------------------------------------------------ state

class SymptomAnalysisState extends Equatable {
  const SymptomAnalysisState({
    this.status = BlocStatus.initial,
    this.request,
    this.analysis,
    this.errorMessage,
  });

  final BlocStatus status;
  final SymptomCheckRequest? request;
  final SymptomAnalysis? analysis;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[
    status,
    request,
    analysis,
    errorMessage,
  ];
}

// ------------------------------------------------------------------- bloc

class SymptomAnalysisBloc
    extends Bloc<SymptomAnalysisEvent, SymptomAnalysisState> {
  SymptomAnalysisBloc({required AnalyzeSymptoms analyzeSymptoms})
    : _analyzeSymptoms = analyzeSymptoms,
      super(const SymptomAnalysisState()) {
    on<SymptomAnalysisRequested>(_onRequested);
    on<SymptomSeverityOverridden>(_onSeverityOverridden);
  }

  final AnalyzeSymptoms _analyzeSymptoms;

  Future<void> _onRequested(
    SymptomAnalysisRequested event,
    Emitter<SymptomAnalysisState> emit,
  ) async {
    emit(
      SymptomAnalysisState(
        status: BlocStatus.loading,
        request: event.request,
      ),
    );
    try {
      final SymptomAnalysis analysis = await _analyzeSymptoms(event.request);
      emit(
        SymptomAnalysisState(
          status: BlocStatus.success,
          request: event.request,
          analysis: analysis,
        ),
      );
    } on Failure catch (failure) {
      emit(
        SymptomAnalysisState(
          status: BlocStatus.failure,
          request: event.request,
          errorMessage: failure.message,
        ),
      );
    } catch (_) {
      // Response mapping and unexpected client errors must leave the loading
      // state as a recoverable error so the user can retry the same request.
      emit(
        SymptomAnalysisState(
          status: BlocStatus.failure,
          request: event.request,
          errorMessage: 'We could not display the analysis. Please try again.',
        ),
      );
    }
  }

  void _onSeverityOverridden(
    SymptomSeverityOverridden event,
    Emitter<SymptomAnalysisState> emit,
  ) {
    final SymptomAnalysis? current = state.analysis;
    if (current == null) return;
    emit(
      SymptomAnalysisState(
        status: state.status,
        analysis: current.copyWith(severity: event.severity),
      ),
    );
  }
}
