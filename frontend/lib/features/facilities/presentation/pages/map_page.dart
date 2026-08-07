import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../bloc/map_bloc.dart';
import '../widgets/facility_sheet.dart';
import '../widgets/map_canvas.dart';
import '../widgets/map_overlays.dart';

/// Live map of the recommended facilities with a draggable detail sheet.
class MapPage extends StatelessWidget {
  const MapPage({super.key, this.focusFacilityId});

  final String? focusFacilityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapBloc>(
      create: (_) =>
          sl<MapBloc>()..add(MapStarted(focusFacilityId: focusFacilityId)),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (BuildContext context, MapState state) {
          final Facility? pinned = state.pinnedFacility;

          return Stack(
            children: <Widget>[
          Positioned.fill(
            child: MapCanvas(
              facilities: state.recommendations.map((e) => e.facility).toList(),
              userPosition: state.userPosition,
              selectedFacilityId: pinned?.id,
              onMarkerTap: (Facility facility) =>
                  context.read<MapBloc>().add(MapFacilitySelected(facility.id)),
            ),
          ),
          _TopControls(state: state),
              if (state.status.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (state.status.isSuccess) _Sheet(state: state),
            ],
          );
        },
      ),
    );
  }

  /// Pin, callout, route pill and the user's own dot, placed as fractions of
  /// the viewport so they track the painted route.
  List<Widget> _mapMarkers(BuildContext context, Facility facility) {
    final Size size = MediaQuery.sizeOf(context);

    return <Widget>[
      Positioned(
        left: size.width * 0.20,
        top: size.height * 0.31,
        child: const FacilityPin(),
      ),
      Positioned(
        left: size.width * 0.20,
        top: size.height * 0.16,
        width: size.width * 0.52,
        child: FacilityCallout(facility: facility),
      ),
      Positioned(
        left: size.width * 0.30,
        top: size.height * 0.66,
        child: RoutePill(
          eta: facility.etaLabel,
          distance: facility.distanceLabel,
        ),
      ),
      Positioned(
        left: size.width * 0.70,
        top: size.height * 0.685,
        child: const UserLocationDot(),
      ),
    ];
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({required this.state});

  final MapState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MapCircleButton(
              icon: Icons.arrow_back,
              onTap: () => state.mode == MapViewMode.facility
                  ? context.read<MapBloc>().add(const MapOverviewRequested())
                  : context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.home),
            ),
            MapCircleButton(
              icon: Icons.my_location,
              onTap: () =>
                  context.read<MapBloc>().add(const MapOverviewRequested()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.state});

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final bool isOverview = state.mode == MapViewMode.overview;

    return DraggableScrollableSheet(
      initialChildSize: isOverview ? 0.58 : 0.42,
      minChildSize: 0.30,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            boxShadow: AppShadows.sheet,
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: isOverview
                ? _overviewChildren(context)
                : _facilityChildren(context),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------- overview

  List<Widget> _overviewChildren(BuildContext context) {
    final FacilityRecommendation? top = state.topMatch;
    if (top == null) return <Widget>[const SheetGrabber()];

    final Facility facility = top.facility;

    return <Widget>[
      const SheetGrabber(),
      const SizedBox(height: AppSpacing.xs),
      TopMatchHeader(
        recommendation: top,
        onNavigate: () =>
            context.read<MapBloc>().add(MapFacilitySelected(facility.id)),
      ),
      const SizedBox(height: AppSpacing.md),
      LastUpdatedRow(facility: facility),
      const Divider(height: AppSpacing.xl),
      CapacityRow(
        facility: facility,
        order: const <CapacityMetric>[
          CapacityMetric.currentPatients,
          CapacityMetric.incoming,
          CapacityMetric.totalBeds,
        ],
      ),
      const Divider(height: AppSpacing.xl),
      WaitAndEmergenciesRow(facility: facility),
      const SizedBox(height: AppSpacing.lg),
      Text(
        'Recommended Facilities (${state.recommendations.length})',
        style: AppTextStyles.h2.copyWith(fontSize: 21),
      ),
      const SizedBox(height: AppSpacing.sm),
      for (int i = 0; i < state.recommendations.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: RankedFacilityTile(
            recommendation: state.recommendations[i],
            rank: i + 1,
            onTap: () => context.read<MapBloc>().add(
              MapFacilitySelected(state.recommendations[i].facility.id),
            ),
          ),
        ),
    ];
  }

  // ----------------------------------------------------- single facility

  List<Widget> _facilityChildren(BuildContext context) {
    final FacilityRecommendation? selected = state.selected;
    if (selected == null) return <Widget>[const SheetGrabber()];

    final Facility facility = selected.facility;

    return <Widget>[
      const SheetGrabber(),
      const SizedBox(height: AppSpacing.xs),
      SelectedFacilityHeader(
        facility: facility,
        onCall: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Calling ${facility.name} — ${facility.phoneNumber}',
              ),
            ),
          ),
        onNavigate: () => context.push(AppRoutes.facilityDetail(facility.id)),
      ),
      const SizedBox(height: AppSpacing.md),
      LastUpdatedRow(facility: facility),
      const Divider(height: AppSpacing.xl),
      CapacityRow(
        facility: facility,
        order: const <CapacityMetric>[
          CapacityMetric.totalBeds,
          CapacityMetric.currentPatients,
          CapacityMetric.incoming,
        ],
      ),
      const Divider(height: AppSpacing.xl),
      WaitAndEmergenciesRow(facility: facility),
    ];
  }
}
