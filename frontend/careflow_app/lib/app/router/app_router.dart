import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/legal/presentation/pages/terms_page.dart';
import '../../features/auth/presentation/pages/verification_success_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/facilities/presentation/pages/emergency_page.dart';
import '../../features/facilities/presentation/pages/facility_detail_page.dart';
import '../../features/facilities/presentation/pages/map_page.dart';
import '../../features/facilities/presentation/pages/recommended_facilities_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/symptoms/presentation/pages/ai_analysis_page.dart';
import '../../features/onboarding/presentation/pages/location_permission_page.dart';
import '../../features/symptoms/domain/entities/symptom_analysis.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../view/main_shell.dart';
import 'app_routes.dart';

/// Single [GoRouter] for the app: a linear auth/onboarding flow, then a
/// three-branch shell with screens pushed on top of it.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  static GoRouter build() => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.welcome,
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const TermsPage(),
      ),  
      GoRoute(path: AppRoutes.otp, builder: (_, _) => const OtpPage()),
      GoRoute(
        path: AppRoutes.verified,
        builder: (_, _) => const VerificationSuccessPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingPage(),
    ),
        GoRoute(
          path: AppRoutes.locationPermission,
          builder: (_, _) => const LocationPermissionPage(),
        ),

      // Screens that sit above the tab bar.
      GoRoute(
        path: AppRoutes.analysis,
        parentNavigatorKey: _rootKey,
        builder: (_, GoRouterState state) => AiAnalysisPage(
          symptoms: (state.extra as List<String>?) ?? const <String>[],
        ),
      ),
      GoRoute(
        path: AppRoutes.recommendations,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const RecommendedFacilitiesPage(),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const EmergencyPage(),
      ),
      GoRoute(
        path: '${AppRoutes.facility}/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, GoRouterState state) =>
            FacilityDetailPage(facilityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(
  path: AppRoutes.emergency,
  parentNavigatorKey: _rootKey,
  builder: (_, GoRouterState state) =>
      EmergencyPage(analysis: state.extra as SymptomAnalysis?),
),

      StatefulShellRoute.indexedStack(
        builder: (_, _, StatefulNavigationShell shell) =>
            MainShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.map,
                builder: (_, GoRouterState state) => MapPage(
                  // Set when arriving from a recommendation card.
                  key: ValueKey<String?>(state.uri.queryParameters['facility']),
                  focusFacilityId: state.uri.queryParameters['facility'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
          // app_router.dart — add alongside your other pushed-over-shell routes
        ],
      ),
    ],
  );
}
