import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// The two field looks in the mockups: a plain grey-outlined input on the
/// auth screens, and a cyan-outlined input during onboarding.
enum AppFieldVariant { neutral, accent }

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.variant = AppFieldVariant.neutral,
    this.textInputAction,
    this.inputFormatters,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final AppFieldVariant variant;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  bool get _isAccent => variant == AppFieldVariant.accent;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _isAccent ? AppColors.accent : AppColors.border;
    final Color hintColor = _isAccent ? AppColors.accent : AppColors.textMuted;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: AppTextStyles.bodyLarge,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: hintColor,
          fontWeight: _isAccent ? FontWeight.w600 : FontWeight.w400,
        ),
        filled: true,
        fillColor: _isAccent ? Colors.transparent : AppColors.surface,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(
            color: _isAccent ? AppColors.accentDark : AppColors.primary,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

/// Read-only field that opens a picker — "Select Date", "Select Relationship
/// Type". Renders the trailing affordance inline like the mockups.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.trailing = Icons.keyboard_arrow_down_rounded,
    this.dividerBeforeTrailing = false,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData trailing;
  final bool dividerBeforeTrailing;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.field,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: AppRadius.field,
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                hasValue ? value! : label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: hasValue ? AppColors.textPrimary : AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (dividerBeforeTrailing)
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.accent,
                indent: 0,
                endIndent: 0,
              ),
            SizedBox(
              width: 62,
              child: Icon(trailing, color: AppColors.accent, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
