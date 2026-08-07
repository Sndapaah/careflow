import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/facility.dart';

class MapCanvas extends StatefulWidget {
  const MapCanvas({
    super.key,
    required this.facilities,
    required this.userPosition,
    this.selectedFacilityId,
    this.onMarkerTap,
  });

  final List<Facility> facilities;
  final LatLng userPosition;

  /// Highlights this facility's marker and draws the route line to it.
  final String? selectedFacilityId;

  final ValueChanged<Facility>? onMarkerTap;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final MapController _controller = MapController();

  @override
  void didUpdateWidget(covariant MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the camera framing both the user and the newly selected facility.
    if (widget.selectedFacilityId != oldWidget.selectedFacilityId) {
      _focusOnSelection();
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

  void _focusOnSelection() {
    final Facility? facility = _selected;
    if (facility == null) return;

    final LatLngBounds bounds = LatLngBounds.fromPoints(<LatLng>[
      widget.userPosition,
      LatLng(facility.latitude, facility.longitude),
    ]);

    _controller.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(60, 140, 60, 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Facility? selected = _selected;

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.userPosition,
        initialZoom: 15.5,
        minZoom: 11,
        maxZoom: 19,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: <Widget>[
        TileLayer(
  urlTemplate:
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
        subdomains: const ['a', 'b', 'c', 'd'],
        userAgentPackageName: 'com.careflow.app',
      ),
    // TileLayer(
    // urlTemplate:
    //     'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    //       subdomains: const ['a', 'b', 'c', 'd'],
    //       userAgentPackageName: 'com.careflow.app',
    //     ),
        // Straight-line route to the selected facility. Swap this for a
        // real routed polyline (OSRM or Google Directions) once available —
        // everything else here stays the same.
        if (selected != null)
          PolylineLayer(
            polylines: <Polyline>[
              Polyline(
                points: <LatLng>[
                  widget.userPosition,
                  LatLng(selected.latitude, selected.longitude),
                ],
                strokeWidth: 4,
                color: const Color(0xFF2F6FED),
                pattern: const StrokePattern.dotted(),
              ),
            ],
          ),
        MarkerLayer(
          markers: <Marker>[
            Marker(
              point: widget.userPosition,
              width: 26,
              height: 26,
              child: const _UserDot(),
            ),
            for (final Facility f in widget.facilities)
              Marker(
                point: LatLng(f.latitude, f.longitude),
                width: f.id == widget.selectedFacilityId ? 52 : 40,
                height: f.id == widget.selectedFacilityId ? 52 : 40,
                child: GestureDetector(
                  onTap: () => widget.onMarkerTap?.call(f),
                  child: _FacilityMarker(
                    isSelected: f.id == widget.selectedFacilityId,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
    );
  }
}

class _FacilityMarker extends StatelessWidget {
  const _FacilityMarker({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.local_hospital,
      color: isSelected ? const Color(0xFF2F6FED) : Colors.red,
      size: isSelected ? 44 : 34,
      shadows: const <Shadow>[
        Shadow(color: Colors.black38, blurRadius: 3),
      ],
    );
  }
}