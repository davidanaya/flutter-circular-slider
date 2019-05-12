import 'package:flutter/material.dart';

import 'package:flutter_circular_slider/src/circular_slider_paint.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are init and end to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
///     CircularSlider(5, 10, onSelectionChange: () => {});
class CircularSlider extends StatefulWidget {
  /// the selection will be values between 0..intervals; max value is 300
  final int intervals;

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

  /// color of the base circle and sections
  final Color baseColor;

  /// color of the selection
  final Color selectionColor;

  /// color of the handlers
  final Color handlerColor;

  /// callback function when init and end change
  /// (int init, int end) => void
  final Function onSelectionChange;

  /// callback function when init and end finish
  /// (int init, int end) => void
  final Function onSelectionEnd;

  /// outter radius for the handlers
  final double handlerOutterRadius;

  CircularSlider(this.intervals, this.init, this.end,
      {this.height,
      this.width,
      this.child,
      this.primarySectors,
      this.secondarySectors,
      this.baseColor,
      this.selectionColor,
      this.handlerColor,
      this.onSelectionChange,
      this.onSelectionEnd,
      this.handlerOutterRadius})
      : assert(init >= 0 && init <= intervals,
            'init has to be > 0 and < intervals value'),
        assert(end >= 0 && end <= intervals,
            'end has to be > 0 and < intervals value'),
        assert(intervals >= 0 && intervals <= 300,
            'intervals has to be > 0 and <= 300');

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  int init;
  int end;

  @override
  void initState() {
    super.initState();
    init = widget.init;
    end = widget.end;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 220,
        width: widget.width ?? 220,
        child: CircularSliderPaint(
          init: init,
          end: end,
          intervals: widget.intervals,
          primarySectors: widget.primarySectors ?? 0,
          secondarySectors: widget.secondarySectors ?? 0,
          child: widget.child,
          onSelectionChange: (newInit, newEnd) {
            if (widget.onSelectionChange != null) {
              widget.onSelectionChange(newInit, newEnd);
            }
            setState(() {
              init = newInit;
              end = newEnd;
            });
          },
          onSelectionEnd: (newInit, newEnd) {
            if (widget.onSelectionEnd != null) {
              widget.onSelectionEnd(newInit, newEnd);
            }
          },
          baseColor: widget.baseColor ?? Color.fromRGBO(255, 255, 255, 0.1),
          selectionColor:
              widget.selectionColor ?? Color.fromRGBO(255, 255, 255, 0.3),
          handlerColor: widget.handlerColor ?? Colors.white,
          handlerOutterRadius: widget.handlerOutterRadius ?? 12.0,
        ));
  }
}
