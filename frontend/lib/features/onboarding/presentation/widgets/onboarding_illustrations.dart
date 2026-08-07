import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../profile/domain/entities/patient_profile.dart';

/// Flat vector illustrations for the onboarding steps, painted in code so the
/// project stays asset-free. They follow the same outlined style as the rest
/// of the CareFlow artwork.
class GenderAvatar extends StatelessWidget {
  const GenderAvatar({super.key, required this.gender, this.size = 150});

  final Gender gender;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GenderAvatarPainter(gender)),
    );
  }
}

// ------------------------------------------------------------ shared paints

const Color _ink = Color(0xFF16181D);
const Color _skin = Color(0xFFF7D6BC);
const Color _hairDark = Color(0xFF3B4048);
const Color _hairNavy = Color(0xFF1F3B57);
const Color _jacket = Color(0xFFC08A54);
const Color _blouse = Color(0xFF63AEDC);
const Color _paper = Color(0xFFF3F5F7);
const Color _board = Color(0xFFC79463);
const Color _crossRed = Color(0xFFF2506A);
const Color _peanut = Color(0xFF8A5A3B);
const Color _blockPink = Color(0xFFF6B4C0);
const Color _shirtGreen = Color(0xFF7ED07A);
const Color _phoneBody = Color(0xFF6E7278);
const Color _callGreen = Color(0xFF4CAF50);
const Color _bloodRed = Color(0xFFE03B3B);

Paint _stroke(double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..color = _ink;

Paint _fill(Color color) => Paint()..color = color;

class _GenderAvatarPainter extends CustomPainter {
  const _GenderAvatarPainter(this.gender);

  final Gender gender;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint line = _stroke(s * 0.035);
    final Offset head = Offset(0.5 * s, 0.40 * s);
    final double headR = 0.175 * s;

    if (gender == Gender.female) _paintLongHair(canvas, s, line);

    // Neck.
    final Rect neck = Rect.fromLTWH(0.42 * s, 0.50 * s, 0.16 * s, 0.16 * s);
    canvas.drawRect(neck, _fill(_skin));

    _paintTorso(canvas, s, line);

    // Head.
    canvas.drawCircle(head, headR, _fill(_skin));
    canvas.drawCircle(head, headR, line);

    // Ears.
    canvas.drawCircle(Offset(0.32 * s, 0.42 * s), 0.028 * s, _fill(_skin));
    canvas.drawCircle(Offset(0.68 * s, 0.42 * s), 0.028 * s, _fill(_skin));
    canvas.drawCircle(Offset(0.32 * s, 0.42 * s), 0.028 * s, line);
    canvas.drawCircle(Offset(0.68 * s, 0.42 * s), 0.028 * s, line);

    _paintHairCap(canvas, s, line);
  }

  /// Long hair sits behind everything for the female avatar.
  void _paintLongHair(Canvas canvas, double s, Paint line) {
    final RRect hair = RRect.fromRectAndCorners(
      Rect.fromLTRB(0.27 * s, 0.20 * s, 0.73 * s, 0.80 * s),
      topLeft: Radius.circular(0.23 * s),
      topRight: Radius.circular(0.23 * s),
      bottomLeft: Radius.circular(0.10 * s),
      bottomRight: Radius.circular(0.10 * s),
    );
    canvas.drawRRect(hair, _fill(_hairNavy));
    canvas.drawRRect(hair, line);
  }

  void _paintTorso(Canvas canvas, double s, Paint line) {
    final Color colour = gender == Gender.male ? _jacket : _blouse;
    final Path body = Path()
      ..moveTo(0.16 * s, 1.02 * s)
      ..lineTo(0.16 * s, 0.82 * s)
      ..arcToPoint(
        Offset(0.84 * s, 0.82 * s),
        radius: Radius.circular(0.36 * s),
        clockwise: true,
      )
      ..lineTo(0.84 * s, 1.02 * s)
      ..close();

    canvas.drawPath(body, _fill(colour));
    canvas.drawPath(body, line);

    // Collar.
    final Path collar = Path()
      ..moveTo(0.38 * s, 0.63 * s)
      ..lineTo(0.5 * s, 0.78 * s)
      ..lineTo(0.62 * s, 0.63 * s)
      ..lineTo(0.55 * s, 0.60 * s)
      ..lineTo(0.5 * s, 0.68 * s)
      ..lineTo(0.45 * s, 0.60 * s)
      ..close();
    canvas.drawPath(collar, _fill(Colors.white));
    canvas.drawPath(collar, line);

    if (gender == Gender.male) {
      final Path tie = Path()
        ..moveTo(0.5 * s, 0.72 * s)
        ..lineTo(0.555 * s, 0.80 * s)
        ..lineTo(0.5 * s, 1.0 * s)
        ..lineTo(0.445 * s, 0.80 * s)
        ..close();
      canvas.drawPath(tie, _fill(_hairDark));
      canvas.drawPath(tie, line);
    }
  }

  /// The hair that overlaps the top of the head.
  void _paintHairCap(Canvas canvas, double s, Paint line) {
    final Offset head = Offset(0.5 * s, 0.40 * s);
    final double headR = 0.175 * s;
    final Color colour = gender == Gender.male ? _hairDark : _hairNavy;

    final Path cap = Path()
      ..addArc(Rect.fromCircle(center: head, radius: headR), math.pi, math.pi)
      ..lineTo(head.dx + headR, head.dy - headR * 0.15)
      ..arcToPoint(
        Offset(head.dx - headR, head.dy - headR * 0.15),
        radius: Radius.circular(headR * 1.25),
        clockwise: true,
      )
      ..close();

    canvas.drawPath(cap, _fill(colour));
    canvas.drawPath(cap, line);
  }

  @override
  bool shouldRepaint(_GenderAvatarPainter oldDelegate) =>
      oldDelegate.gender != gender;
}

