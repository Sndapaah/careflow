import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/cache/user_session_cache.dart';

/// Brand-first startup screen shown while the app prepares its first route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _restoreSession);
  }

  Future<void> _restoreSession() async {
    final String? token = await sl<TokenStorage>().read();
    final Map<String, dynamic>? user = await sl<TokenStorage>().readUser();
    if (user != null) {
      sl<UserSessionCache>().store(user);
    }
    if (!mounted) return;
    context.go(token == null || token.isEmpty ? AppRoutes.welcome : AppRoutes.home);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => FadeTransition(
              opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 176,
                  height: 176,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(44),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: AppColors.shadowStrong, blurRadius: 28, offset: Offset(0, 14)),
                    ],
                  ),
                  child: const CareFlowLogo(size: 132),
                ),
                const SizedBox(height: 28),
                Text('CareFlow', style: AppTextStyles.display.copyWith(fontSize: 32)),
                const SizedBox(height: 8),
                Text('Care, connected.', style: AppTextStyles.bodyMuted),
                const SizedBox(height: 40),
                SizedBox(
                  width: 32,
                  height: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: AppColors.primarySurface,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
