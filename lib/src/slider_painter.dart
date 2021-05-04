import 'dart:math';

import 'package:flutter/material.dart';

import 'circular_slider_paint.dart' show CircularSliderMode;
import 'utils.dart';

class SliderPainter extends CustomPainter {
  CircularSliderMode mode;
  double startAngle;
  double endAngle;
  double sweepAngle;
  Color selectionColor;
  Color handlerColor;
  double handlerOutterRadius;
  bool showRoundedCapInSelection;
  bool showHandlerOutter;
  double sliderStrokeWidth;

  late Offset initHandler;
  late Offset endHandler;
  late Offset center;
  late double radius;

  SliderPainter({
    required this.mode,
    required this.startAngle,
    required this.endAngle,
    required this.sweepAngle,
    required this.selectionColor,
    required this.handlerColor,
    required this.handlerOutterRadius,
    required this.showRoundedCapInSelection,
    required this.showHandlerOutter,
    required this.sliderStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint progress = _getPaint(color: selectionColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2) - sliderStrokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + startAngle, sweepAngle, false, progress);

    Paint handler = _getPaint(color: handlerColor, style: PaintingStyle.fill);
    Paint handlerOutter = _getPaint(color: handlerColor, width: 2.0);

    // draw handlers
    if (mode == CircularSliderMode.doubleHandler) {
      initHandler = radiansToCoordinates(center, -pi / 2 + startAngle, radius);
      canvas.drawCircle(initHandler, 8.0, handler);
      canvas.drawCircle(initHandler, handlerOutterRadius, handlerOutter);
    }

    endHandler = radiansToCoordinates(center, -pi / 2 + endAngle, radius);
    canvas.drawCircle(endHandler, 8.0, handler);
    if (showHandlerOutter) {
      canvas.drawCircle(endHandler, handlerOutterRadius, handlerOutter);
    }
  }

  Paint _getPaint({required Color color, double? width, PaintingStyle? style}) =>
      Paint()
        ..color = color
        ..strokeCap =
            showRoundedCapInSelection ? StrokeCap.round : StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
