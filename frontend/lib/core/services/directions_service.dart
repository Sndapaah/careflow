import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final int durationSeconds;

  String get distanceLabel =>
      '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  String get durationLabel {
    final int minutes = (durationSeconds / 60).round();
    return '$minutes mins';
  }
}

class DirectionsService {
  const DirectionsService({required this.apiKey});

  final String apiKey;

  Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      <String, String>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': apiKey,
      },
    );

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'OK') return null;

    final List<dynamic> routes = json['routes'] as List<dynamic>;
    if (routes.isEmpty) return null;

    final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
    final List<dynamic> legs = route['legs'] as List<dynamic>;
    final Map<String, dynamic> leg = legs.first as Map<String, dynamic>;

    final String encodedPolyline =
        (route['overview_polyline'] as Map<String, dynamic>)['points']
            as String;

    return RouteResult(
      points: _decodePolyline(encodedPolyline),
      distanceMeters:
          ((leg['distance'] as Map<String, dynamic>)['value'] as num)
              .toDouble(),
      durationSeconds:
          (leg['duration'] as Map<String, dynamic>)['value'] as int,
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
