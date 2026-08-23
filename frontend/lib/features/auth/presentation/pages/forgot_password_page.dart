import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/widgets/validated_field.dart';
import '../../../../core/utils/field_validators.dart';
import '../../domain/repositories/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() { _email.dispose(); _otp.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (FieldValidators.email(email) != null || (_sent && (_otp.text.trim().length != 6 || FieldValidators.password(_password.text) != null))) return;
    setState(() => _loading = true);
    try {
      final repo = sl<AuthRepository>();
      if (!_sent) { await repo.requestPasswordReset(email); setState(() => _sent = true); }
      else { await repo.resetPassword(email: email, otp: _otp.text.trim(), password: _password.text); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset. Please log in.'))); context.go(AppRoutes.login); } }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Forgot password')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(children: [
      const SizedBox(height: AppSpacing.lg), const CareFlowLogoMark(logoSize: 110),
      const SizedBox(height: AppSpacing.lg),
      Text(_sent ? 'Enter the code sent to your email and choose a new password.' : 'Enter your email and we will send you a reset code.', textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      ValidatedField(hint: 'Email', keyboardType: TextInputType.emailAddress, validator: FieldValidators.email, onChanged: (v) => _email.text = v),
      if (_sent) ...[
        const SizedBox(height: AppSpacing.md), ValidatedField(hint: '6-digit code', keyboardType: TextInputType.number, validator: (v) => v.length == 6 ? null : 'Enter the 6-digit code', onChanged: (v) => _otp.text = v),
        const SizedBox(height: AppSpacing.md), ValidatedField(hint: 'New password', obscureText: true, validator: FieldValidators.password, onChanged: (v) => _password.text = v),
      ],
      const SizedBox(height: AppSpacing.lg), PrimaryButton(label: _sent ? 'Reset password' : 'Send reset code', isLoading: _loading, onPressed: _submit),
      TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Back to login')),
    ])),
  );
}
