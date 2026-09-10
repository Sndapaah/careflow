import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../../../../core/cache/last_diagnosis_cache.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/location/current_location_provider.dart';
import '../../../../core/network/api_client.dart';
import '../models/facility_model.dart';
import 'package:geolocator/geolocator.dart';

/// Boundary the repository talks to. The HTTP implementation below hits the
/// CareFlow backend's /hospitals/recommend endpoint.
abstract interface class FacilityRemoteDataSource {
  Future<List<FacilityModel>> fetchNearby();
  Future<List<FacilityRecommendation>> fetchRecommendations();
  Future<FacilityRecommendation> fetchEmergencyMatch();
  Future<FacilityModel> fetchById(String id);
  Future<String> startArrival(String facilityId, int etaMinutes, double latitude, double longitude);
  Future<void> heartbeatArrival(String facilityId, String arrivalId, int etaMinutes, double latitude, double longitude);
  Future<void> cancelArrival(String facilityId, String arrivalId);
}

class FacilityHttpDataSource implements FacilityRemoteDataSource {
  FacilityHttpDataSource({
    required ApiClient apiClient,
    required CurrentLocationProvider locationProvider,
    required LastDiagnosisCache diagnosisCache,
  }) : _api = apiClient,
       _location = locationProvider,
       _cache = diagnosisCache;

  final ApiClient _api;
  final CurrentLocationProvider _location;
  final LastDiagnosisCache _cache;

