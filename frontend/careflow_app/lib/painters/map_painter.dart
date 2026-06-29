import 'package:flutter/material.dart';

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final minorRoad = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 5;

    final park = Paint()
      ..color = Colors.green.shade100;

    final building = Paint()
      ..color = Colors.grey.shade200;

    // Park
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .65,
        size.height * .10,
        120,
        80,
      ),
      park,
    );

    // Buildings
    canvas.drawRect(
      Rect.fromLTWH(40, 220, 80, 60),
      building,
    );

    canvas.drawRect(
      Rect.fromLTWH(280, 180, 100, 70),
      building,
    );

    canvas.drawRect(
      Rect.fromLTWH(180, 500, 90, 80),
      building,
    );

    // Main Road
    canvas.drawLine(
      Offset(0, 350),
      Offset(size.width, 500),
      road,
    );

    // Cross Road
    canvas.drawLine(
      Offset(180, 0),
      Offset(260, size.height),
      road,
    );

    // Minor Roads
    canvas.drawLine(
      Offset(80, 120),
      Offset(300, 300),
      minorRoad,
    );

    canvas.drawLine(
      Offset(50, 650),
      Offset(320, 620),
      minorRoad,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}