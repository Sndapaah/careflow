import '../../features/facilities/domain/entities/facility_recommendation.dart';

/// Bridges Diagnosis and Facilities: /diagnose already returns ranked
/// hospitals for the symptoms just analyzed, so Facilities reads from here
/// instead of re-querying with less context.
class LastDiagnosisCache {
  List<FacilityRecommendation>? _recommendations;
  DateTime? _fetchedAt;

  static const Duration _freshFor = Duration(minutes: 10);

  void store(List<FacilityRecommendation> recommendations) {
    _recommendations = recommendations;
    _fetchedAt = DateTime.now();
  }

  List<FacilityRecommendation>? get fresh {
    if (_recommendations == null || _fetchedAt == null) return null;
    if (DateTime.now().difference(_fetchedAt!) > _freshFor) return null;
    return _recommendations;
  }

  void clear() {
    _recommendations = null;
    _fetchedAt = null;
  }
}