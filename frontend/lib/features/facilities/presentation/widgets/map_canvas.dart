import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../../core/services/directions_service.dart';
import '../../domain/entities/facility.dart';

/// Dark blue / navy map styling structure — removes busy components while
/// using dark slate, rich midnight blue geometry colors, and distinct accents.
const String _darkBlueMapStyle = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#1c2b46" }] },
  { "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#7488a1" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#1c2b46" }] },
  { "featureType": "administrative", "elementType": "geometry.stroke", "stylers": [{ "color": "#273a56" }] },
  { "featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [{ "color": "#647793" }] },
  { "featureType": "landscape.man_made", "elementType": "geometry.fill", "stylers": [{ "color": "#21324e" }] },
  { "featureType": "poi", "elementType": "geometry", "stylers": [{ "color": "#283d5a" }] },
  { "featureType": "poi.park", "elementType": "geometry.fill", "stylers": [{ "color": "#1b3d4a" }] },
  { "featureType": "road", "elementType": "geometry", "stylers": [{ "color": "#2c3e5d" }] },
  { "featureType": "road.arterial", "elementType": "geometry", "stylers": [{ "color": "#374c6d" }] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "color": "#182438" }] },
  { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{ "color": "#2c3e5d" }] },
  { "featureType": "transit", "elementType": "geometry", "stylers": [{ "color": "#2f476a" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#0e1626" }] }
]
''';

class MapCanvas extends StatefulWidget {
  const MapCanvas({
    super.key,
    required this.facilities,
    required this.userPosition,
    required this.directionsApiKey,
    required this.routeRequestId,
    required this.locationPermissionGranted,
    this.selectedFacilityId,
    this.onMarkerTap,
    this.onRouteResolved,
    this.onMapReady,
  });

  final List<Facility> facilities;
  final ll.LatLng userPosition;
  final String directionsApiKey;
  final int routeRequestId;
  final bool locationPermissionGranted;
  final String? selectedFacilityId;
  final ValueChanged<Facility>? onMarkerTap;
  final ValueChanged<RouteResult>? onRouteResolved;
  final ValueChanged<GoogleMapController>? onMapReady;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  GoogleMapController? _controller;
  late final DirectionsService _directions = DirectionsService(
    apiKey: widget.directionsApiKey,
  );

  List<LatLng> _routePoints = <LatLng>[];
  bool _loadingRoute = false;
  int _lastFetchedRequestId = -1;

  @override
  void initState() {
    super.initState();
    if (widget.selectedFacilityId != null) {
      _lastFetchedRequestId = widget.routeRequestId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRoute());
    }
  }

  @override
  void didUpdateWidget(covariant MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool positionChanged =
        oldWidget.userPosition.latitude != widget.userPosition.latitude ||
        oldWidget.userPosition.longitude != widget.userPosition.longitude;
    if (positionChanged && widget.selectedFacilityId == null) {
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.userPosition.latitude,
            widget.userPosition.longitude,
          ),
          15.5,
        ),
      );
    }
    // FIXED: Now checks routeRequestId tracking index changes to cleanly capture repeat navigation signals
    if (widget.selectedFacilityId != null &&
        widget.routeRequestId != _lastFetchedRequestId) {
      _lastFetchedRequestId = widget.routeRequestId;
      _fetchRoute();
    } else if (widget.selectedFacilityId == null &&
        oldWidget.selectedFacilityId != null) {
      // Clear route points immediately if selection is revoked or cleared by overview requests
      setState(() => _routePoints = <LatLng>[]);
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

    final ll.LatLng origin = ll.LatLng(
      widget.userPosition.latitude,
      widget.userPosition.longitude,
    );
    final ll.LatLng destination = ll.LatLng(
      facility.latitude,
      facility.longitude,
    );
    setState(() => _loadingRoute = true);
    final RouteResult? networkResult = await _directions.getRoute(
      origin: origin,
      destination: destination,
    );
    if (!mounted) return;

    // Never draw a straight origin-to-destination segment as a route. It is
    // geographically misleading and usually means the Directions API did
    // not return a valid road route (missing/invalid key, quota, or no route).
    final RouteResult? result = networkResult;
    if (result == null || result.points.length < 2) {
      setState(() {
        _loadingRoute = false;
        _routePoints = <LatLng>[];
      });
      return;
    }

    setState(() {
      _loadingRoute = false;
      _routePoints = result.points
          .map((ll.LatLng p) => LatLng(p.latitude, p.longitude))
          .toList();
    });

    widget.onRouteResolved?.call(result);
    _fitBounds(facility);
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

  BitmapDescriptor _markerIcon(bool isSelected) =>
      BitmapDescriptor.defaultMarkerWithHue(
        isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          style: _darkBlueMapStyle,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.userPosition.latitude,
              widget.userPosition.longitude,
            ),
            zoom: 15.5,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            widget.onMapReady?.call(controller);
          },
          myLocationEnabled: widget.locationPermissionGranted,
          myLocationButtonEnabled: false,
          markers: <Marker>{
            for (final Facility f in widget.facilities)
              Marker(
                markerId: MarkerId(f.id),
                position: LatLng(f.latitude, f.longitude),
                icon: _markerIcon(f.id == widget.selectedFacilityId),
                // FIXED: Enriched native window text strings with complete live telemetry parameters
                infoWindow: InfoWindow(
                  title: f.name,
                  snippet:
                      '${f.load.label} • ${f.currentPatients} patients • ${f.incomingPatients} incoming',
                ),
                onTap: () => widget.onMarkerTap?.call(f),
              ),
          },
          polylines: <Polyline>{
            if (_routePoints.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: const Color(0xFF00E5FF),
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
