import 'package:equatable/equatable.dart';

/// How urgent the AI thinks the situation is. The patient can override it.
enum SeverityLevel {
  low('Low'),
  moderate('Moderate'),
  high('High');

  const SeverityLevel(this.label);

  final String label;
}

/// One candidate condition with the model's confidence in it.
class PossibleCondition extends Equatable {
  const PossibleCondition({required this.name, required this.confidence});

  final String name;

  /// 0..100
  final int confidence;

  @override
  List<Object?> get props => <Object?>[name, confidence];
}

/// A symptom the patient logged previously, for the home screen list.
class RecentSymptom extends Equatable {
  const RecentSymptom({required this.label, required this.whenLabel});

  final String label;
  final String whenLabel;

  @override
  List<Object?> get props => <Object?>[label, whenLabel];
}

/// Full result of running the symptom checker.
class SymptomAnalysis extends Equatable {
  const SymptomAnalysis({
    required this.symptoms,
    required this.conditions,
    required this.recommendations,
    required this.severity,
  });

  final List<String> symptoms;
  final List<PossibleCondition> conditions;
  final List<String> recommendations;
  final SeverityLevel severity;

  /// Fixed medical-safety wording shown under the conditions list.
  static const String disclaimer =
      'These are AI-generated possibilities -- not a diagnosis.';

  SymptomAnalysis copyWith({SeverityLevel? severity}) => SymptomAnalysis(
    symptoms: symptoms,
    conditions: conditions,
    recommendations: recommendations,
    severity: severity ?? this.severity,
  );

  @override
  List<Object?> get props => <Object?>[
    symptoms,
    conditions,
    recommendations,
    severity,
  ];
}
