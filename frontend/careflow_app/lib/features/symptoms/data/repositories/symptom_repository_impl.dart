import '../../../../core/error/failure.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../../../../core/utils/emergency_detector.dart';

/// Rule-based stand-in for the CareFlow AI service. It returns plausible,
/// deterministic output so the analysis screen can be built and reviewed
/// before the model endpoint exists.
class SymptomRepositoryImpl implements SymptomRepository {
  static const Duration _latency = Duration(milliseconds: 900);

  static const List<String> _quick = <String>[
    'Headache',
    'Nausea',
    'Cough',
    'Fever',
    'Body pain',
    'Dizziness',
    'Sore throat',
  ];

  static const Map<String, List<PossibleCondition>> _knowledge =
      <String, List<PossibleCondition>>{
        'headache': <PossibleCondition>[
          PossibleCondition(name: 'Malaria', confidence: 90),
          PossibleCondition(name: 'Flu', confidence: 82),
        ],
        'fever': <PossibleCondition>[
          PossibleCondition(name: 'Malaria', confidence: 88),
          PossibleCondition(name: 'Typhoid', confidence: 71),
        ],
        'cough': <PossibleCondition>[
          PossibleCondition(name: 'Respiratory infection', confidence: 84),
          PossibleCondition(name: 'Flu', confidence: 76),
        ],
        'nausea': <PossibleCondition>[
          PossibleCondition(name: 'Gastritis', confidence: 79),
          PossibleCondition(name: 'Food poisoning', confidence: 68),
        ],
      };

  @override
  Future<SymptomAnalysis> analyze(List<String> symptoms) async {
    await Future<void>.delayed(_latency);

    final List<String> cleaned = symptoms
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();

    if (cleaned.isEmpty) {
      throw const ServerFailure('Tell us what you are feeling first.');
    }

    final bool isEmergency = EmergencyDetector.isEmergency(cleaned);
    final List<PossibleCondition> conditions = _matchConditions(cleaned);

    return SymptomAnalysis(
      symptoms: cleaned,
      conditions: conditions,
      recommendations: isEmergency
          ? const <String>[
              'Seek emergency medical attention immediately.',
              'Call emergency services or go to the nearest hospital now.',
            ]
          : const <String>[
              'Visit a healthcare facility for assessment.',
              'Stay hydrated and rest well.',
            ],
      severity: isEmergency ? SeverityLevel.high : _severityFor(conditions),
    );
  }

  List<PossibleCondition> _matchConditions(List<String> symptoms) {
    final Map<String, PossibleCondition> merged = <String, PossibleCondition>{};

    for (final String symptom in symptoms) {
      final List<PossibleCondition>? hits = _knowledge[symptom.toLowerCase()];
      if (hits == null) continue;
      for (final PossibleCondition hit in hits) {
        final PossibleCondition? existing = merged[hit.name];
        if (existing == null || hit.confidence > existing.confidence) {
          merged[hit.name] = hit;
        }
      }
    }

    if (merged.isEmpty) {
      return const <PossibleCondition>[
        PossibleCondition(name: 'General infection', confidence: 64),
        PossibleCondition(name: 'Fatigue', confidence: 55),
      ];
    }

    final List<PossibleCondition> ranked = merged.values.toList()
      ..sort(
        (PossibleCondition a, PossibleCondition b) =>
            b.confidence.compareTo(a.confidence),
      );
    return ranked;
  }

  SeverityLevel _severityFor(List<PossibleCondition> conditions) {
    final int top = conditions.isEmpty ? 0 : conditions.first.confidence;
    if (top >= 95) return SeverityLevel.high;
    if (top >= 80) return SeverityLevel.moderate;
    return SeverityLevel.low;
  }

  @override
  Future<List<String>> getQuickSymptoms() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _quick;
  }

  @override
  Future<List<RecentSymptom>> getRecentSymptoms() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const <RecentSymptom>[
      RecentSymptom(label: 'Fever', whenLabel: 'yesterday'),
      RecentSymptom(label: 'Cough', whenLabel: '3 days ago'),
    ];
  }
}