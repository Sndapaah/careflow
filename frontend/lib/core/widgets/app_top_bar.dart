import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_buttons.dart';

/// Header used on the pushed screens: a circular back button on the left,
/// then a title with an optional subtitle underneath.
///
/// [centerTitle] matches the facility-detail layout where the title is
/// optically centred; the stacked variant (AI Analysis, Emergency) keeps the
/// text left-aligned next to the button.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor = AppColors.textPrimary,
    this.centerTitle = false,
    this.onBack,
    this.trailing,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Color titleColor;
  final bool centerTitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final Widget text = Column(
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: AppTextStyles.h1.copyWith(color: titleColor),
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              CircleBackButton(onPressed: onBack),
              const SizedBox(width: AppSpacing.md),
              if (centerTitle)
                Expanded(child: Center(child: text))
              else
                Expanded(child: text),
              if (trailing != null)
                trailing!
              else if (centerTitle)
                const SizedBox(width: 46),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

/// Header without a back button — used by the root tabs (Profile).
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xs,
            AppSpacing.gutter,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(title, style: AppTextStyles.h2.copyWith(fontSize: 22)),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
