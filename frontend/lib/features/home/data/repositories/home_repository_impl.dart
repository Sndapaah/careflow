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
    HealthTip(
      title: "Today's Health Tip",
      body: 'A 10-minute walk after meals helps regulate blood sugar.',
    ),
    HealthTip(
      title: "Today's Health Tip",
      body: 'Take breaks from screens every 20 minutes to rest your eyes.',
    ),
    HealthTip(
      title: "Today's Health Tip",
      body: 'Deep breathing for a few minutes a day can lower stress.',
    ),
  ];

  @override
  Future<HealthTip> getDailyTip() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Keep the same tip within each local 12-hour window and guarantee the
    // next window advances to a different tip.
    final DateTime now = DateTime.now();
    final int halfDay = now.hour < 12 ? 0 : 1;
    final int day = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(2020)).inDays;
    final int index = (day * 2 + halfDay) % _tips.length;
    return _tips[index];
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 3;
  }
}
