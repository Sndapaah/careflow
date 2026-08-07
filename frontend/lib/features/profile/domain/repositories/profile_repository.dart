import '../entities/patient_profile.dart';

abstract interface class ProfileRepository {
  Future<PatientProfile> getProfile();

  Future<PatientProfile> setNotificationsEnabled(bool enabled);

  Future<PatientProfile> setEmergencyAlertsEnabled(bool enabled);

  /// Persists edits made on the Edit Profile screen.
  Future<PatientProfile> updateProfile(PatientProfile updated);
}
