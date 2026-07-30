import '../../../../core/usecases/usecase.dart';
import '../entities/patient_profile.dart';
import '../repositories/profile_repository.dart';

class GetPatientProfile implements UseCase<PatientProfile, NoParams> {
  const GetPatientProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<PatientProfile> call(NoParams params) => _repository.getProfile();
}

class SetNotificationsEnabled implements UseCase<PatientProfile, bool> {
  const SetNotificationsEnabled(this._repository);

  final ProfileRepository _repository;

  @override
  Future<PatientProfile> call(bool params) =>
      _repository.setNotificationsEnabled(params);
}

class SetEmergencyAlertsEnabled implements UseCase<PatientProfile, bool> {
  const SetEmergencyAlertsEnabled(this._repository);

  final ProfileRepository _repository;

  @override
  Future<PatientProfile> call(bool params) =>
      _repository.setEmergencyAlertsEnabled(params);
}
