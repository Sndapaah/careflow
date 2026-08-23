import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confidence_ring.dart';
import '../../../../core/widgets/hospital_glyph.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import 'map_overlays.dart';
import 'recommendation_card.dart';

/// Grab handle at the top of the draggable sheet.
class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 86,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

/// "Last Updated: 5 mins" on the left, the live badge on the right.
class LastUpdatedRow extends StatelessWidget {
  const LastUpdatedRow({super.key, required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Text(
                  'Last Updated: ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  facility.lastUpdatedLabel,
                  style: AppTextStyles.statValue.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        LiveIndicator(isLive: facility.isLive),
      ],
    );
  }
}

/// The three-column capacity row, split by hairline dividers.
class CapacityRow extends StatelessWidget {
  const CapacityRow({super.key, required this.facility, required this.order});

  final Facility facility;
  final List<CapacityMetric> order;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < order.length; i++) ...<Widget>[
            if (i > 0)
              const VerticalDivider(
                width: AppSpacing.md,
                thickness: 1,
                color: AppColors.border,
              ),
            Expanded(child: _metric(order[i])),
          ],
        ],
      ),
    );
  }

  Widget _metric(CapacityMetric metric) => switch (metric) {
    CapacityMetric.currentPatients => InlineStat(
      icon: Icons.groups_outlined,
      label: 'Current Patients',
      value: '${facility.currentPatients}',
      axis: Axis.vertical,
    ),
    CapacityMetric.incoming => InlineStat(
      icon: Icons.person_add_alt,
      label: 'Incoming (Est.)',
      value: '${facility.incomingPatients}',
      iconColor: AppColors.primary,
      axis: Axis.vertical,
    ),
    CapacityMetric.totalBeds => InlineStat(
      icon: Icons.bed_outlined,
      label: 'Beds left',
      value: '${facility.totalBeds}/${facility.bedCapacity}',
      axis: Axis.vertical,
    ),
  };
}

enum CapacityMetric { currentPatients, incoming, totalBeds }

/// "WAIT 7 mins" beside "Emergencies 0".
class WaitAndEmergenciesRow extends StatelessWidget {
  const WaitAndEmergenciesRow({super.key, required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: InlineStat(
            icon: Icons.access_time,
            label: 'WAIT',
            value: facility.etaLabelForWait,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: InlineStat(
            icon: Icons.emergency_share_rounded,
            label: 'Emergencies',
            value: '${facility.emergencies}',
            iconColor: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

extension on Facility {
  String get etaLabelForWait => '$waitMinutes mins';
}

/// Header of the ranked overview: thumbnail, name, confidence and the
/// navigate shortcut.
class TopMatchHeader extends StatelessWidget {
  const TopMatchHeader({
    super.key,
    required this.recommendation,
    required this.onNavigate,
  });

  final FacilityRecommendation recommendation;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final Facility facility = recommendation.facility;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const _GlyphCard(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StatusBadge.match(label: recommendation.rank.label),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                facility.name,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2.copyWith(fontSize: 21),
              ),
              const SizedBox(height: AppSpacing.xxs),
              FacilityLoadBadge(load: facility.load),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Confidence Score', style: AppTextStyles.caption),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ConfidenceScore(
                  percent: recommendation.confidenceScore,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _TintedActionButton(
                icon: Icons.near_me_rounded,
                onTap: onNavigate,
                width: 96,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Header of the single-facility sheet: thumbnail, name, distance, and the
/// call / navigate pair.
class SelectedFacilityHeader extends StatelessWidget {
  const SelectedFacilityHeader({
    super.key,
    required this.facility,
    required this.onCall,
    required this.onNavigate,
  });

  final Facility facility;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _GlyphCard(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      facility.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(fontSize: 21),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (facility.isEmergencyCapable)
                    const StatusBadge.emergency()
                  else
                    FacilityLoadBadge(load: facility.load),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${facility.distanceLabel} away',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _TintedActionButton(icon: Icons.call, onTap: onCall),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TintedActionButton(
                      icon: Icons.near_me_rounded,
                      onTap: onNavigate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlyphCard extends StatelessWidget {
  const _GlyphCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        boxShadow: AppShadows.subtle,
      ),
      child: const HospitalGlyph(size: 66),
    );
  }
}

/// Soft blue square button carrying just an icon. Briefly disables itself
/// and shows a spinner after each tap so rapid double-taps can't fire the
/// same action (call, navigate) twice in a row.
class _TintedActionButton extends StatefulWidget {
  const _TintedActionButton({
    required this.icon,
    required this.onTap,
    this.width,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double? width;

  @override
  State<_TintedActionButton> createState() => _TintedActionButtonState();
}

class _TintedActionButtonState extends State<_TintedActionButton> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    widget.onTap();
    // Brief cooldown — long enough to block a double-tap, short enough that
    // a genuine second action (e.g. re-tapping Navigate later) isn't stuck.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: _busy ? null : _handleTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: widget.width,
          height: 60,
          child: _busy
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                )
              : Icon(widget.icon, size: 30, color: AppColors.primary),
        ),
      ),
    );
  }
}

/// A row in the "Recommended Facilities (3)" list.
class RankedFacilityTile extends StatelessWidget {
  const RankedFacilityTile({
    super.key,
    required this.recommendation,
    required this.rank,
    required this.onTap,
  });

  final FacilityRecommendation recommendation;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Facility facility = recommendation.facility;

    return AppCard(
      onTap: onTap,
      shadows: null,
      border: Border.all(color: AppColors.border),
      padding: const EdgeInsets.all(AppSpacing.xs),
      radius: AppRadius.sm,
      child: Row(
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: AppTextStyles.badge.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const HospitalGlyph(size: 54),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  facility.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                FacilityLoadBadge(load: facility.load),
                const SizedBox(height: 4),
                _CountsRow(facility: facility),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 74,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    facility.etaLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    facility.distanceLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary, size: 26),
        ],
      ),
    );
  }
}

class _CountsRow extends StatelessWidget {
  const _CountsRow({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    TextStyle style() =>
        AppTextStyles.body.copyWith(color: AppColors.textSecondary);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.groups_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 3),
          Text('${facility.currentPatients}', style: style()),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.person_add_alt, size: 16, color: AppColors.primary),
          const SizedBox(width: 3),
          Text('${facility.incomingPatients}', style: style()),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.emergency_share_rounded,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: 3),
          Text('${facility.emergencies}', style: style()),
        ],
      ),
    );
  }
}
