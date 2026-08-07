import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../profile/domain/entities/patient_profile.dart';
import '../../domain/entities/medical_profile_draft.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/gender_choice.dart';
import '../widgets/onboarding_illustrations.dart';
import '../widgets/option_chip.dart';
import '../widgets/step_progress_bar.dart';
import '../../../../core/utils/field_validators.dart';
import '../../../../core/widgets/validated_field.dart';

/// The five-step medical questionnaire new patients complete after verifying
/// their contact. All steps share one bloc, one header and one Next action.
bool _showsSkip(int step) => step != 0 && step != 3;

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (OnboardingState p, OnboardingState c) =>
          p.status != c.status,
      listener: (BuildContext context, OnboardingState state) {
        if (state.status.isSuccess) {
          context.go(AppRoutes.locationPermission);
        } else if (state.status.isFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingBloc bloc = context.read<OnboardingBloc>();

        return PopScope<Object?>(
          canPop: state.step == 0,
          onPopInvokedWithResult: (bool didPop, Object? _) {
            if (!didPop) bloc.add(const OnboardingBackPressed());
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  _StepHeader(
                    state: state,
                    onBack: () => state.step == 0
                        ? context.pop()
                        : bloc.add(const OnboardingBackPressed()),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: _StepBody(state: state, bloc: bloc),
                    ),
                  ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
                    top: AppSpacing.md,
                    bottom: AppSpacing.xl,
                  ),
                  child: _showsSkip(state.step)
                      ? Row(
                          children: <Widget>[
                            Expanded(child: _SkipButton(state: state, bloc: bloc)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: _NextButton(state: state, bloc: bloc)),
                          ],
                        )
                      : Center(
                          child: SizedBox(
                            width: 240,
                            child: _NextButton(state: state, bloc: bloc),
                          ),
                        ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.state, required this.onBack});

  final OnboardingState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 26),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: StepProgressBar(
              current: state.step,
              total: OnboardingState.totalSteps,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(state.stepLabel, style: AppTextStyles.h2.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  @override
  Widget build(BuildContext context) {
    return switch (state.step) {
      0 => _IdentityStep(state: state, bloc: bloc),
      1 => _ConditionsStep(state: state, bloc: bloc),
      2 => _AllergiesStep(state: state, bloc: bloc),
      3 => _ContactStep(state: state, bloc: bloc),
      _ => _BloodTypeStep(state: state, bloc: bloc),
    };
  }
}

// ------------------------------------------------------------------ step 1

class _IdentityStep extends StatelessWidget {
  const _IdentityStep({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.draft.dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) bloc.add(OnboardingDateOfBirthSelected(picked));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? dob = state.draft.dateOfBirth;

    return Column(
      children: <Widget>[
        Text.rich(
          TextSpan(
            style: AppTextStyles.h2.copyWith(fontSize: 21),
            children: <InlineSpan>[
              const TextSpan(text: 'Start your journey to connect with '),
              TextSpan(
                text: 'CareFlow',
                style: TextStyle(color: AppColors.accent),
              ),
              const TextSpan(text: ' today'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Please choose your gender:',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        GenderChoice(
          selected: state.draft.gender,
          onSelect: (Gender gender) =>
              bloc.add(OnboardingGenderSelected(gender)),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Please enter your date of birth:',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppPickerField(
          label: 'Select Date',
          value: dob == null ? null : DateFormat('yyyy-MM-dd').format(dob),
          trailing: Icons.calendar_month_outlined,
          onTap: () => _pickDate(context),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ------------------------------------------------------------------ step 2

class _ConditionsStep extends StatelessWidget {
  const _ConditionsStep({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  @override
  Widget build(BuildContext context) {
    return _QuestionStep(
      title: 'Any existing health conditions?',
      illustration: const ConditionsIllustration(size: 210),
      options: MedicalProfileDraft.conditionOptions,
      selected: state.draft.conditions,
      onToggle: (String value) => bloc.add(OnboardingConditionToggled(value)),
    );
  }
}

// ------------------------------------------------------------------ step 3

class _AllergiesStep extends StatelessWidget {
  const _AllergiesStep({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  @override
  Widget build(BuildContext context) {
    return _QuestionStep(
      title: 'Any existing allergies?',
      illustration: const AllergiesIllustration(size: 210),
      options: MedicalProfileDraft.allergyOptions,
      selected: state.draft.allergies,
      onToggle: (String value) => bloc.add(OnboardingAllergyToggled(value)),
    );
  }
}

// ------------------------------------------------------------------ step 5

class _BloodTypeStep extends StatelessWidget {
  const _BloodTypeStep({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  @override
  Widget build(BuildContext context) {
    final String? chosen = state.draft.bloodType;

    return _QuestionStep(
      title: 'What is your blood type?',
      illustration: const BloodTypeIllustration(size: 190),
      options: MedicalProfileDraft.bloodTypeOptions,
      selected: <String>{?chosen},
      onToggle: (String value) => bloc.add(OnboardingBloodTypeSelected(value)),
      alignment: WrapAlignment.center,
    );
  }
}

/// Shared layout for the three "pick from a list" steps.
class _QuestionStep extends StatelessWidget {
  const _QuestionStep({
    required this.title,
    required this.illustration,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.alignment = WrapAlignment.start,
  });

  final String title;
  final Widget illustration;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppSpacing.lg),
        illustration,
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: alignment,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final String option in options)
              OptionChip(
                label: option,
                selected: selected.contains(option),
                onTap: () => onToggle(option),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ------------------------------------------------------------------ step 4

class _ContactStep extends StatelessWidget {
  const _ContactStep({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  Future<void> _pickRelationship(BuildContext context) async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final String option in MedicalProfileDraft.relationshipOptions)
              ListTile(
                title: Text(option, style: AppTextStyles.bodyLarge),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );

    if (choice != null) {
      bloc.add(OnboardingContactChanged(relationship: choice));
    }
  }

  @override
  Widget build(BuildContext context) {
    final EmergencyContact contact = state.draft.emergencyContact;

    return Column(
      children: <Widget>[
        Text.rich(
          TextSpan(
            style: AppTextStyles.h2.copyWith(fontSize: 21),
            children: <InlineSpan>[
              TextSpan(
                text: 'CareFlow',
                style: TextStyle(color: AppColors.accent),
              ),
              const TextSpan(
                text: ' Please we will like to have an emergency contact of yours.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        const EmergencyContactIllustration(size: 200),
        const SizedBox(height: AppSpacing.xl),
        ValidatedField(
          hint: 'Full Name',
          textInputAction: TextInputAction.next,
          validator: FieldValidators.fullName,
          onChanged: (String v) => bloc.add(OnboardingContactChanged(fullName: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPickerField(
          label: 'Select Relationship Type',
          value: contact.relationship.isEmpty ? null : contact.relationship,
          dividerBeforeTrailing: true,
          onTap: () => _pickRelationship(context),
        ),
        const SizedBox(height: AppSpacing.md),
        ValidatedField(
          hint: 'Phone Number',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          validator: FieldValidators.phone,
          onChanged: (String v) => bloc.add(OnboardingContactChanged(phoneNumber: v)),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
class _NextButton extends StatelessWidget {
  const _NextButton({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  @override
  Widget build(BuildContext context) {
    final String label = state.isLastStep ? 'Finish' : 'Next';
    final VoidCallback? onPressed = state.canAdvance && !state.status.isLoading
        ? () => bloc.add(const OnboardingNextPressed())
        : null;

    if (state.canAdvance) {
      return PrimaryButton(
        label: label,
        onPressed: onPressed,
        isLoading: state.status.isLoading,
        height: 48,
      );
    }

    return SecondaryButton(label: label, onPressed: onPressed, height: 48);
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.state, required this.bloc});

  final OnboardingState state;
  final OnboardingBloc bloc;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: state.isLastStep ? 'Skip' : 'Skip',
      onPressed: state.status.isLoading
          ? null
          : () => bloc.add(const OnboardingSkipPressed()),
      height: 48,
    );
  }
}