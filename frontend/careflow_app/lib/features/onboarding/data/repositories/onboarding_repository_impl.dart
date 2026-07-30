import '../../../../core/error/failure.dart';
import '../../domain/entities/medical_profile_draft.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Accepts the draft and holds the last submission in memory. Swap for an
/// API-backed implementation when the profile endpoint is available.
class OnboardingRepositoryImpl implements OnboardingRepository {
  MedicalProfileDraft? lastSubmitted;

  @override
  Future<void> submit(MedicalProfileDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!draft.canAdvanceFrom(4)) {
      throw const ServerFailure('Please finish every step first.');
    }
    lastSubmitted = draft;
  }
}
