import 'package:careflow_app/core/di/injector.dart';
import 'package:careflow_app/core/theme/app_theme.dart';
import 'package:careflow_app/features/auth/presentation/pages/login_page.dart';
import 'package:careflow_app/features/auth/presentation/pages/otp_page.dart';
import 'package:careflow_app/features/auth/presentation/pages/register_page.dart';
import 'package:careflow_app/features/auth/presentation/pages/verification_success_page.dart';
import 'package:careflow_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:careflow_app/features/facilities/presentation/pages/emergency_page.dart';
import 'package:careflow_app/features/facilities/presentation/pages/facility_detail_page.dart';
import 'package:careflow_app/features/facilities/presentation/pages/map_page.dart';
import 'package:careflow_app/features/facilities/presentation/pages/recommended_facilities_page.dart';
import 'package:careflow_app/features/home/presentation/pages/home_page.dart';
import 'package:careflow_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:careflow_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:careflow_app/features/profile/domain/entities/patient_profile.dart';
import 'package:careflow_app/features/profile/presentation/pages/profile_page.dart';
import 'package:careflow_app/features/symptoms/presentation/pages/ai_analysis_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders every screen at a phone-sized viewport and fails on any layout
/// error (overflow, unbounded constraints, null assertions). This is the
/// cheap safety net that keeps the UI honest without a device attached.
void main() {
  const Size phone = Size(390, 844);

  setUp(() async {
    await sl.reset();
    await configureDependencies();
  });

  Future<void> render(WidgetTester tester, Widget page) async {
    tester.view
      ..physicalSize = phone * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: page));
    // Let the in-memory data sources resolve and the UI settle.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
  }

  final Map<String, Widget> screens = <String, Widget>{
    'welcome': const WelcomePage(),
    'login': const LoginPage(),
    'register': const RegisterPage(),
    'otp': const OtpPage(),
    'verification success': const VerificationSuccessPage(),
    'onboarding': const OnboardingPage(),
    'home': const HomePage(),
    'ai analysis': const AiAnalysisPage(symptoms: <String>['Headache']),
    'recommended facilities': const RecommendedFacilitiesPage(),
    'facility detail': const FacilityDetailPage(
      facilityId: 'university-clinic',
    ),
    'emergency': const EmergencyPage(),
    'map overview': const MapPage(),
    'map focused': const MapPage(focusFacilityId: 'university-hospital'),
    'profile': const ProfilePage(),
  };

  screens.forEach((String name, Widget page) {
    testWidgets('$name renders without layout errors', (
      WidgetTester tester,
    ) async {
      await render(tester, page);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('walks all five onboarding steps without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = phone * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const OnboardingPage()),
    );
    await tester.pump();

    final OnboardingBloc bloc = BlocProvider.of<OnboardingBloc>(
      tester.element(find.byType(Scaffold).first),
    );

    // Answers are supplied through the bloc's public events so the sweep is
    // not coupled to date pickers or bottom sheets.
    final List<List<OnboardingEvent>> answers = <List<OnboardingEvent>>[
      <OnboardingEvent>[
        const OnboardingGenderSelected(Gender.male),
        OnboardingDateOfBirthSelected(DateTime(2004, 3, 26)),
      ],
      <OnboardingEvent>[const OnboardingConditionToggled('Asthma')],
      <OnboardingEvent>[const OnboardingAllergyToggled('Penicillin')],
      <OnboardingEvent>[
        const OnboardingContactChanged(
          fullName: 'Kingsley Hovor',
          relationship: 'Brother',
          phoneNumber: '+233 24 555 0199',
        ),
      ],
    ];

    for (int step = 0; step < answers.length; step++) {
      expect(find.text('${step + 1}/5'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'step ${step + 1}');

      for (final OnboardingEvent event in answers[step]) {
        bloc.add(event);
      }
      await tester.pump();

      bloc.add(const OnboardingNextPressed());
      await tester.pump();
    }

    expect(find.text('5/5'), findsOneWidget);
    expect(find.text('What is your blood type?'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'step 5');
  });
}
