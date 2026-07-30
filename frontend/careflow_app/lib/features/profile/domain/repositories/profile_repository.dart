import '../entities/patient_profile.dart';

abstract interface class ProfileRepository {
  Future<PatientProfile> getProfile();

  /// Persists a settings toggle and returns the updated profile.
  Future<PatientProfile> setNotificationsEnabled(bool enabled);

  Future<PatientProfile> setEmergencyAlertsEnabled(bool enabled);
}
