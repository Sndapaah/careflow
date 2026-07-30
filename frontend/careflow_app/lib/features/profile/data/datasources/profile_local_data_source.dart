import '../../domain/entities/patient_profile.dart';

abstract interface class ProfileLocalDataSource {
  Future<PatientProfile> read();

  Future<PatientProfile> write(PatientProfile profile);
}

/// Holds the profile in memory for the lifetime of the app. Replace with a
/// secure-storage or API-backed implementation without touching the bloc.
class ProfileInMemoryDataSource implements ProfileLocalDataSource {
  static const Duration _latency = Duration(milliseconds: 250);

  PatientProfile _profile = PatientProfile(
    patientId: 'CF-0113',
    fullName: 'Nana Sarpong',
    email: 'nanasarpong@gmail.com',
    phoneNumber: '+233 55 925 5742',
    dateOfBirth: DateTime(2004, 3, 26),
    gender: Gender.male,
    bloodType: 'O-',
    allergies: const <String>['Penicillin'],
    conditions: const <String>['Asthma'],
    emergencyContact: const EmergencyContact(
      fullName: 'Kingsley Hovor',
      relationship: 'Brother',
      phoneNumber: '+233 24 555 0199',
    ),
  );

  @override
  Future<PatientProfile> read() async {
    await Future<void>.delayed(_latency);
    return _profile;
  }

  @override
  Future<PatientProfile> write(PatientProfile profile) async {
    _profile = profile;
    return _profile;
  }
}
