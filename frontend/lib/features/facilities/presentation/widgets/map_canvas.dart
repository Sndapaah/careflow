import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../../core/services/directions_service.dart';
import '../../domain/entities/facility.dart';
import 'package:geolocator/geolocator.dart';

/// Light, low-saturation map style — carries over the CartoDB "light_all"
/// look from the flutter_map version, since Google's default styling is
/// busier/more saturated by comparison.
const String _lightMapStyle = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#f5f5f5" }] },
  { "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#616161" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#f5f5f5" }] },
  { "featureType": "road", "elementType": "geometry", "stylers": [{ "color": "#ffffff" }] },
  { "featureType": "road.arterial", "elementType": "geometry", "stylers": [{ "color": "#ffffff" }] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "color": "#dadada" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#c9c9c9" }] },
  { "featureType": "poi", "elementType": "geometry", "stylers": [{ "color": "#eeeeee" }] },
  { "featureType": "poi.park", "elementType": "geometry", "stylers": [{ "color": "#e5e5e5" }] }
]
''';

class MapCanvas extends StatefulWidget {
  const MapCanvas({
    super.key,
    required this.facilities,
    required this.userPosition,
    required this.directionsApiKey,
    this.selectedFacilityId,
    this.onMarkerTap,
    this.onRouteResolved,
    this.onMapReady,
  });

  final List<Facility> facilities;
  final ll.LatLng userPosition;
  final String directionsApiKey;
  final String? selectedFacilityId;
  final ValueChanged<Facility>? onMarkerTap;
  final ValueChanged<RouteResult>? onRouteResolved;
  final ValueChanged<GoogleMapController>? onMapReady;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  GoogleMapController? _controller;
  late final DirectionsService _directions =
      DirectionsService(apiKey: widget.directionsApiKey);

  List<LatLng> _routePoints = <LatLng>[];
  bool _loadingRoute = false;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    // Handles arriving already pre-focused on a facility (e.g. via a
    // recommendation) — didUpdateWidget never fires in that case since
    // there's no prior value to compare against on the very first build.
    if (widget.selectedFacilityId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRoute());
    }
  }

  Future<void> _checkPermission() async { 
    final LocationPermission permission = await Geolocator.checkPermission();
    final bool granted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (mounted) setState(() => _hasLocationPermission = granted);
  }

  @override
  void didUpdateWidget(covariant MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // FIXED: Trigger route updates if the selected facility changes, 
    // OR if the user position changes (moving away from uninitialized fallbacks)
    if (widget.selectedFacilityId != oldWidget.selectedFacilityId || 
        widget.userPosition != oldWidget.userPosition) {
      _fetchRoute();
    }
  }

  Facility? get _selected {
    final String? id = widget.selectedFacilityId;
    if (id == null) return null;
    for (final Facility f in widget.facilities) {
      if (f.id == id) return f;
    }
    return null;
  }

  Future<void> _fetchRoute() async {
    final Facility? facility = _selected;
    if (facility == null) {
      setState(() => _routePoints = <LatLng>[]);
      return;
    }

    // FIXED GUARD: Guard routing math if the location position is matching uninitialized defaults
    if (widget.userPosition.latitude == 6.6885 && widget.userPosition.longitude == -1.6244) {
      return;
    }

    setState(() => _loadingRoute = true);
    final RouteResult? result = await _directions.getRoute(
      origin: ll.LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
      destination: ll.LatLng(facility.latitude, facility.longitude),
    );
    if (!mounted) return;

    setState(() {
      _loadingRoute = false;
      _routePoints = result == null
          ? <LatLng>[]
          : result.points.map((ll.LatLng p) => LatLng(p.latitude, p.longitude)).toList();
    });

    if (result != null) {
      widget.onRouteResolved?.call(result);
      _fitBounds(facility);
    }
  }

  void _fitBounds(Facility facility) {
    final GoogleMapController? controller = _controller;
    if (controller == null) return;

    try {
      final double south = widget.userPosition.latitude < facility.latitude
          ? widget.userPosition.latitude
          : facility.latitude;
      final double north = widget.userPosition.latitude > facility.latitude
          ? widget.userPosition.latitude
          : facility.latitude;
      final double west = widget.userPosition.longitude < facility.longitude
          ? widget.userPosition.longitude
          : facility.longitude;
      final double east = widget.userPosition.longitude > facility.longitude
          ? widget.userPosition.longitude
          : facility.longitude;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west), 
            northeast: LatLng(north, east),
          ),
          80, 
        ),
      );
    } catch (e) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(facility.latitude, facility.longitude),
          14.0,
        ),
      );
    }
  }

  BitmapDescriptor _markerIcon(bool isSelected) => BitmapDescriptor.defaultMarkerWithHue(
        isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          //style: _lightMapStyle,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
            zoom: 15.5,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            // FIXED: Restored communication callback channel to feed page layouts cleanly
            widget.onMapReady?.call(controller);
          },
          myLocationEnabled: _hasLocationPermission, 
          myLocationButtonEnabled: false,
          markers: <Marker>{
            for (final Facility f in widget.facilities)
              Marker(
                markerId: MarkerId(f.id),
                position: LatLng(f.latitude, f.longitude),
                icon: _markerIcon(f.id == widget.selectedFacilityId),
                infoWindow: InfoWindow(title: f.name),
                onTap: () => widget.onMarkerTap?.call(f),
              ),
          },
          polylines: <Polyline>{
            if (_routePoints.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: const Color(0xFF2F6FED),
                width: 5,
              ),
          },
        ),
        if (_loadingRoute)
          const Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
      ],
    );
  }
}
