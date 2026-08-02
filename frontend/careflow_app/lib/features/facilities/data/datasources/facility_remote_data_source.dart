import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../models/facility_model.dart';

/// Boundary the repository talks to. Swap the in-memory implementation below
/// for an HTTP client once the CareFlow backend endpoints are live — nothing
/// above this interface has to change.
abstract interface class FacilityRemoteDataSource {
  Future<List<FacilityModel>> fetchNearby();

  Future<List<FacilityRecommendation>> fetchRecommendations();

  Future<FacilityRecommendation> fetchEmergencyMatch();

  Future<FacilityModel> fetchById(String id);
}

/// In-memory stand-in seeded with the reference data from the designs.
class FacilityInMemoryDataSource implements FacilityRemoteDataSource {
  static const Duration _latency = Duration(milliseconds: 350);

  static const FacilityModel universityClinic = FacilityModel(
    id: 'university-clinic',
    name: 'University Clinic',
    distanceKm: 1.2,
    etaMinutes: 5,
    load: FacilityLoad.low,
    currentPatients: 4,
    incomingPatients: 5,
    totalBeds: 3,
    waitMinutes: 7,
    emergencies: 0,
    isEmergencyCapable: true,
    latitude: 6.6745,
    longitude: -1.5716,
    staffCount: 8,
    patientCapacity: 12,
    phoneNumber: '+233 32 206 0331',
    departments: <String>['Out-Patient Department', 'Pharmacy', 'Laboratory'],
    services: <String>['General Medicine', 'Pharmacy', 'Lab Tests'],
    lastUpdatedMinutes: 5,
  );

  static const FacilityModel universityHospital = FacilityModel(
    id: 'university-hospital',
    name: 'University Hospital',
    distanceKm: 2.4,
    etaMinutes: 12,
    load: FacilityLoad.low,
    currentPatients: 21,
    incomingPatients: 18,
    totalBeds: 20,
    waitMinutes: 18,
    emergencies: 4,
    isEmergencyCapable: true,
    latitude: 6.6746,
    longitude: -1.5661,
    staffCount: 46,
    patientCapacity: 60,
    phoneNumber: '+233 32 206 0400',
    departments: <String>[
      'Emergency',
      'Out-Patient Department',
      'Pharmacy',
      'Laboratory',
      'Radiology',
    ],
    services: <String>[
      'General Medicine',
      'Emergency Care',
      'Pharmacy',
      'Lab Tests',
      'Imaging',
    ],
    lastUpdatedMinutes: 7,
  );

  static const FacilityModel districtClinic = FacilityModel(
    id: 'district-clinic',
    name: 'District Clinic',
    distanceKm: 3.2,
    etaMinutes: 24,
    load: FacilityLoad.medium,
    currentPatients: 16,
    incomingPatients: 12,
    totalBeds: 10,
    waitMinutes: 34,
    emergencies: 2,
    isEmergencyCapable: false,
    latitude: 6.7009,
    longitude: -1.6231,
    staffCount: 14,
    patientCapacity: 25,
    phoneNumber: '+233 32 209 1122',
    departments: <String>['Out-Patient Department', 'Pharmacy'],
    services: <String>['General Medicine', 'Pharmacy'],
    isLive: false,
  );

  static const List<FacilityModel> _all = <FacilityModel>[
    universityClinic,
    universityHospital,
    districtClinic,
  ];

  static const List<FacilityModel> _nearby = <FacilityModel>[
    FacilityModel(
      id: 'komfo-anokye',
      name: 'Komfo Anokye Hospital',
      distanceKm: 4.8,
      etaMinutes: 21,
      load: FacilityLoad.high,
      currentPatients: 84,
      incomingPatients: 32,
      totalBeds: 120,
      waitMinutes: 52,
      emergencies: 9,
      isEmergencyCapable: true,
      latitude: 6.6886,
      longitude: -1.6244,
    ),
    FacilityModel(
      id: 'bomso',
      name: 'Bomso Hospital',
      distanceKm: 3.6,
      etaMinutes: 16,
      load: FacilityLoad.medium,
      currentPatients: 28,
      incomingPatients: 11,
      totalBeds: 40,
      waitMinutes: 26,
      emergencies: 1,
      isEmergencyCapable: true,
      latitude: 6.6790,
      longitude: -1.5850,
    ),
    FacilityModel(
      id: 'knust-hospital',
      name: 'KNUST Hospital',
      distanceKm: 2.4,
      etaMinutes: 12,
      load: FacilityLoad.low,
      currentPatients: 21,
      incomingPatients: 18,
      totalBeds: 20,
      waitMinutes: 18,
      emergencies: 4,
      isEmergencyCapable: true,
      latitude: 6.6746,
      longitude: -1.5661,
    ),
    FacilityModel(
      id: 'knust-clinic',
      name: 'KNUST Clinic',
      distanceKm: 1.2,
      etaMinutes: 5,
      load: FacilityLoad.low,
      currentPatients: 4,
      incomingPatients: 5,
      totalBeds: 3,
      waitMinutes: 7,
      emergencies: 0,
      isEmergencyCapable: false,
      latitude: 6.6745,
      longitude: -1.5716,
    ),
  ];

  @override
  Future<List<FacilityModel>> fetchNearby() async {
    await Future<void>.delayed(_latency);
    return _nearby;
  }

  @override
  Future<List<FacilityRecommendation>> fetchRecommendations() async {
    await Future<void>.delayed(_latency);
    return const <FacilityRecommendation>[
      FacilityRecommendation(
        facility: universityClinic,
        rank: MatchRank.top,
        confidence: ConfidenceLevel.high,
        confidenceScore: 92,
        reasons: <String>[
          'Closest facility',
          'Low congestion',
          'Shortest wait time',
          'Matches speciality',
        ],
      ),
      FacilityRecommendation(
        facility: universityHospital,
        rank: MatchRank.alternative,
        confidence: ConfidenceLevel.high,
        confidenceScore: 85,
        reasons: <String>[
          'Low congestion',
          'Shortest wait time',
          'Matches speciality',
        ],
      ),
      FacilityRecommendation(
        facility: districtClinic,
        rank: MatchRank.last,
        confidence: ConfidenceLevel.medium,
        confidenceScore: 64,
        reasons: <String>['Matches speciality'],
      ),
    ];
  }

  @override
  Future<FacilityRecommendation> fetchEmergencyMatch() async {
    await Future<void>.delayed(_latency);
    return const FacilityRecommendation(
      facility: universityHospital,
      rank: MatchRank.top,
      confidence: ConfidenceLevel.high,
      confidenceScore: 94,
      reasons: <String>[
        'Emergency-Capable Facility',
        'More beds available',
        'Matches speciality',
      ],
    );
  }

  @override
  Future<FacilityModel> fetchById(String id) async {
    await Future<void>.delayed(_latency);
    return <FacilityModel>[..._all, ..._nearby].firstWhere(
      (FacilityModel facility) => facility.id == id,
      orElse: () => universityClinic,
    );
  }
}
