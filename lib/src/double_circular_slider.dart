import 'dart:math';

import 'package:flutter/material.dart';
import 'circular_slider_paint.dart';
import 'circular_slider_decoration.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are init and end to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
///     DoubleCircularSlider(5, 10, onSelectionChange: () => {});
class DoubleCircularSlider extends StatefulWidget {
  /// the selection will be values between 0..divisions; max value is 300
  final int divisions;

  /// the initial value in the selection
  final int init;

  /// the end value in the selection
  final int end;

  /// the number of primary sectors to be painted
  /// will be painted using selectionColor
  final int primarySectors;

  /// the number of secondary sectors to be painted
  /// will be painted using baseColor
  final int secondarySectors;

  /// an optional widget that would be mounted inside the circle
  final Widget child;

  /// height of the canvas, default at 220
  final double height;

  /// width of the canvas, default at 220
  final double width;

  /// callback function when init and end change
  /// (int init, int end) => void
  final SelectionChanged<int> onSelectionChange;

  /// callback function when init and end finish
  /// (int init, int end) => void
  final SelectionChanged<int> onSelectionEnd;

  /// if true, the onSelectionChange will also return the number of laps in the slider
  /// otherwise, everytime the user completes a full lap, the selection restarts from 0
  /// if set to true, and either init or end is bigger than divisions the Widget will auto calculated the number of laps
  final bool shouldCountLaps;

  final CircularSliderDecoration decoration;

  DoubleCircularSlider(
    this.divisions,
    this.init,
    this.end, {
    this.height,
    this.width,
    this.child,
    this.primarySectors,
    this.secondarySectors,
    this.onSelectionChange,
    this.onSelectionEnd,
    this.decoration,
    this.shouldCountLaps,
  })  : assert((!shouldCountLaps) ? init >= 0 && init <= divisions : true,
            'init has to be > 0 and < divisions value'),
        assert((!shouldCountLaps) ? end >= 0 && end <= divisions : true,
            'end has to be > 0 and < divisions value'),
        assert(divisions >= 0 && divisions <= 300,
            'divisions has to be > 0 and <= 300');

  @override
  _DoubleCircularSliderState createState() => _DoubleCircularSliderState();
}

class _DoubleCircularSliderState extends State<DoubleCircularSlider> {
  int _init;
  int _end;
  
  @override
  void initState() {
    super.initState();
    _init = widget.init;
    _end = widget.end;
  }

  CircularSliderDecoration getDefaultSliderDecorator()
  {
    var dBox = CircularSliderHandlerDecoration(
      color: Colors.lightBlue[900].withOpacity(0.8),
      shape: BoxShape.circle,
      icon: Icon(Icons.filter_tilt_shift, size: 30, color: Colors.teal[700]),
      useRoundedCap: true,
    );

    var iBox = dBox.copyWith();

    var sweepDecoration = CircularSliderSweepDecoration(
      sliderStrokeWidth: 12, 
      gradient: new SweepGradient(
        startAngle: 3 * pi / 2,
        endAngle: 7 * pi / 2,
        tileMode: TileMode.repeated,
        colors: [Colors.blue.withOpacity(0.8), Colors.red.withOpacity(0.8)],
      )
    );
    
    var prdDD = CircularSliderDeviderDecoration(
      color: Colors.blue[200],
      width: 2,
      size: 11,
      useRoundedCap: false
    );

    var sdnDD = CircularSliderDeviderDecoration(
      color: Colors.lightBlue.withOpacity(0.5),
      width: 1,
      size: 6,
    );

    var clock = CircularSliderClockNumberDecoration();

    return CircularSliderDecoration(
      sweepDecoration, 
      clockNumberDecoration:  clock,
      baseColor: Colors.lightBlue[200].withOpacity(0.2),
      mainDeviderDecoration: prdDD,
      secondDeviderDecoration: sdnDD,
      endHandlerDecoration: dBox, initHandlerDecoration: iBox);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 220,
        width: widget.width ?? 220,
        child: CircularSliderPaint(
          mode: CircularSliderMode.doubleHandler,
          init: _init,
          end: _end,
          divisions: widget.divisions,
          primarySectors: widget.primarySectors ?? 0,
          secondarySectors: widget.secondarySectors ?? 0,
          child: widget.child,
          onSelectionChange: (newInit, newEnd, laps) {
            if (widget.onSelectionChange != null) {
              widget.onSelectionChange(newInit, newEnd, laps);
            }
            setState(() {
              _init = newInit;
              _end = newEnd;
            });
          },
          onSelectionEnd: (newInit, newEnd, laps) {
            if (widget.onSelectionEnd != null) {
              widget.onSelectionEnd(newInit, newEnd, laps);
            }
          },
          shouldCountLaps: widget.shouldCountLaps ?? false,
          sliderDecoration: widget.decoration ?? getDefaultSliderDecorator(),
        ));
  }
}
