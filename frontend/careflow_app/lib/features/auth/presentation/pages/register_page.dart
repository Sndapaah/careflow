import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/widgets/social_auth_row.dart';
import '../../domain/entities/auth_user.dart';
import '../bloc/register_bloc.dart';
import '../widgets/auth_footer_prompt.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => sl<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  static const EdgeInsets _inset = EdgeInsets.symmetric(horizontal: 40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listenWhen: (RegisterState previous, RegisterState current) =>
              previous.status != current.status,
          listener: (BuildContext context, RegisterState state) {
            if (state.status.isSuccess) {
              // New accounts go through OTP before the medical questionnaire.
              context.push(AppRoutes.otp);
            } else if (state.status.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (BuildContext context, RegisterState state) {
            final RegisterBloc bloc = context.read<RegisterBloc>();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  CareFlowLogoMark(
                    logoSize: 138,
                    titleStyle: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Create new account',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: _inset,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppTextField(
                          hint: 'Full Name',
                          textInputAction: TextInputAction.next,
                          onChanged: (String v) =>
                              bloc.add(RegisterFullNameChanged(v)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (String v) =>
                              bloc.add(RegisterEmailChanged(v)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          hint: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onChanged: (String v) =>
                              bloc.add(RegisterPhoneChanged(v)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          hint: 'Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onChanged: (String v) =>
                              bloc.add(RegisterPasswordChanged(v)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const _TermsNotice(),
                        const SizedBox(height: AppSpacing.sm),
                        PrimaryButton(
                          label: 'Sign Up',
                          borderRadius: AppRadius.xs,
                          isLoading: state.status.isLoading,
                          onPressed: () => bloc.add(const RegisterSubmitted()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SocialAuthRow(
                    onGoogle: () => bloc.add(
                      const RegisterWithProviderPressed(SocialProvider.google),
                    ),
                    onFacebook: () => bloc.add(
                      const RegisterWithProviderPressed(
                        SocialProvider.facebook,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AuthFooterPrompt(
                    question: 'Already have an account?',
                    action: 'Login',
                    onTap: () => context.go(AppRoutes.login),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AppTextStyles.caption.copyWith(
      fontSize: 12.5,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    final TextStyle link = base.copyWith(color: AppColors.primary);

    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          const TextSpan(text: 'By Signing Up, You Agree To The '),
          TextSpan(text: 'Terms Of Use', style: link),
          const TextSpan(text: ' And '),
          TextSpan(text: 'Privacy Notice', style: link),
        ],
      ),
    );
  }
}
