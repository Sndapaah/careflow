import 'package:equatable/equatable.dart';

/// How busy a facility currently is. Drives the coloured load badge.
enum FacilityLoad {
  low('Low Load'),
  medium('Medium Load'),
  high('High Load');

  const FacilityLoad(this.label);

  final String label;
}

/// A health facility together with its live capacity telemetry.
class Facility extends Equatable {
  const Facility({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.etaMinutes,
    required this.load,
    required this.currentPatients,
    required this.incomingPatients,
    required this.totalBeds,
    required this.waitMinutes,
    required this.emergencies,
    required this.isEmergencyCapable,
    required this.latitude,
    required this.longitude,
    this.staffCount = 0,
    this.patientCapacity = 0,
    this.phoneNumber = '',
    this.departments = const <String>[],
    this.services = const <String>[],
    this.lastUpdatedMinutes,
    this.isLive = true,
  });

  final String id;
  final String name;
  final double distanceKm;
  final int etaMinutes;
  final FacilityLoad load;

  final double latitude;
  final double longitude;

  final int currentPatients;
  final int incomingPatients;
  final int totalBeds;
  final int waitMinutes;
  final int emergencies;
  final bool isEmergencyCapable;

  final int staffCount;
  final int patientCapacity;
  final String phoneNumber;
  final List<String> departments;
  final List<String> services;

  /// Minutes since the facility last reported. `null` renders as "N/A".
  final int? lastUpdatedMinutes;
  final bool isLive;

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';

  String get etaLabel => '$etaMinutes mins';

  String get waitLabel => '$waitMinutes min';

  String get lastUpdatedLabel =>
      lastUpdatedMinutes == null ? 'N/A' : '$lastUpdatedMinutes mins';

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    distanceKm,
    etaMinutes,
    load,
    currentPatients,
    incomingPatients,
    totalBeds,
    waitMinutes,
    emergencies,
    isEmergencyCapable,
    staffCount,
    patientCapacity,
    phoneNumber,
    departments,
    services,
    lastUpdatedMinutes,
    isLive,
  ];
}
