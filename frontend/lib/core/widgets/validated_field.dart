// lib/core/widgets/validated_field.dart
import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'app_text_field.dart';

class ValidatedField extends StatefulWidget {
  const ValidatedField({
    super.key,
    required this.hint,
    required this.validator,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.variant = AppFieldVariant.neutral,
  });

  final String hint;
  final String? Function(String) validator;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final AppFieldVariant variant;

  @override
  State<ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<ValidatedField> {
  String? _error;
  bool _touched = false;

  void _handleChanged(String value) {
    widget.onChanged(value);
    final String? error = widget.validator(value);
    setState(() {
      _touched = value.isNotEmpty;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _touched && _error == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppTextField(
          hint: widget.hint,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          textInputAction: widget.textInputAction,
          errorText: _error,
          variant: widget.variant,
          onChanged: _handleChanged,
        ),
        if (isValid)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs, left: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  'Looks good',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
      ],
    );
  }
}