/// Step 2 — a patient beside a medical clipboard.
class ConditionsIllustration extends StatelessWidget {
  const ConditionsIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: const _ConditionsPainter()),
  );
}

class _ConditionsPainter extends CustomPainter {
  const _ConditionsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint line = _stroke(s * 0.028);

    // Patient silhouette behind the board.
    canvas.drawCircle(Offset(0.24 * s, 0.28 * s), 0.11 * s, _fill(_skin));
    canvas.drawCircle(Offset(0.24 * s, 0.28 * s), 0.11 * s, line);
    final Path shoulders = Path()
      ..moveTo(0.05 * s, 0.72 * s)
      ..arcToPoint(
        Offset(0.47 * s, 0.72 * s),
        radius: Radius.circular(0.24 * s),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(shoulders, _fill(_blouse));
    canvas.drawPath(shoulders, line);

    // Clipboard.
    final RRect board = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.32 * s, 0.18 * s, 0.94 * s, 0.94 * s),
      Radius.circular(0.04 * s),
    );
    canvas.drawRRect(board, _fill(_board));
    canvas.drawRRect(board, line);

    final RRect sheet = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.37 * s, 0.24 * s, 0.89 * s, 0.88 * s),
      Radius.circular(0.02 * s),
    );
    canvas.drawRRect(sheet, _fill(_paper));
    canvas.drawRRect(sheet, line);

    // Clip at the top.
    final RRect clip = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.55 * s, 0.13 * s, 0.72 * s, 0.23 * s),
      Radius.circular(0.02 * s),
    );
    canvas.drawRRect(clip, _fill(const Color(0xFFD9DDE2)));
    canvas.drawRRect(clip, line);

    // Red cross on the sheet.
    final Offset c = Offset(0.63 * s, 0.40 * s);
    canvas.drawRect(
      Rect.fromCenter(center: c, width: 0.20 * s, height: 0.075 * s),
      _fill(_crossRed),
    );
    canvas.drawRect(
      Rect.fromCenter(center: c, width: 0.075 * s, height: 0.20 * s),
      _fill(_crossRed),
    );

    // ECG trace.
    final Path ecg = Path()
      ..moveTo(0.31 * s, 0.68 * s)
      ..lineTo(0.52 * s, 0.68 * s)
      ..lineTo(0.58 * s, 0.55 * s)
      ..lineTo(0.65 * s, 0.78 * s)
      ..lineTo(0.71 * s, 0.62 * s)
      ..lineTo(0.76 * s, 0.70 * s)
      ..lineTo(0.83 * s, 0.70 * s);
    canvas.drawPath(ecg, line);
    canvas.drawCircle(
      Offset(0.83 * s, 0.70 * s),
      0.022 * s,
      _fill(const Color(0xFF3ECBE8)),
    );
  }

  @override
  bool shouldRepaint(_ConditionsPainter oldDelegate) => false;
}

