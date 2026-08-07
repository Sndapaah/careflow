import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Small rounded label used everywhere in the designs: "Low Load",
/// "TOP MATCH", "Emergency", "Out-Patient Department".
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
    this.dense = false,
    this.uppercase = false,
  });

  /// Green "Low Load" pill.
  const StatusBadge.lowLoad({Key? key})
    : this(
        key: key,
        label: 'Low Load',
        foreground: AppColors.successText,
        background: AppColors.successSurface,
      );

  /// Amber "Medium Load" pill.
  const StatusBadge.mediumLoad({Key? key})
    : this(
        key: key,
        label: 'Medium Load',
        foreground: AppColors.warning,
        background: AppColors.warningSurface,
      );

  /// Red "Emergency" pill with the beacon glyph.
  const StatusBadge.emergency({Key? key, String label = 'Emergency'})
    : this(
        key: key,
        label: label,
        foreground: AppColors.danger,
        background: AppColors.dangerSurface,
        icon: Icons.emergency_share_rounded,
      );

  /// Cyan "TOP MATCH" / "ALT MATCH" tag.
  const StatusBadge.match({Key? key, required String label})
    : this(
        key: key,
        label: label,
        foreground: AppColors.accentDark,
        background: AppColors.accentSurface,
        dense: true,
        uppercase: true,
      );

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;
  final bool dense;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
        vertical: dense ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.rounded,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: AppTextStyles.badge.copyWith(
              color: foreground,
              letterSpacing: uppercase ? 0.4 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// White outlined chip on the facility detail screen — "Top Match",
/// "Low Load", "1.2 km".
class OutlinedInfoChip extends StatelessWidget {
  const OutlinedInfoChip({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.labelColor = AppColors.textPrimary,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.badge.copyWith(
                color: labelColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pale-tinted tag list item — the "Departments" row on facility detail.
class SoftTag extends StatelessWidget {
  const SoftTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: AppRadius.rounded,
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: AppColors.accentDark,
          fontSize: 13,
        ),
      ),
    );
  }
}
