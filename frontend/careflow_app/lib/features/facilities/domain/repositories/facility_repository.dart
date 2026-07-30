import '../entities/facility.dart';
import '../entities/facility_recommendation.dart';

/// Contract the presentation layer depends on. Implemented in the data layer.
///
/// Every method throws a [Failure] on error rather than returning a wrapper,
/// so blocs handle exactly one error type.
abstract interface class FacilityRepository {
  /// Facilities close to the user, for the home strip.
  Future<List<Facility>> getNearbyFacilities();

  /// Ranked matches for the current symptom context.
  Future<List<FacilityRecommendation>> getRecommendations();

  /// The single best emergency-capable match.
  Future<FacilityRecommendation> getEmergencyMatch();

  Future<Facility> getFacilityById(String id);
}
