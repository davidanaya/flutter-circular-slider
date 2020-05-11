

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CircularSliderSweepDecoration {
  final double sliderStrokeWidth;

  /// A 2D sweep gradient.
  ///
  /// {@tool snippet}
  ///
  /// This sample takes the above gradient and rotates it by radians,
  /// i.e. 45 degrees.
  ///
  /// ```dart
  /// new SweepGradient(
  ///       startAngle: 3 * pi / 2,
  ///       endAngle: 7 * pi / 2,
  ///       tileMode: TileMode.repeated,
  ///       colors: [Colors.blue, Colors.red],
  ///     )
  /// ```
  /// {@end-tool}
  final SweepGradient gradient;
  final bool useRoundedCap;
  final Color color;

  double getRadius (double width, double height) => min(width / 2, height / 2) - sliderStrokeWidth;

  CircularSliderSweepDecoration({@required this.sliderStrokeWidth, this.gradient, this.color, this.useRoundedCap = true})
  : assert((gradient == null && color == null) ? false : true, 'either a color or gradient must be provided too allow sweep drawing'),
  assert((gradient != null && color != null) ? false : true, 'color is not needed when a gradient is defined');

  paint(Canvas canvas, Size size, Offset center, double startAngle, double sweepAngle) {
    var sweepRect = Rect.fromCircle(center: center, radius: getRadius(size.width, size.height));
    Paint progress = _getPaint(rect: sweepRect);
    canvas.drawArc(sweepRect, -pi / 2 + startAngle, sweepAngle, false, progress);
  }

  Paint _getPaint({double width, PaintingStyle style, Rect rect}) {
    var paint = Paint()
        ..strokeCap =
            useRoundedCap ? StrokeCap.round : StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;

    if(color != null)
      paint..color = color;
    
    if(gradient != null)
      paint..shader = gradient.createShader(rect);

    return paint;
  }

  CircularSliderSweepDecoration copyWith({
    double sliderStrokeWidth,
    SweepGradient gradient,
    Color color,
  }) {
    return CircularSliderSweepDecoration(
      sliderStrokeWidth: sliderStrokeWidth ?? this.sliderStrokeWidth,
      gradient: gradient ?? this.gradient,
      color: color ?? this.color,
    );
  }
}

///Use this class to define your Slider Handler decoration
class CircularSliderHandlerDecoration {
    ///shape defines the handler default shape could be a square or circle
    ///default shape is circle
    final BoxShape shape;
    
    /// The icon to display on top of the handler
    ///if The [Icon.size] is not provided the default is 30
    /// ```dart
    /// Icon(Icons.filter_tilt_shift, size: iconSize, color: Colors.teal[700]);
    /// ```
    /// {@end-tool}
    final Icon icon;

    ///handler default color
    final Color color;

    ///optional shadow which will get apply to the handler, if not provided there handler will get draw without shadown
    final BoxShadow shadow;
    
    ///default handler radius = 8
    ///when using shape = rectangle, the rect will get generated from Rect.fromCircle
    final double radius;

    ///Helps to define which border you want to apply to the handler shape
    ///
    /// {@tool snippet}
    ///
    /// This sample takes the above gradient and rotates it by radians,
    /// i.e. 45 degrees.
    ///
    /// ```dart
    /// new Border.all(width: 3, color: Colors.green);
    /// new Border(top: BorderSide(width: 3.0, color: Colors.green));
    /// ```
    /// {@end-tool}
    final Border border;

    /// if a value is provided it must be bigger than [this.radius] otherwise it will not draw the expected effect
    /// the outther handler will only get draw when [this.showhandlerOutter] = true.
    /// 
    /// See also:
    ///
    ///  * [this.showhandlerOutter] for additional information
    final double handlerOutterRadius;

    /// draw a outter container for the handler, the outter shape could be either a rectangle or circle
    /// the shape will always match the default handler shape which is control by using the [this.shape] 
    /// default value is always false unless defined
    /// if set to true then the handlerOutterRadius also needs to get set unless you want to use the default value
    /// showhandlerOutter enable then both [this.shadow] and [this.icon] are expected to be null.
    /// we are keeping this as backwards compatibility since similar effect could be generate by using 
    /// 
    /// ```dart
    /// Icon(Icons.filter_tilt_shift, size: iconSize, color: Colors.teal[700]);
    /// ```
    /// {@end-tool}
    final bool showhandlerOutter;

    final bool useRoundedCap;

  CircularSliderHandlerDecoration({
    this.color = Colors.blue,
    this.shape = BoxShape.circle, 
    this.shadow, 
    this.radius = 8,
    this.border,
    this.handlerOutterRadius = 12, 
    this.icon,
    this.useRoundedCap = false,
    this.showhandlerOutter = false}) 
  : assert((showhandlerOutter && shadow != null) ? false : true, 'shadows does not draw well when using the defaul HandlerOutter, try using border instead'),
  assert((showhandlerOutter && icon != null) ? false : true, 'handlerOutterRadius can not be use in convination with icon'),
  assert((!showhandlerOutter || (showhandlerOutter && handlerOutterRadius > radius)) ? true : false, 'when using handlerOutterRadius needs to be bigger than radius value');

