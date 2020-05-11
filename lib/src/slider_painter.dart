import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'circular_slider_paint.dart' show CircularSliderMode;
import 'circular_slider_decoration.dart';
import 'utils.dart';

class SliderPainter extends CustomPainter {
  CircularSliderMode mode;
  double startAngle;
  double endAngle;
  double sweepAngle;
  CircularSliderDecoration sliderDecorator;

  Offset _initHandler;
  Offset _endHandler;
  Offset _center;
  double _radius;

  Offset get initHandlerCenterLocation => _initHandler;
  Offset get endHandlerCenterLocation => _endHandler;
  Offset get center => _center;
  double get radius => _radius;

  SliderPainter({
    @required this.mode,
    @required this.startAngle,
    @required this.endAngle,
    @required this.sweepAngle,
    @required this.sliderDecorator,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _center = Offset(size.width / 2, size.height / 2);
    _radius = min(size.width / 2, size.height / 2) - sliderDecorator.sweepDecoration.sliderStrokeWidth;

    sliderDecorator.sweepDecoration.paint(canvas, size, center, startAngle, sweepAngle);

    // draw start handler
    if (mode == CircularSliderMode.doubleHandler) {
      _initHandler = radiansToCoordinates(center, -pi / 2 + startAngle, radius);
      sliderDecorator.initHandlerDecoration?.paint(canvas, initHandlerCenterLocation);
    }
    
    // draw end handler
    _endHandler = radiansToCoordinates(center, -pi / 2 + endAngle, radius);
    sliderDecorator.endHandlerDecoration?.paint(canvas, endHandlerCenterLocation);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
