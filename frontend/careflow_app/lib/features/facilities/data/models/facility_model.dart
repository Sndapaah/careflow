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
    required super.waitMinutes,
    required super.emergencies,
    required super.isEmergencyCapable,
    super.staffCount,
    super.patientCapacity,
    super.phoneNumber,
    super.departments,
    super.services,
    super.lastUpdatedMinutes,
    super.isLive,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      etaMinutes: json['eta_minutes'] as int,
      load: FacilityLoad.values.firstWhere(
        (FacilityLoad value) => value.name == json['load'],
        orElse: () => FacilityLoad.low,
      ),
      currentPatients: json['current_patients'] as int? ?? 0,
      incomingPatients: json['incoming_patients'] as int? ?? 0,
      totalBeds: json['total_beds'] as int? ?? 0,
      waitMinutes: json['wait_minutes'] as int? ?? 0,
      emergencies: json['emergencies'] as int? ?? 0,
      isEmergencyCapable: json['is_emergency_capable'] as bool? ?? false,
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
    'wait_minutes': waitMinutes,
    'emergencies': emergencies,
    'is_emergency_capable': isEmergencyCapable,
    'staff_count': staffCount,
    'patient_capacity': patientCapacity,
    'phone_number': phoneNumber,
    'departments': departments,
    'services': services,
    'last_updated_minutes': lastUpdatedMinutes,
    'is_live': isLive,
  };
}
