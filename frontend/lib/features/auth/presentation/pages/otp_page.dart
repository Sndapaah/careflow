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
import '../bloc/otp_bloc.dart';
import '../widgets/otp_code_field.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpBloc>(
      create: (_) => sl<OtpBloc>()..add(const OtpStarted()),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OtpBloc, OtpState>(
          listenWhen: (OtpState previous, OtpState current) =>
              previous.status != current.status,
          listener: (BuildContext context, OtpState state) {
            if (state.status.isSuccess) {
              context.push(AppRoutes.verified);
            } else if (state.status.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (BuildContext context, OtpState state) {
            final OtpBloc bloc = context.read<OtpBloc>();

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: AppSpacing.xxxl),
                  CareFlowLogoMark(
                    logoSize: 150,
                    title: 'Sign Up',
                    titleStyle: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'OTP Verification',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.accent,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'We have  sent an OTP to your contact',
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OtpCodeField(
                    value: state.code,
                    onChanged: (String code) => bloc.add(OtpCodeChanged(code)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.countdownLabel,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: state.hasExpired
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ResendRow(
                    onResend: () => bloc.add(const OtpResendPressed()),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ContinueAction(
                    isEnabled: state.isComplete,
                    isLoading: state.status.isLoading,
                    onPressed: () => bloc.add(const OtpSubmitted()),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.onResend});

  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Didn't receive the code?",
            style: AppTextStyles.bodyLarge.copyWith(fontSize: 17),
          ),
          GestureDetector(
            onTap: onResend,
            child: Text(
              'Resend',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 17,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the two states in the designs: a plain blue label while the code
/// is incomplete, and a filled button once all six digits are in.
class _ContinueAction extends StatelessWidget {
  const _ContinueAction({
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return TextButton(
        onPressed: onPressed,
        child: Text(
          'Continue',
          style: AppTextStyles.button.copyWith(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return SizedBox(
      width: 264,
      child: PrimaryButton(
        label: 'Continue',
        height: 58,
        borderRadius: AppRadius.xs,
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}
