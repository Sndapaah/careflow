import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// The green percentage + ring pairing used for AI confidence scores.
class ConfidenceScore extends StatelessWidget {
  const ConfidenceScore({
    super.key,
    required this.percent,
    this.size = 26,
    this.textStyle,
  });

  /// 0..100
  final int percent;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$percent%',
          style:
              textStyle ??
              AppTextStyles.statValue.copyWith(color: AppColors.success),
        ),
        const SizedBox(width: AppSpacing.xs),
        ConfidenceRing(percent: percent, size: size),
      ],
    );
  }
}

/// Just the ring, without the numeric label.
class ConfidenceRing extends StatelessWidget {
  const ConfidenceRing({
    super.key,
    required this.percent,
    this.size = 26,
    this.color = AppColors.success,
    this.strokeWidth = 3,
  });

  final int percent;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (percent.clamp(0, 100)) / 100,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.18);

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
