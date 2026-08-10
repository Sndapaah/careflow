//import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for the backend's base URL.
///
/// - Web: localhost works directly.
/// - Android emulator: needs the special alias 10.0.2.2 — "localhost" on an
///   emulator refers to the emulator itself, not your host machine.
/// - iOS simulator: localhost works directly.
/// - Physical device (Android or iOS): needs your machine's actual LAN IP,
///   since the phone is a separate device on the same network, not able to
///   reach "localhost" or the emulator-only 10.0.2.2 alias.
///
/// Currently pinned to physical-device testing via [_localLanIp]. Swap the
/// `Platform.isAndroid` branch back in (and update the IP as needed) when
/// testing on the emulator again.
abstract final class ApiConfig {
  static const String _localLanIp = '192.168.37.241';
  static const int port = 5000;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$port/api';
    return 'http://$_localLanIp:$port/api';
  }
}
