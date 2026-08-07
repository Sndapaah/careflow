import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Six single-digit boxes that behave as one field: typing advances, deleting
/// steps back, and a pasted code fills every box at once.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.length = 6,
  });

  /// The code the bloc currently holds. Resetting it to '' clears the boxes.
  final String value;
  final ValueChanged<String> onChanged;
  final int length;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (int i) => TextEditingController(
        text: i < widget.value.length ? widget.value[i] : '',
      ),
    );
    _nodes = List<FocusNode>.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(OtpCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only push back when the bloc's value diverges — e.g. after a resend.
    if (widget.value != _code) _syncFromValue();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code =>
      _controllers.map((TextEditingController c) => c.text).join();

  void _syncFromValue() {
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = i < widget.value.length ? widget.value[i] : '';
    }
  }

  void _handleChanged(int index, String raw) {
    // A paste lands entirely in one box; spread it across the remaining ones.
    if (raw.length > 1) {
      final String digits = raw.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i + index < widget.length && i < digits.length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final int next = (index + digits.length).clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
      widget.onChanged(_code);
      return;
    }

    if (raw.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (raw.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    widget.onChanged(_code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(widget.length, (int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: _OtpBox(
            controller: _controllers[index],
            focusNode: _nodes[index],
            onChanged: (String value) => _handleChanged(index, value),
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.accent, width: 1.4),
        boxShadow: AppShadows.subtle,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: AppTextStyles.display.copyWith(fontSize: 30),
        cursorColor: AppColors.accent,
        decoration: const InputDecoration(
          counterText: '',
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
