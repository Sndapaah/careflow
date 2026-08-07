import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';

/// Palette swap between the calm cyan recommendation list and the red
/// emergency screen, which share the same card anatomy.
enum RecommendationTone { standard, emergency }

/// One ranked facility: rank tag, distance, wait/confidence tiles, the
/// reasoning bullets, and the two actions.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onNavigate,
    this.onViewDetails,
    this.onCall,
    this.tone = RecommendationTone.standard,
  });

  final FacilityRecommendation recommendation;
  final VoidCallback onNavigate;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCall;
  final RecommendationTone tone;

  bool get _isEmergency => tone == RecommendationTone.emergency;

  Color get _tileBackground =>
      _isEmergency ? AppColors.dangerSurfaceSoft : AppColors.accentSurface;

  @override
  Widget build(BuildContext context) {
    final Facility facility = recommendation.facility;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TitleRow(recommendation: recommendation, showRankTag: !_isEmergency),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: <Widget>[
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${facility.distanceLabel} away',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: LabelledValueTile(
                  label: 'Wait',
                  value: facility.waitLabel,
                  icon: Icons.access_time,
                  background: _tileBackground,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LabelledValueTile(
                  label: 'Confidence',
                  value: recommendation.confidence.label,
                  icon: Icons.shield_outlined,
                  background: _tileBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _tileBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recommended because',
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final String reason in recommendation.reasons)
                  CheckLine(text: reason),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _isEmergency
                    ? SecondaryButton(
                        label: 'Navigate',
                        trailingIcon: Icons.near_me_outlined,
                        onPressed: onNavigate,
                      )
                    : SecondaryButton(
                        label: 'View Details',
                        trailingIcon: Icons.chevron_right,
                        onPressed: onViewDetails,
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _isEmergency
                    ? PrimaryButton(
                        label: 'Call Now',
                        icon: Icons.call,
                        height: 50,
                        borderRadius: AppRadius.pill,
                        onPressed: onCall,
                      )
                    : PrimaryButton(
                        label: 'Navigate',
                        icon: Icons.near_me_outlined,
                        height: 50,
                        borderRadius: AppRadius.pill,
                        onPressed: onNavigate,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.recommendation, required this.showRankTag});

  final FacilityRecommendation recommendation;
  final bool showRankTag;

  @override
  Widget build(BuildContext context) {
    final Facility facility = recommendation.facility;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (showRankTag) ...<Widget>[
          StatusBadge.match(label: recommendation.rank.label),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Text(
            facility.name,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3.copyWith(fontSize: 19),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (showRankTag)
          FacilityLoadBadge(load: facility.load)
        else
          const StatusBadge.emergency(),
      ],
    );
  }
}

/// Picks the right coloured badge for a facility's current load.
class FacilityLoadBadge extends StatelessWidget {
  const FacilityLoadBadge({super.key, required this.load});

  final FacilityLoad load;

  @override
  Widget build(BuildContext context) => switch (load) {
    FacilityLoad.low => const StatusBadge.lowLoad(),
    FacilityLoad.medium => const StatusBadge.mediumLoad(),
    FacilityLoad.high => const StatusBadge(
      label: 'High Load',
      foreground: AppColors.danger,
      background: AppColors.dangerSurface,
    ),
  };
}
