import 'package:flutter/material.dart';

import 'package:flutter_clock_slider/src/clock_paint.dart';

class ClockSlider extends StatelessWidget {
  // this represents the initial and end time from 0 to 288
  // each increments represents 5 minutes, and we have 24h
  final int initTime;
  final int endTime;

  // dimensions for the canvas
  final double height;
  final double width;

  // color of the base of the clock (always present)
  final Color baseClockColor;
  final Color selectedClockColor;
  final Color handlerColor;
  final Color textColor;

  // executed when the time changes due to the user moving the slider
  final Function onTimeChange;

  // outter radius for the handlers
  final double handlerOutterRadius;

  ClockSlider(this.initTime, this.endTime,
      {this.height,
      this.width,
      this.baseClockColor,
      this.selectedClockColor,
      this.handlerColor,
      this.textColor,
      this.onTimeChange,
      this.handlerOutterRadius});

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
