import '../../../../core/usecases/usecase.dart';
import '../entities/facility.dart';
import '../entities/facility_recommendation.dart';
import '../repositories/facility_repository.dart';

class GetNearbyFacilities implements UseCase<List<Facility>, NoParams> {
  const GetNearbyFacilities(this._repository);

  final FacilityRepository _repository;

  @override
  Future<List<Facility>> call(NoParams params) =>
      _repository.getNearbyFacilities();
}

class GetRecommendations
    implements UseCase<List<FacilityRecommendation>, NoParams> {
  const GetRecommendations(this._repository);

  final FacilityRepository _repository;

  @override
  Future<List<FacilityRecommendation>> call(NoParams params) =>
      _repository.getRecommendations();
}

class GetEmergencyMatch implements UseCase<FacilityRecommendation, NoParams> {
  const GetEmergencyMatch(this._repository);

  final FacilityRepository _repository;

  @override
  Future<FacilityRecommendation> call(NoParams params) =>
      _repository.getEmergencyMatch();
}

class GetFacilityById implements UseCase<Facility, String> {
  const GetFacilityById(this._repository);

  final FacilityRepository _repository;

  @override
  Future<Facility> call(String params) => _repository.getFacilityById(params);
}
