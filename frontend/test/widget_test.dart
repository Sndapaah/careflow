import 'package:careflow_app/app/app.dart';
import 'package:careflow_app/core/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await configureDependencies();
  });

  testWidgets('opens on the welcome screen with both entry actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CareFlowApp());
    await tester.pump();

    expect(find.text('Welcome To CareFlow'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign Up'), findsOneWidget);
  });

  testWidgets('welcome screen routes through to the login form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CareFlowApp());
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
