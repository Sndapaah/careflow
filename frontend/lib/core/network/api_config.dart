import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for the backend's base URL. Android emulator can't reach
/// "localhost" (that's the emulator's own loopback, not your machine), so it
/// needs the special alias 10.0.2.2. iOS simulator can use localhost as-is.
/// A physical device needs your machine's LAN IP — replace the placeholder
/// below with it (e.g. 192.168.1.42) when testing on real hardware.
abstract final class ApiConfig {
  static const String _physicalDeviceHost = '192.168.1.XXX'; // TODO: your LAN IP
  static const int port = 5000;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://$_physicalDeviceHost:$port/api'; // iOS sim + physical devices
  }
}