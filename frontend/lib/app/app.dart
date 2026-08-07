import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class CareFlowApp extends StatefulWidget {
  const CareFlowApp({super.key});

  @override
  State<CareFlowApp> createState() => _CareFlowAppState();
}

class _CareFlowAppState extends State<CareFlowApp> {
  // Built once: rebuilding the router would reset every navigation stack.
  final GoRouter _router = AppRouter.build();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
