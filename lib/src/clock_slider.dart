import 'package:flutter/material.dart';

import 'package:flutter_clock_slider/src/clock_paint.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are initTime and endTime to set the initial selection.
/// The clock is a 24h one, and initTime and endTime are used as integer values
/// from 0 to 288 (24h * 12 intervals of 5 min in an hour).
/// onTimeChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
///     ClockSlider(5.0, 10.0, onTimeChange: () => {});
class ClockSlider extends StatelessWidget {
  /// the initial time in the selection
  final int initTime;

  /// the end time in the selection
  final int endTime;

  /// height of the canvas, default at 220
  final double height;

  /// width of the canvas, default at 220
  final double width;

  /// color of the base clock
  final Color baseClockColor;

  /// color of the selection in the clock
  final Color selectedClockColor;

  /// color of the handlers
  final Color handlerColor;

  /// color for the text with the total time selected
  final Color textColor;

  /// callback function when initTime and endTime change
  /// (int initTime, int endTime) => void
  final Function onTimeChange;

  /// outter radius for the handlers
  final double handlerOutterRadius;

  ClockSlider(this.initTime, this.endTime,
      {this.height,
      this.width,
      this.baseClockColor,
      this.selectedClockColor,
      this.handlerColor,
      this.textColor,
      this.onTimeChange,
      this.handlerOutterRadius})
      : assert(
            initTime >= 0 && endTime >= 0 && initTime <= 288 && endTime <= 288,
            'initTime and endTime should both be > 0 and < 288');

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 220,
        width: width ?? 220,
        child: ClockPaint(
          initTime: initTime,
          endTime: endTime,
          onTimeChange: onTimeChange,
          baseClockColor: baseClockColor ?? Color.fromRGBO(255, 255, 255, 0.1),
          selectedClockColor:
              selectedClockColor ?? Color.fromRGBO(255, 255, 255, 0.3),
          handlerColor: handlerColor ?? Colors.white,
          textColor: handlerColor ?? Colors.white,
          handlerOutterRadius: handlerOutterRadius ?? 12.0,
        ));
  }
}
