import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/widgets/social_auth_row.dart';
import '../widgets/auth_footer_prompt.dart';

/// Entry screen: brand mark, the two primary paths into the app, and the
/// social sign-in shortcuts.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const EdgeInsets _actionInset = EdgeInsets.symmetric(horizontal: 40);

  void _showComingSoon(BuildContext context, String provider) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$provider sign-in is coming soon.')),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      const Spacer(flex: 2),
                      const CareFlowLogo(size: 150),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Text(
                          'Welcome To CareFlow',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Padding(
                        padding: _actionInset,
                        child: PrimaryButton(
                          label: 'Login',
                          borderRadius: AppRadius.xs,
                          onPressed: () => context.push(AppRoutes.login),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Padding(
                        padding: _actionInset,
                        child: PrimaryButton(
                          label: 'Sign Up',
                          borderRadius: AppRadius.xs,
                          onPressed: () => context.push(AppRoutes.register),
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: OrDivider(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SocialAuthRow(
                        onGoogle: () => _showComingSoon(context, 'Google'),
                        onFacebook: () => _showComingSoon(context, 'Facebook'),
                      ),
                      const Spacer(),
                      AuthFooterPrompt(
                        question: "Don't have an account?",
                        action: 'Sign Up',
                        onTap: () => context.push(AppRoutes.register),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
