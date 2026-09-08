import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for the backend's base URL.
///
/// Flip [_targetingEmulator] depending on what you're running against:
/// - true  → Android emulator (uses the 10.0.2.2 loopback alias)
/// - false → physical device on the same Wi-Fi as this machine (uses your LAN IP)
abstract final class ApiConfig {
  /// Override this for release builds with the deployed HTTPS API URL.
  /// Example: --dart-define=CAREFLOW_API_URL=https://api.example.com/api
  static const String _configuredBaseUrl = String.fromEnvironment(
    'CAREFLOW_API_URL',
    defaultValue: '',
  );
  static const bool _targetingEmulator = bool.fromEnvironment(
    'CAREFLOW_TARGETING_EMULATOR',
    defaultValue: false,
  );

  static const String _localLanIp = String.fromEnvironment(
    'CAREFLOW_LOCAL_IP',
    defaultValue: '192.168.120.241',
  );
  // Accept the name used by the documented flutter run command.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: String.fromEnvironment('MAPS_API_KEY'),
  );
  // Use the device GPS by default. Pass
  // --dart-define=CAREFLOW_DEMO_MODE=true for a repeatable demo origin.
  static const bool demoMode = bool.fromEnvironment(
    'CAREFLOW_DEMO_MODE',
    defaultValue: false,
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
  static const String _demoLatitude = String.fromEnvironment(
    'CAREFLOW_DEMO_LAT',
    defaultValue: '6.673187230173344',
  );
  static const String _demoLongitude = String.fromEnvironment(
    'CAREFLOW_DEMO_LNG',
    defaultValue: '-1.5671027830475017',
  );
  static double get demoLatitude =>
      double.tryParse(_demoLatitude) ?? 6.673187230173344;
  static double get demoLongitude =>
      double.tryParse(_demoLongitude) ?? -1.5671027830475017;
  static const int port = 5000;

  static String get baseUrl {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return _configuredBaseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    }
    if (kIsWeb) return 'http://localhost:$port/api';

    if (Platform.isAndroid && _targetingEmulator) {
      return 'http://10.0.2.2:$port/api';
    }

    return 'http://$_localLanIp:$port/api';
  }
}
