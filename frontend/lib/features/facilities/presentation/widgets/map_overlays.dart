import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/facility.dart';
import 'recommendation_card.dart';

/// White circular control floating over the map (back, recentre).
class MapCircleButton extends StatelessWidget {
  const MapCircleButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
}

/// The info bubble anchored to a facility pin.
class FacilityCallout extends StatelessWidget {
  const FacilityCallout({super.key, required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            facility.name,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.accent,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.groups_outlined,
                size: 17,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${facility.currentPatients}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.person_add_alt,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${facility.incomingPatients}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (facility.isEmergencyCapable && facility.emergencies > 0)
            const StatusBadge.emergency()
          else
            FacilityLoadBadge(load: facility.load),
        ],
      ),
    );
  }
}

/// Blue capsule showing drive time and distance along the route.
class RoutePill extends StatelessWidget {
  const RoutePill({super.key, required this.eta, required this.distance});

  final String eta;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.directions_car_filled,
            size: 22,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                eta,
                style: AppTextStyles.badge.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                distance,
                style: AppTextStyles.badge.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Blue "you are here" dot with a white ring.
class UserLocationDot extends StatelessWidget {
  const UserLocationDot({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: AppShadows.card,
      ),
    );
  }
}

/// Map pin marking a facility.
class FacilityPin extends StatelessWidget {
  const FacilityPin({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent, width: 1.5),
        boxShadow: AppShadows.subtle,
      ),
      child: const Icon(
        Icons.local_hospital,
        size: 20,
        color: AppColors.accent,
      ),
    );
  }
}

/// "Live ((•))" indicator on the sheet header.
class LiveIndicator extends StatelessWidget {
  const LiveIndicator({super.key, required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final Color colour = isLive ? AppColors.success : AppColors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          isLive ? 'Live' : 'Offline',
          style: AppTextStyles.bodyLarge.copyWith(
            color: colour,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Icon(Icons.sensors, size: 20, color: colour),
      ],
    );
  }
}
