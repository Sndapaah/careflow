import '../../../../core/usecases/usecase.dart';
import '../entities/medical_profile_draft.dart';
import '../repositories/onboarding_repository.dart';

class SubmitMedicalProfile implements UseCase<void, MedicalProfileDraft> {
  const SubmitMedicalProfile(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(MedicalProfileDraft params) => _repository.submit(params);
}
