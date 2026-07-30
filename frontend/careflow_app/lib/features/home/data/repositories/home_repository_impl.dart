import '../../domain/entities/health_tip.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  static const List<HealthTip> _tips = <HealthTip>[
    HealthTip(
      title: "Today's Health Tip",
      body: 'Stay hydrated! Drink water daily to regulate your body.',
    ),
    HealthTip(
      title: "Today's Health Tip",
      body: 'Sleep seven to nine hours — rest is when your body repairs.',
    ),
    HealthTip(
      title: "Today's Health Tip",
      body: 'Wash your hands before meals to keep infections away.',
    ),
  ];

  @override
  Future<HealthTip> getDailyTip() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Rotates daily rather than randomly, so the tip is stable within a day.
    return _tips[DateTime.now().day % _tips.length];
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 3;
  }
}
