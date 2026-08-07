import '../../../../core/error/failure.dart';
import '../../domain/entities/medical_profile_draft.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../../auth/data/datasources/onboarding_remote_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._remote);

  final OnboardingRemoteDataSource _remote;

  @override
  Future<void> submit(MedicalProfileDraft draft) async {
    try {
      await _remote.submit(draft);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('Could not save your profile.');
    }
  }
}