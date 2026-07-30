import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/domain/entities/patient_profile.dart';
import 'onboarding_illustrations.dart';
import 'option_chip.dart';

/// The male/female pair on step 1, split by a hairline divider.
class GenderChoice extends StatelessWidget {
  const GenderChoice({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final Gender? selected;
  final ValueChanged<Gender> onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _GenderCard(
              gender: Gender.male,
              selected: selected == Gender.male,
              onTap: () => onSelect(Gender.male),
            ),
          ),
          const VerticalDivider(
            width: AppSpacing.lg,
            thickness: 1,
            color: AppColors.borderStrong,
          ),
          Expanded(
            child: _GenderCard(
              gender: Gender.female,
              selected: selected == Gender.female,
              onTap: () => onSelect(Gender.female),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.gender,
    required this.selected,
    required this.onTap,
  });

  final Gender gender;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentSurface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.accent : Colors.transparent,
              width: 1.6,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.86,
                  child: GenderAvatar(gender: gender, size: 150),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      gender.label,
                      style: AppTextStyles.h3.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    RadioDot(selected: selected, size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
