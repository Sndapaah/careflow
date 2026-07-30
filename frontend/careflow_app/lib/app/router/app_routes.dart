/// Every navigable path in the app, in one place.
abstract final class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String verified = '/verified';
  static const String onboarding = '/onboarding';

  // Bottom-navigation tabs.
  static const String home = '/home';
  static const String map = '/map';
  static const String profile = '/profile';

  // Pushed over the shell.
  static const String analysis = '/analysis';
  static const String recommendations = '/recommendations';
  static const String emergency = '/emergency';
  static const String facility = '/facility';

  static String facilityDetail(String id) => '$facility/$id';

  /// Opens the map tab focused on a single facility.
  static String mapFocused(String facilityId) => '$map?facility=$facilityId';
}
