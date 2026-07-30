import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Solid blue call-to-action. Used for Login, Sign Up, Navigate, Continue.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expanded = true,
    this.height = 54,
    this.borderRadius = AppRadius.sm,
    this.color = AppColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expanded;
  final double height;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    final Widget content = isLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
              if (trailingIcon != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Icon(trailingIcon, size: 20, color: Colors.white),
              ],
            ],
          );

    return SizedBox(
      width: expanded ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enabled ? AppShadows.button : null,
        ),
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.45),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Outlined counterpart — "Navigate" next to "Call Now", "View Details".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expanded = true,
    this.height = 50,
    this.borderRadius = AppRadius.pill,
    this.foreground = AppColors.primary,
    this.background = AppColors.surface,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expanded;
  final double height;
  final double borderRadius;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: foreground.withValues(alpha: 0.45)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.button.copyWith(color: foreground),
              ),
            ),
            if (trailingIcon != null) ...<Widget>[
              const SizedBox(width: AppSpacing.xxs),
              Icon(trailingIcon, size: 18, color: foreground),
            ],
          ],
        ),
      ),
    );
  }
}

/// Flat white card-style button used for "Next" in the onboarding flow.
class GhostCardButton extends StatelessWidget {
  const GhostCardButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width = 264,
    this.height = 58,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 20,
                color: onPressed == null
                    ? AppColors.textMuted
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular white back button that floats over content on most screens.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed, this.size = 46});

  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: const Icon(
            Icons.arrow_back,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
