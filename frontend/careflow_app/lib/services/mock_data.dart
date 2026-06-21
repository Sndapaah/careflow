import '../models/hospital.dart';

final List<Hospital> hospitals = [
  Hospital(
    name: "KNUST Hospital",
    distance: 2.3,
    availableBeds: 14,
    currentPatients: 82,
    incomingPatients: 17,
    waitTime: 18,
    confidence: 92,
    status: "OPEN",
  ),
  Hospital(
    name: "Komfo Anokye",
    distance: 5.6,
    availableBeds: 7,
    currentPatients: 140,
    incomingPatients: 28,
    waitTime: 42,
    confidence: 88,
    status: "HIGH CONGESTION",
  ),
];