  void paint(Canvas canvas, Offset center,)
  {
    var handler = _getPaint(color: this.color, width: this.radius, style: PaintingStyle.fill);
    var rect = Rect.fromCircle(center: center, radius: this.radius);
    
    _drawShadow(canvas, center);
      
    if(shape == BoxShape.circle){
      canvas.drawCircle(center, this.radius, handler);
    }
    else {
      var path = Path()..addRect(rect);
      canvas.drawPath(path, handler);
    }

    _drawHandlerOutter(canvas, center);

    //draw the border when enabled
    if(border != null) 
      border.paint(canvas, rect, shape: shape);

    _drawIcon(canvas, center);
  }

  ///This method owns drawing the default outter handler which could be another circle 
  ///or a rectangle depending on the shape parameter
  void _drawHandlerOutter(Canvas canvas, Offset center)
  {
    if(!this.showhandlerOutter)
      return;

    Paint handlerOutter = _getPaint(color: this.color, width: 2.0); 
    if(shape == BoxShape.circle){
      canvas.drawCircle(center, this.handlerOutterRadius, handlerOutter);
    }
    else {
      var parent = Path()
      ..addRect(Rect.fromCircle(center: center, radius: this.handlerOutterRadius));
      
      canvas.drawPath(parent, handlerOutter);
    }
  }

  void _drawShadow(Canvas canvas, Offset center)
  {
      if(shadow == null)
        return;

      var parent = Path();
      if(shape == BoxShape.circle)
        parent..addOval(Rect.fromCircle(center: center, radius: this.radius + shadow.spreadRadius));
      else
        parent..addRect(Rect.fromCircle(center: center, radius: this.radius + shadow.spreadRadius));

      Paint shadowPaint = Paint() 
          ..color = shadow.color.withOpacity(.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(shadow.blurRadius + shadow.spreadRadius));

      canvas.drawPath(parent, shadowPaint);
  }

  ///use this method to create a TextPainter which owns drawing a Icon in the canvas, 
  ///the icon will get added in the center of the handler
  ///the icon will be on top of any other shape drew.
  void _drawIcon(Canvas canvas, Offset center)
  {
    if(this.icon == null)
      return;

    var iconSize = this.icon.size ?? 30.0;

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
        recognizer: TapGestureRecognizer()..onTap = () => print("The word touched is"),
        text: String.fromCharCode(icon.icon.codePoint),
        style: TextStyle(
          color: Colors.black, 
        fontSize: iconSize, 
        fontFamily: icon.icon.fontFamily));
    textPainter.layout();

    //Radius of inner circle or the icon is x/2
    var val = iconSize /2;

    textPainter.paint(canvas, Offset(center.dx - val, center.dy - val));
  }

  Paint _getPaint({@required Color color, @required double width, PaintingStyle style}) =>
    Paint()
      ..color = color
      ..strokeCap =
          useRoundedCap ? StrokeCap.round : StrokeCap.butt
      ..style = style ?? PaintingStyle.stroke
      ..strokeWidth = width;

  CircularSliderHandlerDecoration copyWith({
    BoxShape shape,
    Icon icon,
    Color color,
    BoxShadow shadow,
    double radius,
    Border border,
    double handlerOutterRadius,
    bool showRoundedCapInSelection,
  }) {
    return CircularSliderHandlerDecoration(
      shape: shape ?? this.shape,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      shadow: shadow ?? this.shadow,
      radius: radius ?? this.radius,
      border: border ?? this.border,
      handlerOutterRadius: handlerOutterRadius ?? this.handlerOutterRadius,
      useRoundedCap: showRoundedCapInSelection ?? this.useRoundedCap,
    );
  }
}

class CircularSliderDeviderDecoration {
  ///defines the divider's color
  ///Default value: [Colors.blue]
  final Color color;
  
  ///indicates the size of the devider
  ///Default value: 10
  final double size;

  ///indicates the width of the devider
  ///Default value: 2
  final double width;

  ///change this to modify the sides of the deviders
  ///[true] == StrokeCap.round 
  ///[false] == StrokeCap.butt
  final bool useRoundedCap;

  CircularSliderDeviderDecoration({
    this.color = Colors.grey, 
    this.size = 6.0,
    this.width = 2.0,
    this.useRoundedCap = true
    }) :
    assert(size > 0, "attribute [primaryDeviderSize] needs to be bigger than 0");

  CircularSliderDeviderDecoration copyWith({
    Color color,
    double size,
    double width,
  }) {
    return CircularSliderDeviderDecoration(
      color: color ?? this.color,
      size: size ?? this.size,
      width: width ?? this.width,
    );
  }
}

class CircularSliderClockNumberDecoration
{
  ///Set to true to enable clock numbers 
  ///default value: false
  final bool showNumberIndicators;

  ///play with this number to define reduce the font size of the clock number
  ///default value: 0.7
  final double textScaleFactor;

  ///play with this number to define the location of the clock number
  ///default value: 0.9
  final double scaleFactor;

