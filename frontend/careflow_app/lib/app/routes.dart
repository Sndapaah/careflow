import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/onboarding/screens/profile_setup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/symptoms/screens/symptom_form_screen.dart';
import '../features/analysis/screens/analysis_screen.dart';
import '../features/hospitals/screens/recommendation_screen.dart';
import '../features/maps/screens/map_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/dashboard/screens/hospital_dashboard_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/profile-setup': (context) => const ProfileSetupScreen(),
  '/home': (context) => const HomeScreen(),
  '/symptoms': (context) => const SymptomFormScreen(),
  '/analysis': (context) => const AnalysisScreen(),
  '/recommendations': (context) => const RecommendationScreen(),
  '/map': (context) => const MapScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/dashboard': (context) => const HospitalDashboardScreen(),
};