import '../../domain/entities/patient_profile.dart';

/// Boundary the profile repository talks to. Implemented by
/// [ProfileHttpDataSource], which reads the signed-in user from the session
/// cache and writes edits through the backend's personalization endpoint.
abstract interface class ProfileLocalDataSource {
  Future<PatientProfile> read();

  Future<PatientProfile> write(PatientProfile profile);
}
