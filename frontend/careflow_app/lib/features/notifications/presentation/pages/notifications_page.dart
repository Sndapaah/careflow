// lib/features/notifications/presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';

/// Placeholder feed until a real notifications backend exists. Swap the
/// static list below for a NotificationsBloc + repository once you're
/// ready to wire it to the API.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_NotificationItem> items = <_NotificationItem>[
      const _NotificationItem(
        icon: Icons.local_hospital_outlined,
        title: 'Facility update',
        body: 'KNUST Hospital wait time has dropped to 12 minutes.',
        whenLabel: '2h ago',
      ),
      const _NotificationItem(
        icon: Icons.medical_information_outlined,
        title: 'Profile reminder',
        body: 'Add your allergies to get more accurate recommendations.',
        whenLabel: '1d ago',
      ),
      const _NotificationItem(
        icon: Icons.eco_outlined,
        title: "Today's health tip",
        body: 'A new health tip is ready for you.',
        whenLabel: '1d ago',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AppTopBar(
              title: 'Notifications',
              subtitle: 'Recent activity and updates',
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        AppSpacing.sm,
                        AppSpacing.gutter,
                        AppSpacing.xl,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (BuildContext context, int index) {
                        final _NotificationItem item = items[index];
                        return AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: AppColors.accent,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          item.whenLabel,
                                          style: AppTextStyles.caption
                                              .copyWith(
                                                color: AppColors.textMuted,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      item.body,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.whenLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final String whenLabel;
}