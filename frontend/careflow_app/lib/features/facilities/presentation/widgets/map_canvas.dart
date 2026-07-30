import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder for the live map surface.
///
/// Everything drawn on top of the map — pins, callouts, the route pill, the
/// bottom sheet — is real UI. Only the tiles are simulated, so swapping this
/// widget for a `GoogleMap` (or any tile provider) is the single change
/// needed to go live.
class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(child: CustomPaint(painter: _MapPainter()));
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  static const Color _park = Color(0xFFDCEBDC);
  static const Color _water = Color(0xFFCFE0EC);
  static const Color _road = Color(0xFFFAFBFC);
  static const Color _roadEdge = Color(0xFFDDE3E8);
  static const Color _block = Color(0xFFE2E7EB);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.mapSurface);

    Rect frac(double l, double t, double r, double b) =>
        Rect.fromLTRB(l * w, t * h, r * w, b * h);

    // Green spaces.
    for (final Rect park in <Rect>[
      frac(0.46, 0.02, 0.92, 0.30),
      frac(0.04, 0.34, 0.30, 0.46),
      frac(0.62, 0.55, 0.98, 0.72),
      frac(0.10, 0.74, 0.34, 0.88),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(park, const Radius.circular(10)),
        Paint()..color = _park,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        frac(-0.05, 0.86, 0.06, 1.05),
        const Radius.circular(14),
      ),
      Paint()..color = _water,
    );

    // City blocks.
    for (final Rect block in <Rect>[
      frac(0.34, 0.36, 0.56, 0.50),
      frac(0.06, 0.52, 0.26, 0.66),
      frac(0.40, 0.76, 0.62, 0.92),
      frac(0.74, 0.36, 0.96, 0.48),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(8)),
        Paint()..color = _block,
      );
    }

    // Road network: a wide casing stroke under a narrow fill stroke.
    final List<List<Offset>> roads = <List<Offset>>[
      <Offset>[
        Offset(0, 0.32 * h),
        Offset(0.34 * w, 0.32 * h),
        Offset(0.44 * w, 0.24 * h),
        Offset(w, 0.16 * h),
      ],
      <Offset>[
        Offset(0, 0.68 * h),
        Offset(0.28 * w, 0.66 * h),
        Offset(0.58 * w, 0.72 * h),
        Offset(w, 0.66 * h),
      ],
      <Offset>[
        Offset(0.30 * w, 0),
        Offset(0.32 * w, 0.40 * h),
        Offset(0.26 * w, 0.74 * h),
        Offset(0.30 * w, h),
      ],
      <Offset>[
        Offset(0.66 * w, 0),
        Offset(0.64 * w, 0.36 * h),
        Offset(0.70 * w, 0.70 * h),
        Offset(0.66 * w, h),
      ],
      <Offset>[
        Offset(0.06 * w, 0.96 * h),
        Offset(0.44 * w, 0.62 * h),
        Offset(0.78 * w, 0.30 * h),
        Offset(w, 0.10 * h),
      ],
    ];

    final Paint casing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _roadEdge;

    final Paint surface = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _road;

    for (final List<Offset> road in roads) {
      final Path path = Path()..moveTo(road.first.dx, road.first.dy);
      for (final Offset point in road.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas
        ..drawPath(path, casing)
        ..drawPath(path, surface);
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

/// The blue driving route drawn from the user's dot to the facility pin.
class MapRouteOverlay extends StatelessWidget {
  const MapRouteOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(child: CustomPaint(painter: _RoutePainter()));
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path route = Path()
      ..moveTo(0.72 * w, 0.72 * h)
      ..lineTo(0.40 * w, 0.72 * h)
      ..lineTo(0.36 * w, 0.62 * h)
      ..lineTo(0.26 * w, 0.44 * h)
      ..lineTo(0.22 * w, 0.36 * h);

    canvas
      ..drawPath(
        route,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.primary.withValues(alpha: 0.35),
      )
      ..drawPath(
        route,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.primary,
      );
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => false;
}
