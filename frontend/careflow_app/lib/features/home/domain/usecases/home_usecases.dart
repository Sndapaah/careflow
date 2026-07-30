import '../../../../core/usecases/usecase.dart';
import '../entities/health_tip.dart';
import '../repositories/home_repository.dart';

class GetDailyTip implements UseCase<HealthTip, NoParams> {
  const GetDailyTip(this._repository);

  final HomeRepository _repository;

  @override
  Future<HealthTip> call(NoParams params) => _repository.getDailyTip();
}

class GetUnreadNotificationCount implements UseCase<int, NoParams> {
  const GetUnreadNotificationCount(this._repository);

  final HomeRepository _repository;

  @override
  Future<int> call(NoParams params) => _repository.getUnreadNotificationCount();
}
