import '../../../../core/cache/last_diagnosis_cache.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/location/current_location_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../facilities/domain/entities/facility.dart';
import '../../../facilities/domain/entities/facility_recommendation.dart';
import '../../../profile/domain/entities/patient_profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../../domain/repositories/symptom_repository.dart';

class SymptomHttpRepositoryImpl implements SymptomRepository {
  SymptomHttpRepositoryImpl({
    required ApiClient apiClient,
    required CurrentLocationProvider locationProvider,
    required ProfileRepository profileRepository,
    required LastDiagnosisCache diagnosisCache,
  }) : _api = apiClient,
       _location = locationProvider,
       _profile = profileRepository,
       _cache = diagnosisCache;

  final ApiClient _api;
  final CurrentLocationProvider _location;
  final ProfileRepository _profile;
  final LastDiagnosisCache _cache;

  static const List<String> _quick = <String>[
    'Headache',
    'Nausea',
    'Cough',
    'Fever',
    'Body pain',
    'Dizziness',
    'Sore throat',
  ];

  @override
  Future<SymptomAnalysis> analyze(List<String> symptoms) async {
    final (double lat, double lng) = await _location.getCurrent();

    int age = 0;
    String sex = 'unspecified';
    List<String> conditions = const <String>[];
    List<String> allergies = const <String>[];
    try {
//      final PatientProfile profile = await _profile.getPatientProfile();
      final PatientProfile profile = await _profile.getProfile();
      age = DateTime.now().difference(profile.dateOfBirth).inDays ~/ 365;
      sex = profile.gender.name;
      conditions = profile.conditions;
      allergies = profile.allergies;
    } catch (_) {
      // Proceed without demographics rather than blocking analysis.
    }

    final Map<String, dynamic> json = await _api.post(
      '/diagnosis/diagnose',
      authenticated: true,
      body: <String, dynamic>{
        'age': age,
        'sex': sex,
        'symptoms': symptoms,
        'existing_conditions': conditions,
        'allergies': allergies,
        'medications': const <String>[],
        'additional_information': '',
        'latitude': lat,
        'longitude': lng,
      },
    );

    if (json['success'] != true) {
      throw ServerFailure(json['message'] as String? ?? 'Analysis failed.');
    }

    final Map<String, dynamic> analysis =
        json['analysis'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> hospitalsJson =
        json['recommended_hospitals'] as List<dynamic>? ?? <dynamic>[];

    final List<FacilityRecommendation> recommendations =
        _mapHospitals(hospitalsJson);
    if (recommendations.isNotEmpty) _cache.store(recommendations);

    return _mapAnalysis(symptoms, analysis);
  }

  SymptomAnalysis _mapAnalysis(
    List<String> symptoms,
    Map<String, dynamic> analysis,
  ) {
    final List<dynamic> conditionsJson =
        analysis['possible_conditions'] as List<dynamic>? ?? <dynamic>[];

    final List<PossibleCondition> conditions = conditionsJson.map((dynamic c) {
      final Map<String, dynamic> map = c as Map<String, dynamic>;
      final String name = (map['name'] ?? map['condition'] ?? 'Unknown') as String;
      final num confidence = (map['confidence'] as num?) ?? 50;
      return PossibleCondition(
        name: name,
        confidence: confidence.round().clamp(0, 100),
      );
    }).toList();

    final List<String> recommendations =
        (analysis['recommendations'] as List<dynamic>?)
            ?.map((dynamic e) => e.toString())
            .toList() ??
        const <String>['Visit a healthcare facility for assessment.'];

    final String? urgency =
        (analysis['safety'] as Map<String, dynamic>?)?['urgency'] as String?;
    final String? severityRaw = analysis['severity'] as String?;

    final SeverityLevel severity = urgency == 'emergency'
        ? SeverityLevel.high
        : switch (severityRaw?.toLowerCase()) {
            'high' => SeverityLevel.high,
            'moderate' || 'medium' => SeverityLevel.moderate,
            _ => SeverityLevel.low,
          };

    return SymptomAnalysis(
      symptoms: symptoms,
      conditions: conditions,
      recommendations: recommendations,
      severity: severity,
    );
  }

  List<FacilityRecommendation> _mapHospitals(List<dynamic> hospitalsJson) {
    final List<FacilityRecommendation> result = <FacilityRecommendation>[];
    for (int i = 0; i < hospitalsJson.length; i++) {
      final Map<String, dynamic> h = hospitalsJson[i] as Map<String, dynamic>;
      final Facility facility = _mapFacility(h);
      final num rawScore = (h['score'] as num?) ?? 50;
      final int score = rawScore.round().clamp(0, 100);
      final ConfidenceLevel confidence = score >= 80
          ? ConfidenceLevel.high
          : score >= 55
          ? ConfidenceLevel.medium
          : ConfidenceLevel.low;
      final MatchRank rank = i == 0
          ? MatchRank.top
          : i == 1
          ? MatchRank.alternative
          : MatchRank.last;
      final List<String> reasons =
          (h['whyRecommended'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[];

      result.add(FacilityRecommendation(
        facility: facility,
        rank: rank,
        confidence: confidence,
        confidenceScore: score,
        reasons: reasons,
      ));
    }
    return result;
  }

  Facility _mapFacility(Map<String, dynamic> h) {
    final Map<String, dynamic>? location = h['location'] as Map<String, dynamic>?;
    final List<dynamic> coords =
        location?['coordinates'] as List<dynamic>? ?? <dynamic>[0, 0];
    final double lng = (coords[0] as num).toDouble();
    final double lat = (coords.length > 1 ? coords[1] as num : 0).toDouble();

    final num maxCapacity = (h['maxCapacity'] as num?) ?? 0;
    final num currentPatients = (h['currentPatients'] as num?) ?? 0;
    final double occupancyPct =
        maxCapacity == 0 ? 0 : (currentPatients / maxCapacity) * 100;
    final double distanceKm = ((h['distance'] as num?) ?? 0).toDouble();
    final int estimatedEtaMinutes = (distanceKm / 30 * 60).round().clamp(1, 180);

    return Facility(
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
      incomingPatients: 0,
      totalBeds: ((h['availableBeds'] as num?) ?? maxCapacity).round(),
      waitMinutes:
          ((h['estimatedWaitingTime'] ?? h['averageWaitingTime']) as num?)
                  ?.round() ??
              0,
      emergencies: 0,
      isEmergencyCapable: (h['emergency'] as bool?) ?? false,
      latitude: lat,
      longitude: lng,
      staffCount: ((h['availableDoctors'] as num?) ?? 0).round(),
      patientCapacity: maxCapacity.round(),
      phoneNumber: (h['phone'] as String?) ?? '',
      departments: (h['specialties'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      services: (h['services'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      isLive: (h['isOpen'] as bool?) ?? true,
    );
  }

  @override
  Future<List<String>> getQuickSymptoms() async => _quick;

  @override
  Future<List<RecentSymptom>> getRecentSymptoms() async {
    final Map<String, dynamic> json = await _api.get(
      '/history/history',
      authenticated: true,
    );

    if (json['success'] != true) return const <RecentSymptom>[];

    final List<dynamic> history =
        json['history'] as List<dynamic>? ?? <dynamic>[];

    return history.map((dynamic entry) {
      final Map<String, dynamic> record = entry as Map<String, dynamic>;
      final List<dynamic> symptomsJson =
          record['symptoms'] as List<dynamic>? ?? <dynamic>[];
      final String label = symptomsJson.isEmpty
          ? 'Symptom check'
          : symptomsJson.map((dynamic s) => s.toString()).join(', ');
      final String? createdAt = record['createdAt'] as String?;
      return RecentSymptom(
        label: label,
        whenLabel:
            createdAt == null ? '' : _relativeTime(DateTime.parse(createdAt)),
      );
    }).toList();
  }

  String _relativeTime(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}