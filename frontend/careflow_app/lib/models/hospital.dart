class Hospital {
  final String name;
  final double distance;
  final int confidence;
  final int availableBeds;
  final int currentPatients;
  final int incomingPatients;
  final int waitTime;
  final String status;

  Hospital({
    required this.name,
    required this.distance,
    required this.confidence,
    required this.availableBeds,
    required this.currentPatients,
    required this.incomingPatients,
    required this.waitTime,
    required this.status,
  });
}