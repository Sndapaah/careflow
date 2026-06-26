class Hospital {
  final String name;
  final double distance;
  final int confidence;
  final int availableBeds;
  final int currentPatients;
  final int incomingPatients;
  final int waitTime;
  final String status;
  final int rank;

  // New fields

  final String lastUpdated;
  final String congestionLevel;
  final int predictedPatients;
  final int predictedWaitTime;
  final int predictionConfidence;
  final int historicalReliability;
  final List<String> specialties;

  Hospital({
    required this.name,
    required this.distance,
    required this.confidence,
    required this.availableBeds,
    required this.currentPatients,
    required this.incomingPatients,
    required this.waitTime,
    required this.status,
    required this.rank,

    required this.lastUpdated,
    required this.congestionLevel,
    required this.predictedPatients,
    required this.predictedWaitTime,
    required this.predictionConfidence,
    required this.historicalReliability,
    required this.specialties,
  });
}