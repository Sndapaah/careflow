import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/facility.dart';
import '../bloc/facility_detail_bloc.dart';

/// Full profile for a single facility: capacity, departments and services.
class FacilityDetailPage extends StatelessWidget {
  const FacilityDetailPage({super.key, required this.facilityId});

  final String facilityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacilityDetailBloc>(
      create: (_) =>
          sl<FacilityDetailBloc>()..add(FacilityDetailRequested(facilityId)),
      child: const _FacilityDetailView(),
    );
  }
}

class _FacilityDetailView extends StatelessWidget {
  const _FacilityDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<FacilityDetailBloc, FacilityDetailState>(
          builder: (BuildContext context, FacilityDetailState state) {
            final Facility? facility = state.facility;

            return Column(
              children: <Widget>[
                AppTopBar(
                  title: facility?.name ?? 'Facility',
                  centerTitle: true,
                ),
                Expanded(
                  child: facility == null
                      ? const Center(child: CircularProgressIndicator())
                      : _DetailBody(facility: facility),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: <Widget>[
        const _PhotoPlaceholder(),
        const SizedBox(height: AppSpacing.md),
        _HighlightChips(facility: facility),
        const SizedBox(height: AppSpacing.lg),
        Text('Facility Statistics', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: StatColumn(
                icon: Icons.groups_outlined,
                value: '${facility.patientCapacity}',
                label: 'Patient Capacity',
              ),
            ),
            Expanded(
              child: StatColumn(
                icon: Icons.person_outline,
                value: '${facility.staffCount}',
                label: 'Staff',
              ),
            ),
            Expanded(
              child: StatColumn(
                icon: Icons.bed_outlined,
                value: '${facility.totalBeds}',
                label: 'Total Beds',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (facility.isEmergencyCapable) const _EmergencyCapableBanner(),
        const SizedBox(height: AppSpacing.lg),
        Text('Departments', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (final String department in facility.departments)
              SoftTag(label: department),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Services', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        _ServicesGrid(services: facility.services),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Navigate',
          icon: Icons.near_me_outlined,
          height: 60,
          borderRadius: AppRadius.pill,
          onPressed: () => context.go(AppRoutes.mapFocused(facility.id)),
        ),
      ],
    );
  }
}

/// Stands in for the facility photograph until the media endpoint exists.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_rounded,
        size: 110,
        color: Color(0xFF15D2F5),
      ),
    );
  }
}

class _HighlightChips extends StatelessWidget {
  const _HighlightChips({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: OutlinedInfoChip(
            label: 'Top Match',
            icon: Icons.star_rounded,
            iconColor: AppColors.star,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: OutlinedInfoChip(
            label: facility.load.label,
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            labelColor: AppColors.successText,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: OutlinedInfoChip(
            label: facility.distanceLabel,
            icon: Icons.location_on,
            iconColor: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _EmergencyCapableBanner extends StatelessWidget {
  const _EmergencyCapableBanner();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.emergency_share_rounded,
              size: 20,
              color: AppColors.danger,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Emergency-Capable Facility',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-per-row white pills listing what the facility offers.
class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.services});

  final List<String> services;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth = (constraints.maxWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final String service in services)
              Container(
                width: itemWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: AppShadows.subtle,
                ),
                child: Text(
                  service,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
