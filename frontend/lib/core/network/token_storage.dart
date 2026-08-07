import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT and the signed-in user's ID so any repository can look
/// up "who's logged in right now" without threading it through every bloc.
class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'careflow_access_token';
  static const String _userIdKey = 'careflow_user_id';

  Future<void> save(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }
}