import 'package:careflow_app/models/hospital.dart';

class Recommendation {
  final Hospital hospital;
  final int score;
  final String specialtyMatch;

  Recommendation({
    required this.hospital,
    required this.score,
    required this.specialtyMatch,
  });
}

