import 'package:geolocator/geolocator.dart';

import '../error/failure.dart';

/// Single place every repository asks for "where is the user right now".
class CurrentLocationProvider {
  const CurrentLocationProvider();

  Future<(double lat, double lng)> getCurrent() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationFailure('Location services are turned off.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw const LocationFailure('Location permission was not granted.');
      }
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 30),
        ),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      throw const LocationFailure(
        'Your device has not provided a location yet. Check location services and try again.',
      );
    }
  }
}
