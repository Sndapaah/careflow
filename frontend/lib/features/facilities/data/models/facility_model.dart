import '../../domain/entities/facility.dart';

/// Data-layer representation of [Facility]. Owns the JSON contract so the
/// domain entity stays free of serialisation concerns.
class FacilityModel extends Facility {
  const FacilityModel({
    required super.id,
    required super.name,
    required super.distanceKm,
    required super.etaMinutes,
    required super.load,
    required super.currentPatients,
    required super.incomingPatients,
    required super.totalBeds,
    required super.bedCapacity,
    required super.waitMinutes,
    required super.emergencies,
    required super.isEmergencyCapable,
    required super.latitude,
    required super.longitude,
    super.staffCount,
    super.patientCapacity,
    super.phoneNumber,
    super.departments,
    super.services,
    super.lastUpdatedMinutes,
    super.lastUpdatedAt,
    super.isLive,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    int asInt(Object? value) => value is num ? value.round() : int.tryParse('$value') ?? 0;
    return FacilityModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown facility').toString(),
      distanceKm: ((json['distance_km'] ?? json['distance'] ?? 0) as num).toDouble(),
      etaMinutes: asInt(json['eta_minutes'] ?? json['etaMinutes']),
      load: FacilityLoad.values.firstWhere(
        (FacilityLoad value) => value.name == json['load'],
        orElse: () => FacilityLoad.low,
      ),
      currentPatients: asInt(json['current_patients'] ?? json['currentPatients']),
      incomingPatients: asInt(json['incoming_patients'] ?? json['incomingPatients']),
      totalBeds: asInt(json['total_beds'] ?? json['availableBeds']),
      bedCapacity: asInt(json['bed_capacity'] ?? json['maxCapacity']),
      waitMinutes: asInt(json['wait_minutes'] ?? json['averageWaitingTime']),
      emergencies: asInt(json['emergencies']),
      isEmergencyCapable: (json['is_emergency_capable'] ?? json['emergency'] ?? false) as bool,
      latitude: ((json['latitude'] ?? 0) as num).toDouble(),
      longitude: ((json['longitude'] ?? 0) as num).toDouble(),
      staffCount: json['staff_count'] as int? ?? 0,
      patientCapacity: json['patient_capacity'] as int? ?? 0,
      phoneNumber: json['phone_number'] as String? ?? '',
      departments:
          (json['departments'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      services:
          (json['services'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      lastUpdatedMinutes: json['last_updated_minutes'] as int?,
      lastUpdatedAt: DateTime.tryParse(json['last_updated_at'] as String? ?? ''),
      isLive: json['is_live'] as bool? ?? true,
    );
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'distance_km': distanceKm,
    'eta_minutes': etaMinutes,
    'load': load.name,
    'current_patients': currentPatients,
    'incoming_patients': incomingPatients,
    'total_beds': totalBeds,
    'bed_capacity': bedCapacity,
    'wait_minutes': waitMinutes,
    'emergencies': emergencies,
    'is_emergency_capable': isEmergencyCapable,
    'latitude': latitude,
    'longitude': longitude,
    'staff_count': staffCount,
    'patient_capacity': patientCapacity,
    'phone_number': phoneNumber,
    'departments': departments,
    'services': services,
    'last_updated_minutes': lastUpdatedMinutes,
    'last_updated_at': lastUpdatedAt?.toIso8601String(),
    'is_live': isLive,
  };
}
