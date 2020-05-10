import 'dart:math';

import 'package:flutter/material.dart';

import 'circular_slider_paint.dart';

import 'circular_slider_decoration.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are position and divisions to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
///     SingleCircularSlider(5, 10, onSelectionChange: () => {});
class SingleCircularSlider extends StatefulWidget {
  /// the selection will be values between 0..divisions; max value is 300
  final int divisions;

  /// the initial value in the selection
  final int position;

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

  /// color of the base circle and sections
  final Color baseColor;

  /// color of the selection
  final Color selectionColor;

  /// color of the handlers
  final Color handlerColor;

  /// callback function when init and end change
  /// (int init, int end) => void
  final SelectionChanged<int> onSelectionChange;

  /// callback function when init and end finish
  /// (int init, int end) => void
  final SelectionChanged<int> onSelectionEnd;

  /// outter radius for the handlers
  final double handlerOutterRadius;

  /// if true will paint a rounded cap in the selection slider start
  final bool showRoundedCapInSelection;

  /// if true an extra handler ring will be displayed in the handler
  final bool showHandlerOutter;

  /// stroke width for the slider, defaults at 12.0
  final double sliderStrokeWidth;

  /// if true, the onSelectionChange will also return the number of laps in the slider
  /// otherwise, everytime the user completes a full lap, the selection restarts from 0
  final bool shouldCountLaps;

  SingleCircularSlider(
    this.divisions,
    this.position, {
    this.height,
    this.width,
    this.child,
    this.primarySectors,
    this.secondarySectors,
    this.baseColor,
    this.selectionColor,
    this.handlerColor,
    this.onSelectionChange,
    this.onSelectionEnd,
    this.handlerOutterRadius,
    this.showRoundedCapInSelection,
    this.showHandlerOutter,
    this.sliderStrokeWidth,
    this.shouldCountLaps,
  })  : assert(position >= 0 && position <= divisions,
            'init has to be > 0 and < divisions value'),
        assert(divisions >= 0 && divisions <= 300,
            'divisions has to be > 0 and <= 300');

  @override
  _SingleCircularSliderState createState() => _SingleCircularSliderState();
}

class _SingleCircularSliderState extends State<SingleCircularSlider> {
  int _end;

  @override
  void initState() {
    super.initState();
    _end = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 220,
        width: widget.width ?? 220,
        child: CircularSliderPaint(
          mode: CircularSliderMode.singleHandler,
          init: 0,
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
              _end = newEnd;
            });
          },
          onSelectionEnd: (newInit, newEnd, laps) {
            if (widget.onSelectionEnd != null) {
              widget.onSelectionEnd(newInit, newEnd, laps);
            }
          },
          shouldCountLaps: widget.shouldCountLaps ?? false,
          sliderDecoration: getDefaultSliderDecorator(),
        ));
  }


  CircularSliderDecoration getDefaultSliderDecorator()
  {
    var dBox = CircularSliderHandlerDecoration(
      color: Colors.lightBlue[900].withOpacity(0.8),
      shape: BoxShape.circle,
      icon: Icon(Icons.filter_tilt_shift, size: 30, color: Colors.teal[700]),
      useRoundedCap: true,
    );

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
      color: Colors.blue,
      width: 3,
      size: 10,
      useRoundedCap: false
    );

    var sdnDD = prdDD.copyWith(
      width: 1,
      size: 6,
    );

    return CircularSliderDecoration(
      sweepDecoration, 
      baseColor: Colors.lightBlue[200].withOpacity(0.2),
      mainDeviderDecoration: prdDD,
      secondDeviderDecoration: sdnDD,
      endHandlerDecoration: dBox, );
  }
}
