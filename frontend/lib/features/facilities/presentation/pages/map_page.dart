import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/tab_activation_bus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../domain/repositories/facility_repository.dart';
import '../bloc/map_bloc.dart';
import '../../../../core/services/directions_service.dart';
import '../widgets/facility_sheet.dart';
import '../widgets/map_canvas.dart';
import '../widgets/map_overlays.dart';
import '../../../../core/utils/phone_launcher.dart';

const String _googleMapsApiKey = String.fromEnvironment(
  'MAPS_API_KEY',
  defaultValue: '',
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

class _MapViewState extends State<_MapView> with WidgetsBindingObserver {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  GoogleMapController? _mapController;
  bool _hasLocationPermission = true;
  bool _requestingLocation = false;
  bool _permissionPromptVisible = false;
  bool _isMapTabActive = true;
  StreamSubscription<int>? _tabActivationSubscription;
  String? _arrivalId;
  String? _arrivalFacilityId;
  Timer? _arrivalHeartbeat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLocationPermission(promptIfMissing: true);
    });
    _tabActivationSubscription = TabActivationBus.stream.listen((int index) {
      _isMapTabActive = index == 1;
      if (!_isMapTabActive) {
        _cancelTrackedArrival();
        return;
      }
      if (!mounted) return;
      context.read<MapBloc>().add(const MapOverviewRequested());
      _refreshLocationPermission(promptIfMissing: true);
    });
  }

  @override
  void dispose() {
    _cancelTrackedArrival();
    WidgetsBinding.instance.removeObserver(this);
    _tabActivationSubscription?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _trackArrival(RouteResult route) async {
    final facility = context.read<MapBloc>().state.pinnedFacility;
    if (facility == null || _arrivalId != null) return;
    try {
      final repository = sl<FacilityRepository>();
      final int etaMinutes = (route.durationSeconds / 60).round().clamp(1, 360);
      final Position position = await Geolocator.getCurrentPosition();
      _arrivalFacilityId = facility.id;
      _arrivalId = await repository.startArrival(
        facility.id,
        etaMinutes,
        position.latitude,
        position.longitude,
      );
      _arrivalHeartbeat = Timer.periodic(const Duration(minutes: 2), (_) async {
        final id = _arrivalId;
        if (id == null) return;
        try {
          final Position current = await Geolocator.getCurrentPosition();
          final double metresAway = Geolocator.distanceBetween(
            current.latitude,
            current.longitude,
            facility.latitude,
            facility.longitude,
          );
          if (metresAway <= 150) {
            await _cancelTrackedArrival();
            return;
          }
          await repository.heartbeatArrival(
            facility.id,
            id,
            etaMinutes,
            current.latitude,
            current.longitude,
          );
        } catch (_) {}
      });
    } catch (_) {
      _arrivalId = null;
    }
  }

  Future<void> _cancelTrackedArrival() async {
    _arrivalHeartbeat?.cancel();
    _arrivalHeartbeat = null;
    final id = _arrivalId;
    final facilityId = _arrivalFacilityId;
    _arrivalId = null;
    _arrivalFacilityId = null;
    if (id == null || facilityId == null) return;
    try {
      await sl<FacilityRepository>().cancelArrival(facilityId, id);
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isMapTabActive) {
      _refreshLocationPermission(promptIfMissing: true);
    }
  }

  Future<void> _refreshLocationPermission({
    bool promptIfMissing = false,
  }) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return;
    final bool granted =
        serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);
    setState(() {
      _hasLocationPermission = granted;
    });
    if (!granted && promptIfMissing) {
      await _showPermissionPrompt(serviceEnabled, permission);
    }
  }

  Future<void> _showPermissionPrompt(
    bool serviceEnabled,
    LocationPermission permission,
  ) async {
    if (!mounted || _permissionPromptVisible) return;
    _permissionPromptVisible = true;
    try {
      if (!serviceEnabled) {
        await _showLocationMessage(
          'Device location is turned off. Turn it on so CareFlow can find nearby care.',
          actionLabel: 'Open settings',
          onAction: Geolocator.openLocationSettings,
        );
      } else if (permission == LocationPermission.deniedForever) {
        await _showLocationMessage(
          'Location access is disabled for CareFlow. Enable it in app settings.',
          actionLabel: 'Open settings',
          onAction: Geolocator.openAppSettings,
        );
      } else {
        await _requestLocationPermission();
      }
    } finally {
      _permissionPromptVisible = false;
    }
  }

  Future<void> _requestLocationPermission() async {
    if (_requestingLocation) return;
    setState(() => _requestingLocation = true);

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        await _showLocationMessage(
          'Turn on device location services so CareFlow can find nearby care.',
          actionLabel: 'Open settings',
          onAction: Geolocator.openLocationSettings,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        await _showLocationMessage(
          'Location access is disabled for CareFlow. Enable it in app settings.',
          actionLabel: 'Open settings',
          onAction: Geolocator.openAppSettings,
        );
        return;
      }

      final bool granted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!mounted) return;
      setState(() => _hasLocationPermission = granted);
      if (granted) {
        context.read<MapBloc>().add(const MapStarted());
      }
    } finally {
      if (mounted) setState(() => _requestingLocation = false);
    }
  }

  Future<void> _showLocationMessage(
    String message, {
    required String actionLabel,
    required Future<bool> Function() onAction,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Location needed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await onAction();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  void _recenter(MapState state) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(state.userPosition.latitude, state.userPosition.longitude),
        15.5,
      ),
    );
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
                  // ADDED: Link the route sequence tracker from BLoC state
                  routeRequestId: state.routeRequestId,
                  locationPermissionGranted: _hasLocationPermission,
                  facilities: state.recommendations
                      .map((e) => e.facility)
                      .toList(),
                  userPosition: state.userPosition,
                  directionsApiKey: _googleMapsApiKey,
                  selectedFacilityId: state.mode == MapViewMode.facility
                      ? state.pinnedFacility?.id
                      : null,
                  onMarkerTap: (Facility facility) => context
                      .read<MapBloc>()
                      .add(MapFacilitySelected(facility.id)),
                  onRouteResolved: (RouteResult route) {
                    _trackArrival(route);
                    context.read<MapBloc>().add(
                      MapRouteResolved(
                        distanceLabel: route.distanceLabel,
                        durationLabel: route.durationLabel,
                      ),
                    );
                    onMapReady:
                    (GoogleMapController c) {
                      _mapController = c;
                    };
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
                const Positioned.fill(child: _MapLoadingOverlay()),

              if (state.status.isSuccess && state.sheetVisible)
                _Sheet(state: state, controller: _sheetController),

              if (!_hasLocationPermission)
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.xl,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            'CareFlow needs your location to show nearby facilities and directions.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FilledButton.icon(
                            onPressed: _requestingLocation
                                ? null
                                : _requestLocationPermission,
                            icon: _requestingLocation
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.location_on),
                            label: const Text('Allow location access'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MapLoadingOverlay extends StatelessWidget {
  const _MapLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CareFlowHoverLogo(size: 96),
            const SizedBox(height: AppSpacing.md),
            Text('Locating the best care nearby', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(
              width: 128,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ],
        ),
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
        onCall: () => PhoneLauncher.call(facility.phoneNumber),
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
