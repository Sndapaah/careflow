import '../entities/symptom_analysis.dart';

abstract interface class SymptomRepository {
  /// Runs the CareFlow AI symptom checker.
  Future<SymptomAnalysis> analyze(List<String> symptoms);

  /// One-tap suggestions under the search field on Home.
  Future<List<String>> getQuickSymptoms();

  /// The patient's recent entries, newest first.
  Future<List<RecentSymptom>> getRecentSymptoms();
}
