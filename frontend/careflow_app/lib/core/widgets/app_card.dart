import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// White rounded container with the soft shadow used by every card surface.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.surface,
    this.radius = AppRadius.lg,
    this.border,
    this.shadows = AppShadows.card,
    this.onTap,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

/// Flat tinted tile that shows a small label above a value — the
/// "WAIT / 18 min" and "CONFIDENCE / High" pair.
class LabelledValueTile extends StatelessWidget {
  const LabelledValueTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.background = AppColors.accentSurface,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon-over-number-over-caption column — "12 / Patient Capacity".
class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.accent,
    this.iconBackground = AppColors.accentSurface,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.statValue),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.statLabel,
        ),
      ],
    );
  }
}

/// Inline "icon + label + bold value" used across the live-stats rows.
class InlineStat extends StatelessWidget {
  const InlineStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AppColors.textSecondary,
    this.valueStyle,
    this.axis = Axis.horizontal,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final TextStyle? valueStyle;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final Widget labelText = Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    );
    final Widget valueText = Text(
      value,
      style: valueStyle ?? AppTextStyles.statValue.copyWith(fontSize: 18),
    );

    if (axis == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          labelText,
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Flexible(child: valueText),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: labelText),
        const SizedBox(width: AppSpacing.xs),
        valueText,
      ],
    );
  }
}

/// A "label ......... value" row inside the profile information cards.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.leadingIcon,
  });

  final String label;
  final String value;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          if (leadingIcon != null) ...<Widget>[
            Icon(leadingIcon, size: 17, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green tick + text line used by every "Recommended because" list.
class CheckLine extends StatelessWidget {
  const CheckLine({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.check, size: 17, color: color ?? AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small green bullet + text line, as on the AI analysis screen.
class BulletLine extends StatelessWidget {
  const BulletLine({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: style ?? AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }
}
