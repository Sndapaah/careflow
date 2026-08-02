import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/widgets/social_auth_row.dart';
import '../../domain/entities/auth_user.dart';
import '../bloc/login_bloc.dart';
import '../widgets/auth_footer_prompt.dart';
import '../../../../core/utils/field_validators.dart';
import '../../../../core/widgets/validated_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => sl<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  static const EdgeInsets _inset = EdgeInsets.symmetric(horizontal: 40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listenWhen: (LoginState previous, LoginState current) =>
              previous.status != current.status,
          listener: (BuildContext context, LoginState state) {
            if (state.status.isSuccess) {
              context.go(AppRoutes.home);
            } else if (state.status.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (BuildContext context, LoginState state) {
            final LoginBloc bloc = context.read<LoginBloc>();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: AppSpacing.xxxl),
                  CareFlowLogoMark(
                    logoSize: 150,
                    titleStyle: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.display.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding: _inset,
                    child: Column(
                      children: <Widget>[
                        ValidatedField(
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: FieldValidators.email,
                          onChanged: (String value) => bloc.add(LoginEmailChanged(value)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ValidatedField(
                          hint: 'Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: FieldValidators.password,
                          onChanged: (String value) => bloc.add(LoginPasswordChanged(value)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'Login',
                          borderRadius: AppRadius.xs,
                          isLoading: state.status.isLoading,
                          onPressed: () => bloc.add(const LoginSubmitted()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: OrDivider(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SocialAuthRow(
                    onGoogle: () => bloc.add(
                      const LoginWithProviderPressed(SocialProvider.google),
                    ),
                    onFacebook: () => bloc.add(
                      const LoginWithProviderPressed(SocialProvider.facebook),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AuthFooterPrompt(
                    // question: 'Already have an account?',
                    // action: 'Login',
                    question: 'Don\'t have an account?',
                    action: 'Sign Up',
                    onTap: () => context.go(AppRoutes.register),
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
