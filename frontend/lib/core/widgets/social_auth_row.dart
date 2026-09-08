import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// "──── or ────" separator on the auth screens.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'or'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// A full-width Google authentication button matching your updated interface.
class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key, this.onGoogle});

  final VoidCallback? onGoogle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA), // Subtle grey-white layout filling
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFCCCCCC), // Light grey outline border
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent, // Inherits container styling boundaries
          child: InkWell(
            onTap: onGoogle,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const _GoogleMark(),
                const SizedBox(width: 12),
                Text(
                  'Google',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
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

/// Natively rendered official Google "G" brand mark asset component.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 24, // Official production size metric
      child: CustomPaint(painter: const _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Scales the official coordinate map to your designated widget frame size
    final double s = size.shortestSide;
    final double scale = s / 48.0;

    canvas.save();
    canvas.scale(scale);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // 1. Official RED Top Quadrant Path
    final Path redPath = Path()
      ..moveTo(24, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
      ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
      ..close();
    canvas.drawPath(redPath, paint..color = const Color(0xFFEA4335));

    // 2. Official BLUE Right Crossbar & Arc Path
    final Path bluePath = Path()
      ..moveTo(46.5, 24)
      ..cubicTo(46.5, 22.37, 46.35, 20.78, 46.08, 19.25)
      ..lineTo(24, 19.25)
      ..lineTo(24, 28.25)
      ..lineTo(36.75, 28.25)
      ..cubicTo(36.2, 31.2, 34.53, 33.7, 32.02, 35.38)
      ..lineTo(39.37, 41.08)
      ..cubicTo(43.72, 36.56, 46.5, 30.8, 46.5, 24)
      ..close();
    canvas.drawPath(bluePath, paint..color = const Color(0xFF4285F4));

    // 3. Official YELLOW Left Arc Path
    final Path yellowPath = Path()
      ..moveTo(10.54, 28.59)
      ..cubicTo(10.06, 27.14, 9.78, 25.6, 9.78, 24)
      ..cubicTo(9.78, 22.4, 10.06, 20.86, 10.54, 19.41)
      ..lineTo(2.56, 13.22)
      ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24)
      ..cubicTo(0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.54, 28.59)
      ..close();
    canvas.drawPath(yellowPath, paint..color = const Color(0xFFFBBC05));

    // 4. Official GREEN Bottom Arc Path
    final Path greenPath = Path()
      ..moveTo(24, 48)
      ..cubicTo(30.48, 48, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.54, 36.49)
      ..cubicTo(30.43, 37.9, 27.73, 38.75, 24, 38.75)
      ..cubicTo(17.74, 38.75, 12.43, 34.53, 10.54, 28.84)
      ..lineTo(2.56, 35.03)
      ..cubicTo(6.51, 42.62, 14.62, 48, 24, 48)
      ..close();
    canvas.drawPath(greenPath, paint..color = const Color(0xFF34A853));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GooglePainter oldDelegate) => false;
}
