import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/facility.dart';

class LiveIndicator extends StatelessWidget {
  const LiveIndicator({super.key, required this.isLive});
  final bool isLive;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isLive ? AppColors.success : AppColors.textMuted,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        isLive ? 'Live' : 'Offline',
        style: AppTextStyles.caption.copyWith(
          color: isLive ? AppColors.success : AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class MapCircleButton extends StatelessWidget {
  const MapCircleButton({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: const CircleBorder(),
    elevation: 3,
    shadowColor: AppColors.shadowStrong,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox.square(
        dimension: 50,
        child: Icon(icon, size: 24, color: AppColors.textPrimary),
      ),
    ),
  );
}

class FacilityCallout extends StatelessWidget {
  const FacilityCallout({super.key, required this.facility});
  final Facility facility;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xs), boxShadow: AppShadows.card),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(facility.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.h3.copyWith(color: AppColors.accent, fontSize: 16)),
        const SizedBox(height: 3),
        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          const Icon(Icons.groups_outlined, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('${facility.currentPatients}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.person_add_alt, size: 17, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('${facility.incomingPatients}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ]),
        if (facility.isEmergencyCapable) ...<Widget>[const SizedBox(height: 4), const StatusBadge.emergency()],
      ]),
    ),
  );
}
