import '../../../../core/error/failure.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._local);

  final ProfileLocalDataSource _local;

  @override
  Future<PatientProfile> getProfile() async {
    try {
      return await _local.read();
    } catch (_) {
      throw const CacheFailure('Could not load your profile.');
    }
  }

  @override
  Future<PatientProfile> setNotificationsEnabled(bool enabled) async {
    final PatientProfile current = await getProfile();
    return _local.write(current.copyWith(notificationsEnabled: enabled));
  }

  @override
  Future<PatientProfile> setEmergencyAlertsEnabled(bool enabled) async {
    final PatientProfile current = await getProfile();
    return _local.write(current.copyWith(emergencyAlertsEnabled: enabled));
  }
}
