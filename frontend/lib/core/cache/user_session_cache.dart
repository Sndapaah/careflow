/// Holds the signed-in user's raw backend fields in memory, refreshed at
/// login and patched after onboarding submits. Profile reads from here
/// until the backend exposes a proper GET /profile endpoint.
class UserSessionCache {
  Map<String, dynamic>? _user;

  void store(Map<String, dynamic> user) {
    _user = Map<String, dynamic>.from(user);
  }

  /// Merges new fields into whatever's cached (e.g. after addPersonalization,
  /// which only returns a success message, not the updated document).
  void patch(Map<String, dynamic> fields) {
    _user = <String, dynamic>{...?_user, ...fields};
  }

  Map<String, dynamic>? get current => _user;

  void clear() => _user = null;
}