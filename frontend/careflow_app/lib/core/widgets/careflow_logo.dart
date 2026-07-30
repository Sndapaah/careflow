import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The CareFlow brand mark: a gradient map pin holding a medical cross, an
/// ECG trace through its stem, and a navy ground plane beneath it.
///
/// Painted rather than shipped as a raster so it stays crisp at every size
/// and the project needs no image assets.
class CareFlowLogo extends StatelessWidget {
  const CareFlowLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: const _CareFlowLogoPainter()),
    );
  }
}

class _CareFlowLogoPainter extends CustomPainter {
  const _CareFlowLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.black;

    _paintGround(canvas, s, outline);
    _paintPin(canvas, s, outline);
    _paintEcg(canvas, s);
    _paintInnerDisc(canvas, s, outline);
    _paintCross(canvas, s, outline);
  }

  /// The flat navy plane the pin stands on.
  void _paintGround(Canvas canvas, double s, Paint outline) {
    final Path ground = Path()
      ..moveTo(0.03 * s, 0.97 * s)
      ..lineTo(0.97 * s, 0.97 * s)
      ..lineTo(0.63 * s, 0.74 * s)
      ..lineTo(0.37 * s, 0.74 * s)
      ..close();

    canvas.drawPath(ground, Paint()..color = AppColors.logoBase);
    canvas.drawPath(ground, outline..strokeWidth = 0.035 * s);
  }

  /// The teardrop body, built from the two tangent lines that run from the
  /// tip up to the head circle.
  void _paintPin(Canvas canvas, double s, Paint outline) {
    const double cxF = 0.5;
    const double cyF = 0.34;
    const double rF = 0.30;
    const double tipF = 0.93;

    final Offset centre = Offset(cxF * s, cyF * s);
    final double r = rF * s;
    final Offset tip = Offset(cxF * s, tipF * s);

    // Angle at the centre between "straight down" and each tangent point.
    final double theta = math.acos(rF / (tipF - cyF));
    final double right = math.pi / 2 - theta;
    final double sweep = -(2 * math.pi - 2 * theta);

    final Path pin = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(centre.dx + r * math.cos(right), centre.dy + r * math.sin(right))
      ..arcTo(Rect.fromCircle(center: centre, radius: r), right, sweep, false)
      ..close();

    final Paint fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[AppColors.logoPinTop, AppColors.logoPinBottom],
      ).createShader(Rect.fromLTWH(0, 0, s, s));

    canvas.drawPath(pin, fill);
    canvas.drawPath(pin, outline..strokeWidth = 0.045 * s);
  }

  /// ECG trace running through the stem of the pin.
  void _paintEcg(Canvas canvas, double s) {
    final List<Offset> points = <Offset>[
      Offset(0.25 * s, 0.66 * s),
      Offset(0.34 * s, 0.66 * s),
      Offset(0.40 * s, 0.50 * s),
      Offset(0.48 * s, 0.82 * s),
      Offset(0.55 * s, 0.58 * s),
      Offset(0.61 * s, 0.70 * s),
      Offset(0.75 * s, 0.70 * s),
    ];

    final Path ecg = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      ecg.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      ecg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05 * s
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = Colors.black,
    );
  }

  void _paintInnerDisc(Canvas canvas, double s, Paint outline) {
    final Offset centre = Offset(0.5 * s, 0.34 * s);
    canvas.drawCircle(
      centre,
      0.165 * s,
      Paint()..color = const Color(0xFF25DCF7),
    );
    canvas.drawCircle(centre, 0.165 * s, outline..strokeWidth = 0.035 * s);
  }

  void _paintCross(Canvas canvas, double s, Paint outline) {
    const double cxF = 0.5;
    const double cyF = 0.34;
    final double cx = cxF * s;
    final double cy = cyF * s;
    final double t = 0.042 * s; // half thickness of an arm
    final double l = 0.115 * s; // half length of an arm

    final Path cross = Path()
      ..moveTo(cx - t, cy - l)
      ..lineTo(cx + t, cy - l)
      ..lineTo(cx + t, cy - t)
      ..lineTo(cx + l, cy - t)
      ..lineTo(cx + l, cy + t)
      ..lineTo(cx + t, cy + t)
      ..lineTo(cx + t, cy + l)
      ..lineTo(cx - t, cy + l)
      ..lineTo(cx - t, cy + t)
      ..lineTo(cx - l, cy + t)
      ..lineTo(cx - l, cy - t)
      ..lineTo(cx - t, cy - t)
      ..close();

    canvas.drawPath(cross, Paint()..color = const Color(0xFFEF2B2B));
    canvas.drawPath(cross, outline..strokeWidth = 0.028 * s);
  }

  @override
  bool shouldRepaint(_CareFlowLogoPainter oldDelegate) => false;
}

/// Logo stacked above the "CareFlow" wordmark, used on the auth screens.
class CareFlowLogoMark extends StatelessWidget {
  const CareFlowLogoMark({
    super.key,
    this.logoSize = 130,
    this.title = 'CareFlow',
    this.titleStyle,
  });

  final double logoSize;
  final String? title;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CareFlowLogo(size: logoSize),
        if (title != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(title!, textAlign: TextAlign.center, style: titleStyle),
        ],
      ],
    );
  }
}
