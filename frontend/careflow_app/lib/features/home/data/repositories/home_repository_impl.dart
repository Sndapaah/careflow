import 'dart:math';

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

    // Seed a Random with today's date so the pick is stable across app
    // restarts within the same day, but looks shuffled day-to-day rather
    // than cycling in a visible day % length pattern.
    final DateTime now = DateTime.now();
    final int seed = now.year * 10000 + now.month * 100 + now.day;
    final int index = Random(seed).nextInt(_tips.length);
    return _tips[index];
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 3;
  }
}