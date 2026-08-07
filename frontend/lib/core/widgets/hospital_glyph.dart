import 'package:flutter/material.dart';

/// Flat illustration of a hospital building, used as the thumbnail on the
/// home strip, the map sheet and every recommendation card.
///
/// Painted in code so the project ships with no image assets.
class HospitalGlyph extends StatelessWidget {
  const HospitalGlyph({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: const _HospitalPainter()),
    );
  }
}

class _HospitalPainter extends CustomPainter {
  const _HospitalPainter();

  static const Color _wall = Color(0xFFE7EDF2);
  static const Color _wallShade = Color(0xFFCFD9E2);
  static const Color _outline = Color(0xFF4A5A69);
  static const Color _roof = Color(0xFFF6B23F);
  static const Color _window = Color(0xFF4FC3F7);
  static const Color _windowFrame = Color(0xFFFFFFFF);
  static const Color _cross = Color(0xFFE53935);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.028
      ..color = _outline;

    Rect r(double l, double t, double rr, double b) =>
        Rect.fromLTRB(l * w, t * h, rr * w, b * h);

    void box(Rect rect, Color fill, {bool outlined = true}) {
      canvas.drawRect(rect, Paint()..color = fill);
      if (outlined) canvas.drawRect(rect, stroke);
    }

    // Side wings.
    box(r(0.04, 0.34, 0.28, 0.94), _wallShade);
    box(r(0.72, 0.34, 0.96, 0.94), _wallShade);

    // Central block and its roof band.
    box(r(0.26, 0.20, 0.74, 0.94), _wall);
    box(r(0.22, 0.14, 0.78, 0.24), _roof);

    // Rooftop sign carrying the cross.
    box(r(0.40, 0.02, 0.60, 0.14), _windowFrame);
    final Rect sign = r(0.40, 0.02, 0.60, 0.14);
    final Paint crossPaint = Paint()..color = _cross;
    canvas.drawRect(
      Rect.fromCenter(
        center: sign.center,
        width: sign.width * 0.62,
        height: sign.height * 0.26,
      ),
      crossPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: sign.center,
        width: sign.width * 0.26,
        height: sign.height * 0.62,
      ),
      crossPaint,
    );

    // Window grid on the central block.
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 2; col++) {
        final double left = 0.33 + col * 0.20;
        final double top = 0.32 + row * 0.20;
        box(r(left, top, left + 0.13, top + 0.13), _window);
      }
    }

    // Wing windows.
    for (int row = 0; row < 2; row++) {
      final double top = 0.42 + row * 0.20;
      box(r(0.09, top, 0.22, top + 0.12), _window);
      box(r(0.78, top, 0.91, top + 0.12), _window);
    }

    // Entrance.
    final Rect door = r(0.41, 0.72, 0.59, 0.94);
    canvas.drawRect(door, Paint()..color = _window);
    canvas.drawRect(door, stroke);
    canvas.drawLine(
      Offset(door.center.dx, door.top),
      Offset(door.center.dx, door.bottom),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_HospitalPainter oldDelegate) => false;
}
