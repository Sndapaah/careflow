import '../../../../core/usecases/usecase.dart';
import '../entities/symptom_analysis.dart';
import '../repositories/symptom_repository.dart';

class AnalyzeSymptoms implements UseCase<SymptomAnalysis, List<String>> {
  const AnalyzeSymptoms(this._repository);

  final SymptomRepository _repository;

  @override
  Future<SymptomAnalysis> call(List<String> params) =>
      _repository.analyze(params);
}

class GetQuickSymptoms implements UseCase<List<String>, NoParams> {
  const GetQuickSymptoms(this._repository);

  final SymptomRepository _repository;

  @override
  Future<List<String>> call(NoParams params) => _repository.getQuickSymptoms();
}

class GetRecentSymptoms implements UseCase<List<RecentSymptom>, NoParams> {
  const GetRecentSymptoms(this._repository);

  final SymptomRepository _repository;

  @override
  Future<List<RecentSymptom>> call(NoParams params) =>
      _repository.getRecentSymptoms();
}
