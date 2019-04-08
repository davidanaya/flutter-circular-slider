import 'dart:math';

import 'package:flutter/material.dart';

class BasePainter extends CustomPainter {
  Color baseColor;

  Offset center;
  double radius;

  BasePainter({@required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint base = _getPaint(color: baseColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, base);
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? 12.0;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