/// Step 3 — a "no allergens" sign beside a reacting patient.
class AllergiesIllustration extends StatelessWidget {
  const AllergiesIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: const _AllergiesPainter()),
  );
}

class _AllergiesPainter extends CustomPainter {
  const _AllergiesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint line = _stroke(s * 0.028);

    // Person on the right.
    canvas.drawCircle(Offset(0.68 * s, 0.34 * s), 0.15 * s, _fill(_skin));
    canvas.drawCircle(Offset(0.68 * s, 0.34 * s), 0.15 * s, line);

    final Path hair = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(0.68 * s, 0.34 * s), radius: 0.15 * s),
        math.pi,
        math.pi,
      )
      ..close();
    canvas.drawPath(hair, _fill(const Color(0xFF8A5A3B)));
    canvas.drawPath(hair, line);

    // Eyes and an open mouth — the "reaction".
    canvas.drawCircle(Offset(0.63 * s, 0.34 * s), 0.014 * s, _fill(_ink));
    canvas.drawCircle(Offset(0.73 * s, 0.34 * s), 0.014 * s, _fill(_ink));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0.68 * s, 0.43 * s),
        width: 0.05 * s,
        height: 0.07 * s,
      ),
      _fill(_ink),
    );

    final Path body = Path()
      ..moveTo(0.44 * s, 1.0 * s)
      ..lineTo(0.44 * s, 0.80 * s)
      ..arcToPoint(
        Offset(0.94 * s, 0.80 * s),
        radius: Radius.circular(0.26 * s),
        clockwise: true,
      )
      ..lineTo(0.94 * s, 1.0 * s)
      ..close();
    canvas.drawPath(body, _fill(_shirtGreen));
    canvas.drawPath(body, line);

    // Prohibition sign.
    final Offset ban = Offset(0.28 * s, 0.30 * s);
    final double banR = 0.19 * s;
    canvas.drawCircle(ban, banR, _fill(_blockPink));
    canvas.drawCircle(ban, banR, _stroke(s * 0.055));
    canvas.drawLine(
      Offset(ban.dx - banR * 0.55, ban.dy + banR * 0.55),
      Offset(ban.dx + banR * 0.55, ban.dy - banR * 0.55),
      _stroke(s * 0.055),
    );

    // Peanut.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0.24 * s, 0.78 * s),
        width: 0.28 * s,
        height: 0.24 * s,
      ),
      _fill(_peanut),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0.42 * s, 0.66 * s),
        width: 0.24 * s,
        height: 0.20 * s,
      ),
      _fill(_peanut),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0.24 * s, 0.78 * s),
        width: 0.28 * s,
        height: 0.24 * s,
      ),
      line,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0.42 * s, 0.66 * s),
        width: 0.24 * s,
        height: 0.20 * s,
      ),
      line,
    );
  }

  @override
  bool shouldRepaint(_AllergiesPainter oldDelegate) => false;
}

/// Step 4 — a phone placing an emergency call.
class EmergencyContactIllustration extends StatelessWidget {
  const EmergencyContactIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: const _EmergencyContactPainter()),
  );
}

class _EmergencyContactPainter extends CustomPainter {
  const _EmergencyContactPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint line = _stroke(s * 0.030);

