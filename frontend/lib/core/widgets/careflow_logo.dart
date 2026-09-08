import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The CareFlow brand mark: a gradient map pin holding a medical cross, an
/// ECG trace through its stem, and a navy ground plane beneath it.
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

/// The fixed ground plane used when animating the pin independently.
class CareFlowLogoGround extends StatelessWidget {
  const CareFlowLogoGround({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: const _CareFlowLogoPainter(paintPin: false)),
    );
  }
}

/// The pin, ECG trace, disc, and cross without the ground plane.
class CareFlowLogoPin extends StatelessWidget {
  const CareFlowLogoPin({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: const _CareFlowLogoPainter(paintGround: false),
      ),
    );
  }
}

/// Loading treatment that keeps the ground fixed while the pin hovers above it.
class CareFlowHoverLogo extends StatefulWidget {
  const CareFlowHoverLogo({super.key, this.size = 120});

  final double size;

  @override
  State<CareFlowHoverLogo> createState() => _CareFlowHoverLogoState();
}

class _CareFlowHoverLogoState extends State<CareFlowHoverLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final double wave = math.sin(_controller.value * math.pi * 2);

        // FIX: Replaced simple additive sizing with a clean containment wrap layout
        return Center(
          child: SizedBox.square(
            dimension: widget.size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip
                  .none, // Prevents layout clipping during animation transforms
              children: <Widget>[
                CareFlowLogoGround(size: widget.size),
                Transform.translate(
                  offset: Offset(
                    0,
                    -(widget.size * 0.05) - (wave * (widget.size * 0.04)),
                  ),
                  child: Transform.scale(
                    scale: 1 + (wave * 0.025),
                    child: CareFlowLogoPin(size: widget.size),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CareFlowLogoPainter extends CustomPainter {
  const _CareFlowLogoPainter({this.paintGround = true, this.paintPin = true});

  final bool paintGround;
  final bool paintPin;

  @override
  void paint(Canvas canvas, Size size) {
    // FIX: Replaced side scaling metrics with an explicit 1:1 box constraint check
    final double s = math.min(size.width, size.height);

    // Centers drawing boundaries inside the box canvas
    final double dx = (size.width - s) / 2;
    final double dy = (size.height - s) / 2;

    canvas.save();
    canvas.translate(dx, dy);

    final Paint outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.black;

    if (paintGround) _paintGround(canvas, s, outline);
    if (paintPin) {
      _paintPin(canvas, s, outline);
      _paintEcg(canvas, s);
      _paintInnerDisc(canvas, s, outline);
      _paintCross(canvas, s, outline);
    }

    canvas.restore();
  }

  void _paintGround(Canvas canvas, double s, Paint outline) {
    final Path ground = Path()
      ..moveTo(
        0.12 * s,
        0.88 * s,
      ) // Adjusted vertical offsets to fit within a strict 1:1 ratio
      ..lineTo(0.88 * s, 0.88 * s)
      ..lineTo(0.63 * s, 0.70 * s)
      ..lineTo(0.37 * s, 0.70 * s)
      ..close();

    canvas.drawPath(ground, Paint()..color = AppColors.logoBase);
    canvas.drawPath(ground, outline..strokeWidth = 0.035 * s);
  }

  void _paintPin(Canvas canvas, double s, Paint outline) {
    const double cxF = 0.5;
    const double cyF =
        0.36; // Lowered circle coordinates down to stay inside borders
    const double rF = 0.28;
    const double tipF = 0.85;

    final Offset centre = Offset(cxF * s, cyF * s);
    final double r = rF * s;
    final Offset tip = Offset(cxF * s, tipF * s);

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

  void _paintEcg(Canvas canvas, double s) {
    // FIX: Adjusted all data points to keep lines balanced within the modified layout geometry
    final List<Offset> points = <Offset>[
      Offset(0.28 * s, 0.63 * s),
      Offset(0.36 * s, 0.63 * s),
      Offset(0.41 * s, 0.48 * s),
      Offset(0.48 * s, 0.76 * s),
      Offset(0.54 * s, 0.55 * s),
      Offset(0.60 * s, 0.66 * s),
      Offset(0.72 * s, 0.66 * s),
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
    final Offset centre = Offset(0.5 * s, 0.36 * s);
    canvas.drawCircle(
      centre,
      0.155 * s,
      Paint()..color = const Color(0xFF25DCF7),
    );
    canvas.drawCircle(centre, 0.155 * s, outline..strokeWidth = 0.035 * s);
  }

  void _paintCross(Canvas canvas, double s, Paint outline) {
    const double cxF = 0.5;
    const double cyF = 0.36;
    final double cx = cxF * s;
    final double cy = cyF * s;
    final double t = 0.038 * s;
    final double l = 0.105 * s;

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
  bool shouldRepaint(_CareFlowLogoPainter oldDelegate) =>
      paintGround != oldDelegate.paintGround ||
      paintPin != oldDelegate.paintPin;
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CareFlowLogo(size: logoSize),
        if (title != null) ...<Widget>[
          const SizedBox(
            height: 12,
          ), // Added extra separation space before the title text
          Text(title!, textAlign: TextAlign.center, style: titleStyle),
        ],
      ],
    );
  }
}
