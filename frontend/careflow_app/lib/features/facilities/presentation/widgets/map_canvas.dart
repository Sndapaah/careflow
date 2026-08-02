import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/facility.dart';

class MapCanvas extends StatefulWidget {
  const MapCanvas({super.key, required this.facilities, required this.userPosition});

  final List<Facility> facilities;
  final LatLng userPosition;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final MapController _controller = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.userPosition,
        initialZoom: 14,
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.careflow.app', // required by OSM's usage policy
        ),
        MarkerLayer(
          markers: <Marker>[
            Marker(
              point: widget.userPosition,
              width: 24,
              height: 24,
              child: const _UserDot(),
            ),
            for (final Facility f in widget.facilities)
              Marker(
                point: LatLng(f.latitude, f.longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.local_hospital, color: Colors.red),
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
      ),
    );
  }
}