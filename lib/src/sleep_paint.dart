import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_clock_slider/src/sleep_painter.dart';

class SleepPaint extends StatefulWidget {
  final int initTime;
  final int endTime;
  final Function onTimeChange;
  final Color baseClockColor;
  final Color selectedClockColor;
  final Color handlerColor;
  final Color textColor;
  final double handlerOutterRadius;

  SleepPaint(
      {@required this.initTime,
      @required this.endTime,
      @required this.onTimeChange,
      @required this.baseClockColor,
      @required this.selectedClockColor,
      @required this.handlerColor,
      @required this.textColor,
      @required this.handlerOutterRadius});

  @override
  _SleepPaintState createState() => _SleepPaintState();
}

class _SleepPaintState extends State<SleepPaint> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  SleepPainter _painter;

  // start and end angle in radians where we need to locate the init and end handlers
  double _startAngle;
  double _endAngle;

  // the absolute angle representing the amount of sleep (in radians)
  double _sweepAngle;

  @override
  void initState() {
    super.initState();
    _calculatePaintData();
  }

  // we need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself
  @override
  void didUpdateWidget(SleepPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initTime != widget.initTime ||
        oldWidget.endTime != widget.endTime) {
      _calculatePaintData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _onPanDown,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
              child: Text(
                  '${_formatSleepTime(widget.initTime, widget.endTime)}',
                  style: TextStyle(fontSize: 36.0, color: widget.textColor))),
        ),
      ),
    );
  }

  void _calculatePaintData() {
    double initPercent = _timeToPercentage(widget.initTime);
    double endPercent = _timeToPercentage(widget.endTime);
    double sweep = _getSweep(initPercent, endPercent);

    _startAngle = _percentageToRadians(initPercent);
    _endAngle = _percentageToRadians(endPercent);
    _sweepAngle = _percentageToRadians(sweep.abs());

    _painter = SleepPainter(
      startAngle: _startAngle,
      endAngle: _endAngle,
      sweepAngle: _sweepAngle,
      baseClockColor: widget.baseClockColor,
      selectedClockColor: widget.selectedClockColor,
      handlerColor: widget.handlerColor,
      handlerOutterRadius: widget.handlerOutterRadius,
    );
  }

  _onPanUpdate(DragUpdateDetails details) {
    if (!_isInitHandlerSelected && !_isEndHandlerSelected) {
      return;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details.globalPosition);
    var angle = _coordinatesToRadians(position);
    if (angle == null) {
      return;
    }
    var percentage = _radiansToPercentage(angle);
    var newTime = _percentageToTime(percentage);
    if (_isInitHandlerSelected) {
      widget.onTimeChange(newTime, widget.endTime);
    } else {
      widget.onTimeChange(widget.initTime, newTime);
    }
    print('onPanUpdate $angle --> $percentage');
  }

  _onPanEnd(_) {
    print('onPanEnd');
    _isInitHandlerSelected = false;
    _isEndHandlerSelected = false;
  }

  _onPanDown(DragDownDetails details) {
    if (_painter == null) {
      return;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details.globalPosition);
    if (position != null) {
      _isInitHandlerSelected =
          _isCoordInHandler(position, _painter.initHandler);
      if (!_isInitHandlerSelected) {
        _isEndHandlerSelected =
            _isCoordInHandler(position, _painter.endHandler);
      }
    }
    print(
        'onPanDown, init: $_isInitHandlerSelected, end: $_isEndHandlerSelected');
  }

  bool _isCoordInHandler(Offset point, Offset handler) {
    var isTouching = false;

    isTouching = point.dx < (handler.dx + widget.handlerOutterRadius) &&
        point.dx > (handler.dx - widget.handlerOutterRadius) &&
        point.dy < (handler.dy + widget.handlerOutterRadius) &&
        point.dy > (handler.dy - widget.handlerOutterRadius);

    return isTouching;
  }

  String _formatSleepTime(int init, int end) {
    var sleepTime = end > init ? end - init : 288 - init + end;
    var hours = sleepTime ~/ 12;
    var minutes = (sleepTime % 12) * 5;
    return '${hours}h${minutes}m';
  }

  double _getSweep(double init, double end) {
    if (end > init) {
      return end - init;
    }
    return (100 - init + end).abs();
  }

  double _percentageToRadians(double percentage) =>
      ((2 * pi * percentage) / 100);

  double _coordinatesToRadians(Offset position) {
    if (_painter.center == null) {
      return null;
    }
    var dx = position.dx - _painter.center.dx;
    var dy = _painter.center.dy - position.dy;
    return atan2(dy, dx);
  }

  double _radiansToPercentage(double angle) {
    var normalized = angle < 0 ? -angle : 2 * pi - angle;
    var percentage = ((100 * normalized) / (2 * pi));
    // TODO we have an inconsistency of pi/2 in terms of percentage and radians
    return (percentage + 25) % 100;
  }

  double _timeToPercentage(int time) => (time / 288) * 100;

  int _percentageToTime(double percentage) => (percentage * 288) ~/ 100;
}