  Future<List<Map<String, dynamic>>> _recommend({
    List<String> specialties = const <String>[],
    String urgency = 'routine',
    bool includeAll = false,
    int resultLimit = 3,
  }) async {
    final (double lat, double lng) = await _location.getCurrent();
    if (includeAll) {
      final Map<String, dynamic> json = await _api.get('/hospitals/getHs');
      final List<Map<String, dynamic>> hospitals =
          (json['hospitals'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();
      for (final Map<String, dynamic> hospital in hospitals) {
        final Map<String, dynamic>? location = hospital['location'] as Map<String, dynamic>?;
        final List<dynamic> coordinates = location?['coordinates'] as List<dynamic>? ?? const <dynamic>[];
        if (coordinates.length >= 2) {
          hospital['distance'] = Geolocator.distanceBetween(
            lat, lng, (coordinates[1] as num).toDouble(), (coordinates[0] as num).toDouble(),
          ) / 1000;
        }
      }
      hospitals.sort((a, b) => (a['distance'] as num? ?? double.infinity).compareTo(b['distance'] as num? ?? double.infinity));
      return hospitals.take(resultLimit).toList();
    }
    final Map<String, dynamic> json = await _api.post(
      '/hospitals/recommend',
      body: <String, dynamic>{
        'latitude': lat,
        'longitude': lng,
        'required_specialties': specialties,
        'urgency': urgency,
        'include_all': includeAll,
        'limit': resultLimit,
      },
    );
    if (json['success'] != true) {
      throw const ServerFailure('Could not load facilities.');
    }
    return (json['hospitals'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<FacilityModel>> fetchNearby() async {
    final List<Map<String, dynamic>> hospitals = await _recommend(
      includeAll: true,
      resultLimit: 20,
    );
    return hospitals.map(_toFacilityModel).toList();
  }

  @override
  Future<List<FacilityRecommendation>> fetchRecommendations() async {
    final List<FacilityRecommendation>? cached = _cache.fresh;
    if (cached != null) return cached.take(3).toList();
    final List<Map<String, dynamic>> hospitals = await _recommend(
      resultLimit: 3,
    );
    return _toRecommendations(hospitals);
  }

  @override
  Future<FacilityRecommendation> fetchEmergencyMatch() async {
    final List<FacilityRecommendation>? cached = _cache.fresh;
    if (cached != null && cached.isNotEmpty) return cached.first;
    final List<Map<String, dynamic>> hospitals = await _recommend(
      urgency: 'emergency',
      resultLimit: 1,
    );
    if (hospitals.isEmpty) {
      throw const NotFoundFailure('No emergency-capable facility found.');
    }
    return _toRecommendations(hospitals).first;
  }

  @override
  Future<FacilityModel> fetchById(String id) async {
    // Always read details from the server. Recommendation results are cached
    // for the diagnosis flow and may contain telemetry from an earlier poll;
    // using them here made the map and detail screens disagree after the
    // occupancy simulator updated a facility.
    final List<Map<String, dynamic>> hospitals = await _recommend(
      includeAll: true,
      resultLimit: 1000,
    );
    final List<FacilityModel> models = hospitals.map(_toFacilityModel).toList();
    return models.firstWhere(
      (FacilityModel f) => f.id == id,
      orElse: () =>
          throw const NotFoundFailure('That facility is no longer listed.'),
    );
  }

  List<FacilityRecommendation> _toRecommendations(
    List<Map<String, dynamic>> hospitals,
  ) {
    final List<FacilityRecommendation> result = <FacilityRecommendation>[];
    for (int i = 0; i < hospitals.length; i++) {
      final FacilityModel facility = _toFacilityModel(hospitals[i]);
      final num rawScore = (hospitals[i]['score'] as num?) ?? 50;
      final int score = rawScore.round().clamp(0, 100);
      result.add(
        FacilityRecommendation(
          facility: facility,
          rank: i == 0
              ? MatchRank.top
              : i == 1
              ? MatchRank.alternative
              : MatchRank.last,
          confidence: score >= 80
              ? ConfidenceLevel.high
              : score >= 55
              ? ConfidenceLevel.medium
              : ConfidenceLevel.low,
          confidenceScore: score,
          reasons:
              (hospitals[i]['whyRecommended'] as List<dynamic>?)
                  ?.map((dynamic e) => e.toString())
                  .toList() ??
              const <String>[],
        ),
      );
    }
    return result;
  }

  FacilityModel _toFacilityModel(Map<String, dynamic> h) {
    final Map<String, dynamic>? location =
        h['location'] as Map<String, dynamic>?;
    final List<dynamic> coords =
        location?['coordinates'] as List<dynamic>? ?? <dynamic>[0, 0];
    // The hospital recommendation endpoint returns flat latitude/longitude
    // fields; retain GeoJSON support for cached or alternate responses.
    final double lng = (h['longitude'] as num?)?.toDouble() ??
        (coords.isNotEmpty ? (coords[0] as num).toDouble() : 0);
    final double lat = (h['latitude'] as num?)?.toDouble() ??
        (coords.length > 1 ? (coords[1] as num).toDouble() : 0);
    final num maxCapacity = (h['maxCapacity'] as num?) ?? 0;
    final num currentPatients = (h['currentPatients'] as num?) ?? 0;
    final double occupancyPct = maxCapacity == 0
        ? 0
        : (currentPatients / maxCapacity) * 100;
    final double distanceKm = ((h['distance'] as num?) ?? 0).toDouble();
    final int estimatedEtaMinutes = (distanceKm / 30 * 60).round().clamp(
      1,
      180,
    );

    return FacilityModel(
      id: (h['_id'] ?? h['id'] ?? '').toString(),
      name: (h['name'] as String?) ?? 'Unknown facility',
      distanceKm: distanceKm,
      etaMinutes: estimatedEtaMinutes,
      load: occupancyPct >= 80
          ? FacilityLoad.high
          : occupancyPct >= 50
          ? FacilityLoad.medium
          : FacilityLoad.low,
      currentPatients: currentPatients.round(),
      incomingPatients: ((h['incomingPatients'] as num?) ?? 0).round(),
      totalBeds: ((h['availableBeds'] as num?) ?? maxCapacity).round(),
      bedCapacity: maxCapacity.round(),
      waitMinutes:
          ((h['estimatedWaitingTime'] ?? h['averageWaitingTime']) as num?)
              ?.round() ??
          0,
      emergencies: ((h['emergencies'] as num?) ?? 0).round(),
      isEmergencyCapable: (h['emergency'] as bool?) ?? false,
      latitude: lat,
      longitude: lng,
      staffCount: ((h['availableDoctors'] as num?) ?? 0).round(),
      patientCapacity: maxCapacity.round(),
      phoneNumber: (h['phone'] as String?) ?? '',
      departments:
          (h['specialties'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      services:
          (h['services'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      isLive: (h['isOpen'] as bool?) ?? true,
      lastUpdatedAt: DateTime.tryParse(h['lastUpdated'] as String? ?? ''),
    );
  }

  @override
  Future<String> startArrival(String facilityId, int etaMinutes, double latitude, double longitude) async {
    final json = await _api.post('/hospitals/$facilityId/arrivals', body: {'etaMinutes': etaMinutes, 'latitude': latitude, 'longitude': longitude}, authenticated: true);
    return json['arrivalId'].toString();
  }

  @override
  Future<void> heartbeatArrival(String facilityId, String arrivalId, int etaMinutes, double latitude, double longitude) async {
    await _api.patch('/hospitals/$facilityId/arrivals/$arrivalId', body: {'etaMinutes': etaMinutes, 'latitude': latitude, 'longitude': longitude}, authenticated: true);
  }

  @override
  Future<void> cancelArrival(String facilityId, String arrivalId) async {
    await _api.delete('/hospitals/$facilityId/arrivals/$arrivalId', authenticated: true);
  }
}
