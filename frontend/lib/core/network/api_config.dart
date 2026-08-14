import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for the backend's base URL.
///
/// Flip [_targetingEmulator] depending on what you're running against:
/// - true  → Android emulator (uses the 10.0.2.2 loopback alias)
/// - false → physical device on the same Wi-Fi as this machine (uses your LAN IP)
abstract final class ApiConfig {
  static const bool _targetingEmulator = true; // ← flip this per session

  static const String _localLanIp = '192.168.16.241';
  static const int port = 5000;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$port/api';

    if (Platform.isAndroid && _targetingEmulator) {
      return 'http://10.0.2.2:$port/api';
    }

    return 'http://$_localLanIp:$port/api';
  }
}
