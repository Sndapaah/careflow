import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/widgets/confidence_ring.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../bloc/symptom_analysis_bloc.dart';

/// Shows what the symptom checker inferred, and lets the patient correct the
/// severity before searching for facilities.
class AiAnalysisPage extends StatelessWidget {
  const AiAnalysisPage({super.key, required this.symptoms});

  final List<String> symptoms;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SymptomAnalysisBloc>(
      create: (_) =>
          sl<SymptomAnalysisBloc>()..add(SymptomAnalysisRequested(symptoms)),
      child: const _AiAnalysisView(),
    );
  }
}

class _AiAnalysisView extends StatelessWidget {
  const _AiAnalysisView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AppTopBar(
              title: 'AI Analysis',
              subtitle: 'Based on your symptoms',
            ),
            Expanded(
              child: BlocConsumer<SymptomAnalysisBloc, SymptomAnalysisState>(
                listenWhen: (SymptomAnalysisState previous, SymptomAnalysisState current) =>
                    current.analysis?.severity == SeverityLevel.high &&
                    previous.analysis?.severity != SeverityLevel.high,
                listener: (BuildContext context, SymptomAnalysisState state) =>
                    _showEmergencyDialog(context, state.analysis!),
                builder: (BuildContext context, SymptomAnalysisState state) {
                  if (state.status.isLoading || state.analysis == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status.isFailure) {
                    return Center(
                      child: Padding(
                        padding: AppSpacing.page,
                        child: Text(
                          state.errorMessage ?? 'Something went wrong.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge,
                        ),
                      ),
                    );
                  }
                  return _AnalysisBody(analysis: state.analysis!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEmergencyDialog(
    BuildContext context,
    SymptomAnalysis analysis,
  ) async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Emergency Symptom Detected',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Please stay calm, CareFlow will take care of you',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Continue',
                    height: 46,
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (proceed == true && context.mounted) {
      context.push(AppRoutes.emergency, extra: analysis);
    }
  }
}

class _AnalysisBody extends StatelessWidget {
  const _AnalysisBody({required this.analysis});

  final SymptomAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: <Widget>[
        _SymptomsRow(symptoms: analysis.symptoms),
        const SizedBox(height: AppSpacing.lg),
        _ConditionsCard(conditions: analysis.conditions),
        const SizedBox(height: AppSpacing.lg),
        _RecommendationCard(recommendations: analysis.recommendations),
        const SizedBox(height: AppSpacing.lg),
        _SeverityCard(severity: analysis.severity),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Find Recommended Facilities',
          trailingIcon: Icons.double_arrow_rounded,
          borderRadius: AppRadius.pill,
          height: 60,
          onPressed: () => context.push(AppRoutes.recommendations),
        ),
      ],
    );
  }
}

/// The logo alongside the card listing what the patient typed.
class _SymptomsRow extends StatelessWidget {
  const _SymptomsRow({required this.symptoms});

  final List<String> symptoms;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const CareFlowLogo(size: 108),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const _CardIcon(icon: Icons.checklist_rounded),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Symptom(s) Entered',
                        style: AppTextStyles.h3.copyWith(fontSize: 19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    for (final String symptom in symptoms)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: AppRadius.field,
                        ),
                        child: Text(
                          symptom,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.conditions});

  final List<PossibleCondition> conditions;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _CardIcon(icon: Icons.monitor_heart_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Possible Conditions',
                  style: AppTextStyles.h2.copyWith(fontSize: 21),
                ),
              ),
              Flexible(
                child: Text(
                  'Confidence Score',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final PossibleCondition condition in conditions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      condition.name,
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 17),
                    ),
                  ),
                  ConfidenceScore(percent: condition.confidence, size: 24),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(SymptomAnalysis.disclaimer, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendations});

  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _CardIcon(icon: Icons.assignment_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Recommendation',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2.copyWith(fontSize: 21),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final String line in recommendations) BulletLine(text: line),
        ],
      ),
    );
  }
}

class _SeverityCard extends StatelessWidget {
  const _SeverityCard({required this.severity});

  final SeverityLevel severity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primarySurface.withValues(alpha: 0.55),
      shadows: null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Severity',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2.copyWith(fontSize: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'You may choose severity level if incorrect.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              for (final SeverityLevel level in SeverityLevel.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: level == SeverityLevel.high ? 0 : AppSpacing.xs,
                    ),
                    child: _SeverityPill(
                      level: level,
                      isSelected: level == severity,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.level, required this.isSelected});

  final SeverityLevel level;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => context.read<SymptomAnalysisBloc>().add(
          SymptomSeverityOverridden(level),
        ),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            level.label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tinted circle holding a section icon.
class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.accentSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.accent, size: 22),
    );
  }
}
