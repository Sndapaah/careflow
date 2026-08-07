import 'package:geolocator/geolocator.dart';

/// Single place every repository asks for "where is the user right now".
/// Falls back to KNUST's coordinates if a fix can't be obtained quickly.
class CurrentLocationProvider {
  const CurrentLocationProvider();

  static const double _fallbackLat = 6.6885;
  static const double _fallbackLng = -1.6244;

  Future<(double lat, double lng)> getCurrent() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return (_fallbackLat, _fallbackLng);
    }
  }
}