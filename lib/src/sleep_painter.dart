import 'dart:math';

import 'package:flutter/material.dart';

class SleepPainter extends CustomPainter {
  double startAngle;
  double endAngle;
  double sweepAngle;
  Color baseClockColor;
  Color selectedClockColor;
  Color handlerColor;
  double handlerOutterRadius;

  Offset initHandler;
  Offset endHandler;
  Offset center;
  double radius;

  SleepPainter(
      {@required this.startAngle,
      @required this.endAngle,
      @required this.sweepAngle,
      @required this.baseClockColor,
      @required this.selectedClockColor,
      @required this.handlerColor,
      @required this.handlerOutterRadius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint base = _getPaint(color: baseClockColor);
    Paint progress = _getPaint(color: selectedClockColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2);

    // draw base circle
    canvas.drawCircle(center, radius, base);

    Paint section = _getPaint(color: selectedClockColor, width: 2.0);
    // draw section lines
    _getSectionsOffsets(radius)
        .forEach((o) => canvas.drawLine(center, o, section));

    if (startAngle == 0.0 && endAngle == 0.0) return;

    // draw progress
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + startAngle, sweepAngle, false, progress);

    Paint handler = _getPaint(color: handlerColor, style: PaintingStyle.fill);
    Paint handlerOutter = _getPaint(color: handlerColor, width: 2.0);

    // draw handlers
    initHandler = _radianToCoordinates(center, -pi / 2 + startAngle, radius);
    canvas.drawCircle(initHandler, 8.0, handler);
    canvas.drawCircle(initHandler, handlerOutterRadius, handlerOutter);

    endHandler = _radianToCoordinates(center, -pi / 2 + endAngle, radius);
    canvas.drawCircle(endHandler, 8.0, handler);
    canvas.drawCircle(endHandler, handlerOutterRadius, handlerOutter);
  }

  Offset _radianToCoordinates(Offset center, double angle, double radius) {
    var dx = center.dx + radius * cos(angle);
    var dy = center.dy + radius * sin(angle);
    return Offset(dx, dy);
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
    return true;
  }
}
