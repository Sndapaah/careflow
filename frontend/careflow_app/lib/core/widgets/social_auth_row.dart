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

/// The Google + Facebook button pair shared by Welcome, Login and Sign Up.
class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key, this.onGoogle, this.onFacebook});

  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SocialButton(
              label: 'Google',
              onTap: onGoogle,
              mark: const _GoogleMark(),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: _SocialButton(
              label: 'facebook',
              onTap: onFacebook,
              mark: const _FacebookMark(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.mark, this.onTap});

  final String label;
  final Widget mark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: Container(
          height: 62,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            boxShadow: AppShadows.subtle,
            color: AppColors.surfaceMuted,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              mark,
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google "G" approximated with the four brand colours.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 26,
      child: CustomPaint(painter: const _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Rect rect = Rect.fromLTWH(s * 0.09, s * 0.09, s * 0.82, s * 0.82);
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.22
      ..strokeCap = StrokeCap.butt;

    // Sweeps roughly matching the Google logo quadrants.
    canvas.drawArc(rect, -0.35, -1.55, false, arc..color = AppColors.googleRed);
    canvas.drawArc(
      rect,
      -1.9,
      -1.5,
      false,
      arc..color = const Color(0xFFFBBC05),
    );
    canvas.drawArc(
      rect,
      3.0,
      -1.6,
      false,
      arc..color = const Color(0xFF34A853),
    );
    canvas.drawArc(
      rect,
      -0.35,
      1.35,
      false,
      arc..color = const Color(0xFF4285F4),
    );

    // The horizontal bar of the "G".
    canvas.drawRect(
      Rect.fromLTWH(s * 0.5, s * 0.42, s * 0.42, s * 0.17),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GooglePainter oldDelegate) => false;
}

class _FacebookMark extends StatelessWidget {
  const _FacebookMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColors.facebookBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'f',
        style: AppTextStyles.h3.copyWith(
          color: Colors.white,
          fontSize: 19,
          height: 1.1,
        ),
      ),
    );
  }
}
