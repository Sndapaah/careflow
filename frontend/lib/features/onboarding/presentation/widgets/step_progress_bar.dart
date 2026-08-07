import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Five segments across the top of the onboarding screens; segments up to and
/// including the current step are filled cyan.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  /// Zero-based index of the visible step.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (int index) {
        final bool filled = index <= current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == total - 1 ? 0 : AppSpacing.xs,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 5,
              decoration: BoxDecoration(
                color: filled ? AppColors.accent : AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        );
      }),
    );
  }
}
