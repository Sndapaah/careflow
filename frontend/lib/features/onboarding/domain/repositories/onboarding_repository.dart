import '../entities/medical_profile_draft.dart';

abstract interface class OnboardingRepository {
  /// Sends the completed draft to the backend and marks onboarding done.
  Future<void> submit(MedicalProfileDraft draft);
}
