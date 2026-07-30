import '../entities/health_tip.dart';

abstract interface class HomeRepository {
  Future<HealthTip> getDailyTip();

  /// Unread notification count for the bell badge.
  Future<int> getUnreadNotificationCount();
}
