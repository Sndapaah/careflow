import '../models/hospital.dart';

final List<Hospital> hospitals = [
  Hospital(
    rank: 1,
    name: "KNUST Hospital",
    distance: 2.3,
    availableBeds: 14,
    currentPatients: 82,
    incomingPatients: 17,
    waitTime: 18,
    confidence: 92,
    status: "OPEN",

    lastUpdated: "2 mins ago",
    congestionLevel: "LOW",
    predictedPatients: 95,
    predictedWaitTime: 20,
    predictionConfidence: 89,
    historicalReliability: 95,

    specialties: [
      "General Medicine",
      "Emergency Care",
      "Neurology",
      "Cardiology",
    ],
  ),

  Hospital(
    rank: 2,
    name: "Komfo Anokye",
    distance: 5.6,
    availableBeds: 7,
    currentPatients: 140,
    incomingPatients: 28,
    waitTime: 42,
    confidence: 88,
    status: "HIGH CONGESTION",

    lastUpdated: "1 min ago",
    congestionLevel: "HIGH",
    predictedPatients: 170,
    predictedWaitTime: 55,
    predictionConfidence: 91,
    historicalReliability: 97,

    specialties: [
      "Emergency Care",
      "Orthopedics",
      "Cardiology",
      "Neurology",
    ],
  ),
];