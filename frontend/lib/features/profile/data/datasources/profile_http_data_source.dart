import '../../../../core/cache/user_session_cache.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/patient_profile.dart';
import 'profile_local_data_source.dart';

class ProfileHttpDataSource implements ProfileLocalDataSource {
  ProfileHttpDataSource({
    required UserSessionCache sessionCache,
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _cache = sessionCache,
        _api = apiClient,
        _tokenStorage = tokenStorage;

  final UserSessionCache _cache;
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  @override
  Future<PatientProfile> read() async {
    final Map<String, dynamic>? user = _cache.current;
    if (user == null) {
      throw const CacheFailure('Not signed in yet.');
    }

    DateTime dateOfBirth;
    try {
      dateOfBirth = DateTime.parse(user['birthdate'] as String);
    } catch (_) {
      dateOfBirth = DateTime(2000, 1, 1); // fallback if not yet onboarded
    }

    final Map<String, dynamic>? contact =
        user['emergencyContact'] as Map<String, dynamic>?;

    return PatientProfile(
      patientId: (user['_id'] ?? '').toString(),
      fullName: (user['fullname'] as String?) ?? '',
      email: (user['email'] as String?) ?? '',
      phoneNumber: (user['contact'] as String?) ?? '',
      dateOfBirth: dateOfBirth,
      gender: (user['gender'] as String?) == 'female'
          ? Gender.female
          : Gender.male,
      bloodType: (user['bloodType'] as String?) ?? '',
      allergies: (user['allergies'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      conditions: (user['existingHealthConds'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      emergencyContact: EmergencyContact(
        fullName: (contact?['fullname'] as String?) ?? '',
        relationship: (contact?['relType'] as String?) ?? '',
        phoneNumber: (contact?['contact'] as String?) ?? '',
      ),
    );
  }

  @override
  Future<PatientProfile> write(PatientProfile profile) async {
    final String? userId = await _tokenStorage.readUserId();
    if (userId == null) {
      throw const AuthFailure('You need to be signed in to continue.');
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'gender': profile.gender.name,
      'birthdate': profile.dateOfBirth.toIso8601String(),
      'emergencyContact': <String, dynamic>{
        'fullname': profile.emergencyContact.fullName,
        'relType': profile.emergencyContact.relationship,
        'contact': profile.emergencyContact.phoneNumber,
      },
      'existingHealthConds': profile.conditions,
      'allergies': profile.allergies,
      'bloodType': profile.bloodType,
    };

    await _api.post(
      '/auth/addPersonalization/$userId',
      authenticated: true,
      body: body,
    );

    // Notification/emergency-alert toggles are UI-only preferences right
    // now — no backend field for them yet. Store locally on the cache only.
    _cache.patch(<String, dynamic>{
      ...body,
      '_notificationsEnabledLocalOnly': profile.notificationsEnabled,
      '_emergencyAlertsEnabledLocalOnly': profile.emergencyAlertsEnabled,
    });

    return profile;
  }
}
