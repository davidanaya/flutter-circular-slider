import 'dart:math';

import 'package:flutter/material.dart';

import 'utils.dart';
import 'circular_slider_decoration.dart';

class BasePainter extends CustomPainter {
  CircularSliderDecoration decoration;
  int primarySectors;
  int secondarySectors;
  double sliderStrokeWidth;

  Offset center;
  double radius;

  BasePainter({
    @required this.decoration,
    @required this.primarySectors,
    @required this.secondarySectors,
    @required this.sliderStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint base = _getPaint(color: decoration.baseColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2) - sliderStrokeWidth;
    // we need this in the parent to calculate if the user clicks on the circumference

    assert(radius > 0);

    canvas.drawCircle(center, radius, base);

    if (secondarySectors > 0) {
      _paintSectors(secondarySectors, decoration.secondDeviderDecoration ?? new CircularSliderDeviderDecoration(), canvas);
    }

    if (primarySectors > 0) {
      _paintSectors(primarySectors, decoration.mainDeviderDecoration ?? new CircularSliderDeviderDecoration(size: 6), canvas);
    }

    if(decoration.clockNumberDecoration != null && decoration.clockNumberDecoration.showNumberIndicators)
      _drawNumberIndicators(canvas, size, decoration.clockNumberDecoration);
  }

  List<Offset> _paintSectors(int sectors, CircularSliderDeviderDecoration decoration, Canvas canvas, {List<Offset> skipOffset}) {
    Paint section = _getPaint(color: decoration.color, width: decoration.width, roundedCap : decoration.useRoundedCap);

    var endSectors = getSectionsCoordinatesInCircle(center, radius + decoration.size, sectors);
    var initSectors = getSectionsCoordinatesInCircle(center, radius - decoration.size, sectors);
        
    _paintLines(canvas, initSectors, endSectors, section);

    return initSectors;
  }

  void _paintLines(
      Canvas canvas, List<Offset> inits, List<Offset> ends, Paint section) {
    assert(inits.length == ends.length && inits.length > 0);

    for (var i = 0; i < inits.length; i++) {
      canvas.drawLine(inits[i], ends[i], section);
    }
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style, bool roundedCap = false}) =>
      Paint()
        ..color = color
        ..strokeCap =
          roundedCap ? StrokeCap.round : StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;

///allows the slider to show clock inside the sliders
void _drawNumberIndicators(Canvas canvas, Size size, CircularSliderClockNumberDecoration decoration) {
    double p = 28.0;
    
    Offset paddingX = Offset(p * decoration. scaleFactor, 0.0);
    Offset paddingY = Offset(0.0, p * decoration.scaleFactor);

    var tp12 = getIndicatorText("12", decoration.style12 ?? decoration.getDefaultTextStyle());
    tp12.paint(canvas, size.topCenter(-tp12.size.topCenter(-paddingY)));

    var tp6 = getIndicatorText("6", decoration.style6 ?? decoration.getDefaultTextStyle());
    tp6.paint(canvas, size.bottomCenter(-tp6.size.bottomCenter(paddingY)));

    var tp3 = getIndicatorText("3", decoration.style3 ?? decoration.getDefaultTextStyle());
    tp3.paint(canvas, size.centerRight(-tp3.size.centerRight(paddingX)));

    var tp9 = getIndicatorText("9", decoration.style9 ?? decoration.getDefaultTextStyle());
    tp9.paint(canvas, size.centerLeft(-tp9.size.centerLeft(-paddingX)));
  }

  TextPainter getIndicatorText(String text, TextStyle style)
  {
    TextPainter tp6 = new TextPainter(
        text: new TextSpan(style: style, text: text),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp6.layout();

    return tp6;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