    // Speech bubble with the medical cross.
    final RRect bubble = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.52 * s, 0.28 * s, 0.98 * s, 0.60 * s),
      Radius.circular(0.01 * s),
    );
    canvas.drawRRect(bubble, _fill(const Color(0xFFE4E7F2)));
    canvas.drawRRect(bubble, line);
    final Path tail = Path()
      ..moveTo(0.60 * s, 0.60 * s)
      ..lineTo(0.60 * s, 0.72 * s)
      ..lineTo(0.72 * s, 0.60 * s)
      ..close();
    canvas.drawPath(tail, _fill(const Color(0xFFE4E7F2)));
    canvas.drawPath(tail, line);

    final Offset crossC = Offset(0.79 * s, 0.44 * s);
    canvas.drawCircle(crossC, 0.115 * s, _fill(const Color(0xFFC62828)));
    canvas.drawCircle(crossC, 0.115 * s, line);
    canvas.drawRect(
      Rect.fromCenter(center: crossC, width: 0.13 * s, height: 0.04 * s),
      _fill(Colors.white),
    );
    canvas.drawRect(
      Rect.fromCenter(center: crossC, width: 0.04 * s, height: 0.13 * s),
      _fill(Colors.white),
    );

    // Phone.
    final RRect phone = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.10 * s, 0.22 * s, 0.56 * s, 0.96 * s),
      Radius.circular(0.06 * s),
    );
    canvas.drawRRect(phone, _fill(_phoneBody));
    canvas.drawRRect(phone, line);

    // Notch.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.27 * s, 0.22 * s, 0.39 * s, 0.27 * s),
        Radius.circular(0.02 * s),
      ),
      _fill(_ink),
    );

    // Answer button.
    final Offset call = Offset(0.33 * s, 0.55 * s);
    canvas.drawCircle(call, 0.155 * s, _fill(Colors.white));
    canvas.drawCircle(call, 0.155 * s, line);
    _paintHandset(canvas, call, 0.10 * s, line);

    // Slider at the bottom.
    final RRect slider = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.16 * s, 0.79 * s, 0.50 * s, 0.87 * s),
      Radius.circular(0.04 * s),
    );
    canvas.drawRRect(slider, _fill(Colors.white));
    canvas.drawRRect(slider, line);
    canvas.drawCircle(Offset(0.33 * s, 0.83 * s), 0.045 * s, _fill(_callGreen));
    canvas.drawCircle(Offset(0.33 * s, 0.83 * s), 0.045 * s, line);
  }

  /// A simple handset glyph rotated into the "calling" angle.
  void _paintHandset(Canvas canvas, Offset centre, double r, Paint line) {
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-math.pi / 5);

    final Path handset = Path()
      ..moveTo(-r, -r * 0.9)
      ..lineTo(-r * 0.2, -r * 0.9)
      ..lineTo(-r * 0.2, -r * 0.25)
      ..lineTo(r * 0.2, -r * 0.25)
      ..lineTo(r * 0.2, -r * 0.9)
      ..lineTo(r, -r * 0.9)
      ..lineTo(r, r * 0.3)
      ..arcToPoint(
        Offset(-r, r * 0.3),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..close();

    canvas.drawPath(handset, _fill(_callGreen));
    canvas.drawPath(handset, line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EmergencyContactPainter oldDelegate) => false;
}

/// Step 5 — a blood drop carrying a medical cross.
class BloodTypeIllustration extends StatelessWidget {
  const BloodTypeIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: const _BloodTypePainter()),
  );
}

class _BloodTypePainter extends CustomPainter {
  const _BloodTypePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint line = _stroke(s * 0.032);

    // Teardrop: a circle with a point pulled up to the top.
    final Offset centre = Offset(0.5 * s, 0.60 * s);
    final double r = 0.27 * s;
    final Offset tip = Offset(0.5 * s, 0.10 * s);
    final double theta = math.acos(r / (centre.dy - tip.dy));
    final double right = -math.pi / 2 + theta;

    final Path drop = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(centre.dx + r * math.cos(right), centre.dy + r * math.sin(right))
      ..arcTo(
        Rect.fromCircle(center: centre, radius: r),
        right,
        2 * math.pi - 2 * theta,
        false,
      )
      ..close();

    canvas.drawPath(drop, _fill(_bloodRed));
    canvas.drawPath(drop, line);

    // White cross inside.
    canvas.drawRect(
      Rect.fromCenter(center: centre, width: 0.26 * s, height: 0.085 * s),
      _fill(Colors.white),
    );
    canvas.drawRect(
      Rect.fromCenter(center: centre, width: 0.085 * s, height: 0.26 * s),
      _fill(Colors.white),
    );
  }

  @override
  bool shouldRepaint(_BloodTypePainter oldDelegate) => false;
}
