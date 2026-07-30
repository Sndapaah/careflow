import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../profile/domain/entities/patient_profile.dart';
import '../../domain/entities/medical_profile_draft.dart';
import '../../domain/usecases/submit_medical_profile.dart';

// ----------------------------------------------------------------- events

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class OnboardingGenderSelected extends OnboardingEvent {
  const OnboardingGenderSelected(this.gender);

  final Gender gender;

  @override
  List<Object?> get props => <Object?>[gender];
}

final class OnboardingDateOfBirthSelected extends OnboardingEvent {
  const OnboardingDateOfBirthSelected(this.dateOfBirth);

  final DateTime dateOfBirth;

  @override
  List<Object?> get props => <Object?>[dateOfBirth];
}

final class OnboardingConditionToggled extends OnboardingEvent {
  const OnboardingConditionToggled(this.condition);

  final String condition;

  @override
  List<Object?> get props => <Object?>[condition];
}

final class OnboardingAllergyToggled extends OnboardingEvent {
  const OnboardingAllergyToggled(this.allergy);

  final String allergy;

  @override
  List<Object?> get props => <Object?>[allergy];
}

final class OnboardingContactChanged extends OnboardingEvent {
  const OnboardingContactChanged({
    this.fullName,
    this.relationship,
    this.phoneNumber,
  });

  final String? fullName;
  final String? relationship;
  final String? phoneNumber;

  @override
  List<Object?> get props => <Object?>[fullName, relationship, phoneNumber];
}

final class OnboardingBloodTypeSelected extends OnboardingEvent {
  const OnboardingBloodTypeSelected(this.bloodType);

  final String bloodType;

  @override
  List<Object?> get props => <Object?>[bloodType];
}

final class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

final class OnboardingBackPressed extends OnboardingEvent {
  const OnboardingBackPressed();
}

// ------------------------------------------------------------------ state

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = BlocStatus.initial,
    this.step = 0,
    this.draft = const MedicalProfileDraft(),
    this.errorMessage,
  });

  static const int totalSteps = 5;

  final BlocStatus status;

  /// Zero-based index of the visible step.
  final int step;
  final MedicalProfileDraft draft;
  final String? errorMessage;

  bool get canAdvance => draft.canAdvanceFrom(step);

  bool get isLastStep => step == totalSteps - 1;

  /// "1/5"
  String get stepLabel => '${step + 1}/$totalSteps';

  double get progress => (step + 1) / totalSteps;

  OnboardingState copyWith({
    BlocStatus? status,
    int? step,
    MedicalProfileDraft? draft,
    String? errorMessage,
    bool clearError = false,
  }) => OnboardingState(
    status: status ?? this.status,
    step: step ?? this.step,
    draft: draft ?? this.draft,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => <Object?>[status, step, draft, errorMessage];
}

// ------------------------------------------------------------------- bloc

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({required SubmitMedicalProfile submitMedicalProfile})
    : _submitMedicalProfile = submitMedicalProfile,
      super(const OnboardingState()) {
    on<OnboardingGenderSelected>(_onGenderSelected);
    on<OnboardingDateOfBirthSelected>(_onDateOfBirthSelected);
    on<OnboardingConditionToggled>(_onConditionToggled);
    on<OnboardingAllergyToggled>(_onAllergyToggled);
    on<OnboardingContactChanged>(_onContactChanged);
    on<OnboardingBloodTypeSelected>(_onBloodTypeSelected);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingBackPressed>(_onBackPressed);
  }

  final SubmitMedicalProfile _submitMedicalProfile;

  void _onGenderSelected(
    OnboardingGenderSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(gender: event.gender)));
  }

  void _onDateOfBirthSelected(
    OnboardingDateOfBirthSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(dateOfBirth: event.dateOfBirth),
      ),
    );
  }

  void _onConditionToggled(
    OnboardingConditionToggled event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          conditions: _toggle(state.draft.conditions, event.condition),
        ),
      ),
    );
  }

  void _onAllergyToggled(
    OnboardingAllergyToggled event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          allergies: _toggle(state.draft.allergies, event.allergy),
        ),
      ),
    );
  }

  void _onContactChanged(
    OnboardingContactChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          emergencyContact: state.draft.emergencyContact.copyWith(
            fullName: event.fullName,
            relationship: event.relationship,
            phoneNumber: event.phoneNumber,
          ),
        ),
      ),
    );
  }

  void _onBloodTypeSelected(
    OnboardingBloodTypeSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(draft: state.draft.copyWith(bloodType: event.bloodType)),
    );
  }

  Future<void> _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canAdvance) return;

    if (!state.isLastStep) {
      emit(state.copyWith(step: state.step + 1, clearError: true));
      return;
    }

    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      await _submitMedicalProfile(state.draft);
      emit(state.copyWith(status: BlocStatus.success));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  void _onBackPressed(
    OnboardingBackPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.step == 0) return;
    emit(state.copyWith(step: state.step - 1, clearError: true));
  }

  /// Multi-select with an exclusive "None": choosing None clears everything
  /// else, and choosing anything else clears None.
  Set<String> _toggle(Set<String> current, String value) {
    if (value == MedicalProfileDraft.noneOption) {
      return current.contains(value)
          ? const <String>{}
          : <String>{MedicalProfileDraft.noneOption};
    }

    final Set<String> next = <String>{...current}
      ..remove(MedicalProfileDraft.noneOption);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    return next;
  }
}
