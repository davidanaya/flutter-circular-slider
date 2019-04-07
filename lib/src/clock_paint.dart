import 'package:flutter/material.dart';
import 'package:flutter_clock_slider/src/base_painter.dart';
import 'package:flutter_clock_slider/src/progress_painter.dart';
import 'package:flutter_clock_slider/src/utils.dart';

class ClockPaint extends StatefulWidget {
  final int initTime;
  final int endTime;
  final Function onTimeChange;
  final Color baseClockColor;
  final Color selectedClockColor;
  final Color handlerColor;
  final Color textColor;
  final double handlerOutterRadius;

  ClockPaint(
      {@required this.initTime,
      @required this.endTime,
      @required this.onTimeChange,
      @required this.baseClockColor,
      @required this.selectedClockColor,
      @required this.handlerColor,
      @required this.textColor,
      @required this.handlerOutterRadius});

  @override
  _ClockPaintState createState() => _ClockPaintState();
}

class _ClockPaintState extends State<ClockPaint> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  ProgressPainter _painter;

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
  void didUpdateWidget(ClockPaint oldWidget) {
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
        painter: BasePainter(
          baseClockColor: widget.baseClockColor,
        ),
        foregroundPainter: _painter,
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
    double initPercent = timeToPercentage(widget.initTime);
    double endPercent = timeToPercentage(widget.endTime);
    double sweep = getSweepAngle(initPercent, endPercent);

    _startAngle = percentageToRadians(initPercent);
    _endAngle = percentageToRadians(endPercent);
    _sweepAngle = percentageToRadians(sweep.abs());

    _painter = ProgressPainter(
      startAngle: _startAngle,
      endAngle: _endAngle,
      sweepAngle: _sweepAngle,
      selectedClockColor: widget.selectedClockColor,
      handlerColor: widget.handlerColor,
      handlerOutterRadius: widget.handlerOutterRadius,
    );
  }

  _onPanUpdate(DragUpdateDetails details) {
    if (!_isInitHandlerSelected && !_isEndHandlerSelected) {
      return;
    }
    if (_painter.center == null) {
      return;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details.globalPosition);

    var angle = coordinatesToRadians(_painter.center, position);
    var percentage = radiansToPercentage(angle);
    var newTime = percentageToTime(percentage);

    if (_isInitHandlerSelected) {
      widget.onTimeChange(newTime, widget.endTime);
    } else {
      widget.onTimeChange(widget.initTime, newTime);
    }
  }

  _onPanEnd(_) {
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
      _isInitHandlerSelected = isPointInsideCircle(
          position, _painter.initHandler, widget.handlerOutterRadius);
      if (!_isInitHandlerSelected) {
        _isEndHandlerSelected = isPointInsideCircle(
            position, _painter.endHandler, widget.handlerOutterRadius);
      }
    }
  }

  String _formatSleepTime(int init, int end) {
    var sleepTime = end > init ? end - init : 288 - init + end;
    var hours = sleepTime ~/ 12;
    var minutes = (sleepTime % 12) * 5;
    return '${hours}h${minutes}m';
  }
}
