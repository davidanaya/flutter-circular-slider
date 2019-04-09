import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/src/base_painter.dart';
import 'package:flutter_circular_slider/src/slider_painter.dart';
import 'package:flutter_circular_slider/src/utils.dart';

class CircularSliderPaint extends StatefulWidget {
  final int init;
  final int end;
  final int intervals;
  final int primarySectors;
  final int secondarySectors;
  final Function onSelectionChange;
  final Color baseColor;
  final Color selectionColor;
  final Color handlerColor;
  final double handlerOutterRadius;
  final Widget child;

  CircularSliderPaint(
      {@required this.intervals,
      @required this.init,
      @required this.end,
      this.child,
      @required this.primarySectors,
      @required this.secondarySectors,
      @required this.onSelectionChange,
      @required this.baseColor,
      @required this.selectionColor,
      @required this.handlerColor,
      @required this.handlerOutterRadius});

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSliderPaint> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  SliderPainter _painter;

  /// start angle in radians where we need to locate the init handler
  double _startAngle;

  /// end angle in radians where we need to locate the end handler
  double _endAngle;

  /// the absolute angle in radians representing the selection
  double _sweepAngle;

  @override
  void initState() {
    super.initState();
    _calculatePaintData();
  }

  // we need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself
  @override
  void didUpdateWidget(CircularSliderPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.init != widget.init || oldWidget.end != widget.end) {
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
            baseColor: widget.baseColor,
            selectionColor: widget.selectionColor,
            primarySectors: widget.primarySectors,
            secondarySectors: widget.secondarySectors),
        foregroundPainter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  void _calculatePaintData() {
    double initPercent = valueToPercentage(widget.init, widget.intervals);
    double endPercent = valueToPercentage(widget.end, widget.intervals);
    double sweep = getSweepAngle(initPercent, endPercent);

    _startAngle = percentageToRadians(initPercent);
    _endAngle = percentageToRadians(endPercent);
    _sweepAngle = percentageToRadians(sweep.abs());

    _painter = SliderPainter(
      startAngle: _startAngle,
      endAngle: _endAngle,
      sweepAngle: _sweepAngle,
      selectionColor: widget.selectionColor,
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
    var newValue = percentageToValue(percentage, widget.intervals);

    if (_isInitHandlerSelected) {
      widget.onSelectionChange(newValue, widget.end);
    } else {
      widget.onSelectionChange(widget.init, newValue);
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
}
