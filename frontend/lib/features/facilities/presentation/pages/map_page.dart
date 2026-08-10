import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../bloc/map_bloc.dart';
import '../../../../core/services/directions_service.dart';
import '../widgets/facility_sheet.dart';
import '../widgets/map_canvas.dart';
import '../widgets/map_overlays.dart';

const String _googleMapsApiKey = String.fromEnvironment(
  'MAPS_API_KEY',
  defaultValue: 'AIzaSyAHUn48fku0AgMHD1hhDDDBvGTV1qSZDN0',
);

const double _sheetPeekSize = 0.20;

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

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  GoogleMapController? _mapController;

  void _recenter(MapState state) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(state.userPosition.latitude, state.userPosition.longitude),
        15.5,
      ),
    );
    context.read<MapBloc>().add(const MapOverviewRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<MapBloc, MapState>(
        builder: (BuildContext context, MapState state) {
          // FIXED STACK STRATEGY: Forcing StackFit.expand locks the background child bounds
          // in place, stopping the platform views engine from collapsing to h:180
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Map canvas fills background canvas dimensions completely
              Positioned.fill(
                child: MapCanvas(
                  facilities: state.recommendations
                      .map((e) => e.facility)
                      .toList(),
                  userPosition: state.userPosition,
                  directionsApiKey: _googleMapsApiKey,
                  selectedFacilityId: state.sheetVisible
                      ? state.pinnedFacility?.id
                      : null,
                  onMarkerTap: (Facility facility) => context
                      .read<MapBloc>()
                      .add(MapFacilitySelected(facility.id)),
                  onRouteResolved: (RouteResult route) =>
                      context.read<MapBloc>().add(
                        MapRouteResolved(
                          distanceLabel: route.distanceLabel,
                          durationLabel: route.durationLabel,
                        ),
                      ),
                  onMapReady: (GoogleMapController c) {
                    _mapController = c;
                  },
                ),
              ),

              // Top control floating widgets layer over map
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopControls(
                  state: state,
                  onRecenter: () => _recenter(state),
                ),
              ),

              if (state.status.isLoading)
                const Center(child: CircularProgressIndicator()),

              if (state.status.isSuccess && state.sheetVisible)
                _Sheet(state: state, controller: _sheetController),
            ],
          );
        },
      ),
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({required this.state, required this.onRecenter});

  final MapState state;
  final VoidCallback onRecenter;

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
            MapCircleButton(icon: Icons.my_location, onTap: onRecenter),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.state, required this.controller});

  final MapState state;
  final DraggableScrollableController controller;

  @override
  Widget build(BuildContext context) {
    final bool isOverview = state.mode == MapViewMode.overview;

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: isOverview ? 0.58 : 0.42,
      minChildSize: _sheetPeekSize,
      maxChildSize: 0.92,
      snap: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            boxShadow: AppShadows.sheet,
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
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
    final bool hasRouteResolved =
        state.routeDistanceLabel != null && state.routeDurationLabel != null;

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
        onNavigate: () => controller.animateTo(
          _sheetPeekSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ),

      if (hasRouteResolved) ...<Widget>[
        const SizedBox(height: AppSpacing.xs),
        _RouteEtaBanner(
          distance: state.routeDistanceLabel!,
          duration: state.routeDurationLabel!,
        ),
      ],

      if (!hasRouteResolved) ...<Widget>[
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
      ],
    ];
  }
}

// ----------------------------------------------------------- components

class _RouteEtaBanner extends StatelessWidget {
  const _RouteEtaBanner({required this.distance, required this.duration});
  final String distance;
  final String duration;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_filled,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$duration • $distance by road',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
