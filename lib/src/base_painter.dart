import 'dart:math';

import 'package:flutter/material.dart';

class BasePainter extends CustomPainter {
  Color baseClockColor;

  Offset center;
  double radius;

  BasePainter({@required this.baseClockColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint base = _getPaint(color: baseClockColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, base);

    Paint section = _getPaint(color: baseClockColor, width: 2.0);

    _getSectionsOffsets(radius)
        .forEach((o) => canvas.drawLine(center, o, section));
  }

  List<Offset> _getSectionsOffsets(double radius) {
    return [
      Offset(radius, 0.0),
      Offset(radius * 2, radius),
      Offset(0.0, radius),
      Offset(radius, radius * 2)
    ];
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
