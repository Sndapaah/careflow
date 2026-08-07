import '../../../../core/error/failure.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../domain/repositories/facility_repository.dart';
import '../datasources/facility_remote_data_source.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  const FacilityRepositoryImpl(this._remote);

  final FacilityRemoteDataSource _remote;

  @override
  Future<List<Facility>> getNearbyFacilities() async {
    try {
      return await _remote.fetchNearby();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('Could not load nearby facilities.');
    }
  }

  @override
  Future<List<FacilityRecommendation>> getRecommendations() async {
    try {
      return await _remote.fetchRecommendations();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('Could not load recommendations.');
    }
  }

  @override
  Future<FacilityRecommendation> getEmergencyMatch() async {
    try {
      return await _remote.fetchEmergencyMatch();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure('Could not find an emergency facility.');
    }
  }

  @override
  Future<Facility> getFacilityById(String id) async {
    try {
      return await _remote.fetchById(id);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const NotFoundFailure('That facility is no longer listed.');
    }
  }
}
