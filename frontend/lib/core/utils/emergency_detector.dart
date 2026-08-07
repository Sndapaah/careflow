/// Single source of truth for what counts as an emergency symptom.
/// Used by the symptom repository (to set severity) and by the Home screen
/// (for an instant local check before the AI call even happens).
class EmergencyDetector {
  static const List<String> keywords = <String>[
    'heart attack',
    'chest pain',
    "can't breathe",
    'cannot breathe',
    'difficulty breathing',
    'shortness of breath',
    'stroke',
    'severe bleeding',
    'unconscious',
    'unresponsive',
    'seizure',
    'suicidal',
    'overdose',
    'severe allergic reaction',
    'anaphylaxis',
    'choking',
  ];

  static bool isEmergency(List<String> symptoms) {
    final String joined = symptoms.join(' ').toLowerCase();
    return keywords.any((String keyword) => joined.contains(keyword));
  }
}