  ///Optional Style to be applied to the the "12" number in the clock when clock is enable
  ///if not need then set color to transparent
  ///default value: NULL
  ///See also:
  /// * getDefaultTextStyle
  TextStyle style12;

  ///Optional Style to be applied to the the "12" number in the clock when clock is enable
  ///if not need then set color to transparent
  ///default value: NULL
  ///See also:
  /// * getDefaultTextStyle
  TextStyle style3;

  ///Optional Style to be applied to the the "12" number in the clock when clock is enable
  ///if not need then set color to transparent
  ///default value: NULL
  ///See also:
  /// * getDefaultTextStyle
  TextStyle style6;

  ///Optional Style to be applied to the the "12" number in the clock when clock is enable
  ///if not need then set color to transparent
  ///default value: NULL
  ///See also:
  /// * getDefaultTextStyle
  TextStyle style9;

  ///Optional, defines the font size to use when the a Style is not define,
  ///default value: 18
  double defaultFontSize;
  
  ///Optional, defines the main color to get use when the a Style is not define,
  ///default value: [Colors.black]
  Color defaultTextColor;

  CircularSliderClockNumberDecoration({
    this.showNumberIndicators = false, 
    this.textScaleFactor  = 0.7, 
    this.scaleFactor = 0.9, 
    this.style12, 
    this.style3, 
    this.style6, 
    this.style9,
    this.defaultFontSize = 18,
    this.defaultTextColor = Colors.black,
    });

  ///this method will be call any time any style [style12, style3, style6, style9] is not defined  
  ///[defaultFontSize] Optional, defines the font size to use when the a Style is not define,
  ///default value: 18
  ///[defaultTextColor] Optional, defines the main color to get use when the a Style is not define,
  ///default value: [Colors.black]
  TextStyle getDefaultTextStyle() {
    return TextStyle(
        color: defaultTextColor,
        fontWeight: FontWeight.bold,
        fontSize: defaultFontSize * scaleFactor * textScaleFactor);
  }

  CircularSliderClockNumberDecoration getDefaultDecoration() {
    return CircularSliderClockNumberDecoration(
    style12: getDefaultTextStyle(),
    style3: getDefaultTextStyle(),
    style6: getDefaultTextStyle(),
    style9: getDefaultTextStyle(),
    );
  }
}

class CircularSliderDecoration {
    ///defines the background color of the slider
    ///Default Value: [Colors.cyanAccent]
    final Color baseColor;

    ///Provides decoration options which will get applied to the internal clock's numbers when enable
    ///Default Value: NULL
    final CircularSliderClockNumberDecoration clockNumberDecoration;
    
    ///this optional decorator provides option which will get applied to the second Divider when enable
    ///if [DoubleCircularSlider.primarySectors] is not defined then this setting are not needed
    ///when [DoubleCircularSlider.primarySectors] is set, and secondDeviderDecoration == null the deviders will use default values from [CircularSliderDeviderDecoration]
    ///Default Value: NULL
    ///
    ///See also:
    /// * CircularSliderDeviderDecoration
    final CircularSliderDeviderDecoration mainDeviderDecoration;
    
    ///this optional decorator provides option which will get applied to the second Divider when enable
    ///if [secondarySectors] is not defined then this setting are not needed
    ///when [secondarySectors] is set, and secondDeviderDecoration == null the deviders will use default values from [CircularSliderDeviderDecoration]
    ///Default Value: NULL
    ///
    ///See also:
    /// * CircularSliderDeviderDecoration
    final CircularSliderDeviderDecoration secondDeviderDecoration;
    
    ///
    final CircularSliderSweepDecoration sweepDecoration;

    ///
    final CircularSliderHandlerDecoration initHandlerDecoration;
    
    ///
    final CircularSliderHandlerDecoration endHandlerDecoration;

  CircularSliderDecoration(this.sweepDecoration, {
    @required this.endHandlerDecoration,
    this.mainDeviderDecoration,
    this.secondDeviderDecoration,
    this.initHandlerDecoration, 
    this.baseColor = Colors.cyanAccent,
    this.clockNumberDecoration, 
    });

  CircularSliderDecoration copyWith({
    CircularSliderSweepDecoration sweepDecoration,
    CircularSliderHandlerDecoration endHandlerDecoration,
    CircularSliderDeviderDecoration prdDeviderDecoration,
    CircularSliderDeviderDecoration sndDeviderDecoration,
    CircularSliderHandlerDecoration initHandlerDecoration,
    CircularSliderClockNumberDecoration clockIndicatorDecoration,
    Color baseColor,
  }) {
    return CircularSliderDecoration(
      sweepDecoration ?? this.sweepDecoration,
      mainDeviderDecoration: prdDeviderDecoration ?? this.mainDeviderDecoration,
      secondDeviderDecoration: sndDeviderDecoration ?? this.secondDeviderDecoration,
      baseColor: baseColor ?? this.baseColor,
      initHandlerDecoration: initHandlerDecoration ?? this.initHandlerDecoration,
      endHandlerDecoration: endHandlerDecoration ?? this.endHandlerDecoration,
      clockNumberDecoration: clockIndicatorDecoration ?? this.clockNumberDecoration,
    );
  }
}
