import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injector.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verification_success_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/facilities/presentation/pages/emergency_page.dart';
import '../../features/facilities/presentation/pages/facility_detail_page.dart';
import '../../features/facilities/presentation/pages/map_page.dart';
import '../../features/facilities/presentation/pages/recommended_facilities_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/legal/presentation/pages/terms_page.dart';
import '../../features/onboarding/presentation/pages/location_permission_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/domain/entities/patient_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/symptoms/domain/entities/symptom_analysis.dart';
import '../../features/symptoms/presentation/pages/ai_analysis_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../view/main_shell.dart';
import 'app_routes.dart';

// Argument wrapper model to hold both active profile state and data pipeline dependencies together.
class EditProfileArgs {
  const EditProfileArgs({required this.profile, required this.bloc});

  final PatientProfile profile;
  final ProfileBloc bloc;
}

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
        builder: (_, GoRouterState state) =>
            EmergencyPage(analysis: state.extra as SymptomAnalysis?),
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
      
      // FIXED: Uses .value provider pattern to chain down the exact instance running inside the Profile Tab view
      GoRoute(
        path: AppRoutes.editProfile,
        parentNavigatorKey: _rootKey,
        builder: (_, GoRouterState state) {
          final EditProfileArgs args = state.extra as EditProfileArgs;
          return BlocProvider<ProfileBloc>.value(
            value: args.bloc,
            child: EditProfilePage(profile: args.profile),
          );
        },
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
        ],
      ),
    ],
  );
}
