import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Persists the JWT and the signed-in user's ID so any repository can look
/// up "who's logged in right now" without threading it through every bloc.
class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'careflow_access_token';
  static const String _userIdKey = 'careflow_user_id';
  static const String _userKey = 'careflow_user';
  static const String _mapStateKey = 'careflow_map_state';

  Future<void> save(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  Future<Map<String, dynamic>?> readUser() async {
    final String? raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<void> saveMapState(double latitude, double longitude, String? selectedId) =>
      _storage.write(key: _mapStateKey, value: jsonEncode(<String, dynamic>{'latitude': latitude, 'longitude': longitude, 'selectedId': selectedId}));

  Future<Map<String, dynamic>?> readMapState() async {
    final String? raw = await _storage.read(key: _mapStateKey);
    if (raw == null || raw.isEmpty) return null;
    try { return Map<String, dynamic>.from(jsonDecode(raw) as Map); } catch (_) { return null; }
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _mapStateKey);
  }
}
