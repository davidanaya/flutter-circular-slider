import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'base_painter.dart';
import 'slider_painter.dart';
import 'utils.dart';

enum CircularSliderMode { singleHandler, doubleHandler }

enum SlidingState { none, endIsBiggerThanStart, endIsSmallerThanStart }

typedef SelectionChanged<T> = void Function(T a, T b, T c);

class CircularSliderPaint extends StatefulWidget {
  late final CircularSliderMode mode;
  late final int init;
  late final int end;
  late final int divisions;
  late final int primarySectors;
  late final int secondarySectors;
  late final SelectionChanged<int> onSelectionChange;
  late final SelectionChanged<int> onSelectionEnd;
  late final Color baseColor;
  late final Color selectionColor;
  late final Color handlerColor;
  late final double handlerOutterRadius;
  late final Widget child;
  late final bool showRoundedCapInSelection;
  late final bool showHandlerOutter;
  late final double sliderStrokeWidth;
  late final bool shouldCountLaps;

  CircularSliderPaint({
    required this.mode,
    required this.divisions,
    required this.init,
    required this.end,
    required this.child,
    required this.primarySectors,
    required this.secondarySectors,
    required this.onSelectionChange,
    required this.onSelectionEnd,
    required this.baseColor,
    required this.selectionColor,
    required this.handlerColor,
    required this.handlerOutterRadius,
    required this.showRoundedCapInSelection,
    required this.showHandlerOutter,
    required this.sliderStrokeWidth,
    required this.shouldCountLaps,
  });

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSliderPaint> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  late SliderPainter _painter;

  /// start angle in radians where we need to locate the init handler
  double _startAngle = 0.0;

  /// end angle in radians where we need to locate the end handler
  double _endAngle = 0.0;

  /// the absolute angle in radians representing the selection
  double _sweepAngle = 0.0;

  /// in case we have a double slider and we want to move the whole selection by clicking in the slider
  /// this will capture the position in the selection relative to the initial handler
  /// that way we will be able to keep the selection constant when moving
  late int _differenceFromInitPoint;

  /// will store the number of full laps (2pi radians) as part of the selection
  int _laps = 0;

  /// will be used to calculate in the next movement if we need to increase or decrease _laps
  SlidingState _slidingState = SlidingState.none;

  bool get isDoubleHandler => widget.mode == CircularSliderMode.doubleHandler;

  bool get isSingleHandler => widget.mode == CircularSliderMode.singleHandler;

  bool get isBothHandlersSelected =>
      _isEndHandlerSelected && _isInitHandlerSelected;

  bool get isNoHandlersSelected =>
      !_isEndHandlerSelected && !_isInitHandlerSelected;

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
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
          () => CustomPanGestureRecognizer(
                onPanDown: _onPanDown,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
              ),
          (CustomPanGestureRecognizer instance) {},
        ),
      },
      child: CustomPaint(
        painter: BasePainter(
          baseColor: widget.baseColor,
          selectionColor: widget.selectionColor,
          primarySectors: widget.primarySectors,
          secondarySectors: widget.secondarySectors,
          sliderStrokeWidth: widget.sliderStrokeWidth,
        ),
        foregroundPainter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  void _calculatePaintData() {
    var initPercent = isDoubleHandler
        ? valueToPercentage(widget.init, widget.divisions)
        : 0.0;
    var endPercent = valueToPercentage(widget.end, widget.divisions);
    var sweep = getSweepAngle(initPercent, endPercent);

    var previousStartAngle = _startAngle;
    var previousEndAngle = _endAngle;

    _startAngle = isDoubleHandler ? percentageToRadians(initPercent) : 0.0;
    _endAngle = percentageToRadians(endPercent);
    _sweepAngle = percentageToRadians(sweep.abs());

    // update full laps if need be
    if (widget.shouldCountLaps) {
      var newSlidingState = _calculateSlidingState(_startAngle, _endAngle);
      if (isSingleHandler) {
        _laps = _calculateLapsForsSingleHandler(
            _endAngle, previousEndAngle, _slidingState, _laps);
        _slidingState = newSlidingState;
      } else {
        // is double handler
        if (newSlidingState != _slidingState) {
          _laps = _calculateLapsForDoubleHandler(
              _startAngle,
              _endAngle,
              previousStartAngle,
              previousEndAngle,
              _slidingState,
              newSlidingState,
              _laps);
          _slidingState = newSlidingState;
        }
      }
    }

    _painter = SliderPainter(
      mode: widget.mode,
      startAngle: _startAngle,
      endAngle: _endAngle,
      sweepAngle: _sweepAngle,
      selectionColor: widget.selectionColor,
      handlerColor: widget.handlerColor,
      handlerOutterRadius: widget.handlerOutterRadius,
      showRoundedCapInSelection: widget.showRoundedCapInSelection,
      showHandlerOutter: widget.showHandlerOutter,
      sliderStrokeWidth: widget.sliderStrokeWidth,
    );
  }

  int _calculateLapsForsSingleHandler(
      double end, double prevEnd, SlidingState slidingState, int laps) {
    if (slidingState != SlidingState.none) {
      if (radiansWasModuloed(end, prevEnd)) {
        var lapIncrement = end < prevEnd ? 1 : -1;
        var newLaps = laps + lapIncrement;
        return newLaps < 0 ? 0 : newLaps;
      }
    }
    return laps;
  }

  int _calculateLapsForDoubleHandler(
      double start,
      double end,
      double prevStart,
      double prevEnd,
      SlidingState slidingState,
      SlidingState newSlidingState,
      int laps) {
    if (slidingState != SlidingState.none) {
      if (!radiansWasModuloed(start, prevStart) &&
          !radiansWasModuloed(end, prevEnd)) {
        var lapIncrement =
            newSlidingState == SlidingState.endIsBiggerThanStart ? 1 : -1;
        var newLaps = laps + lapIncrement;
        return newLaps < 0 ? 0 : newLaps;
      }
    }
    return laps;
  }

  SlidingState _calculateSlidingState(double start, double end) {
    return end > start
        ? SlidingState.endIsBiggerThanStart
        : SlidingState.endIsSmallerThanStart;
  }

  void _onPanUpdate(Offset details) {
    if (!_isInitHandlerSelected && !_isEndHandlerSelected) {
      return;
    }
    if (_painter.center == null) {
      return;
    }
    _handlePan(details, false);
  }

  void _onPanEnd(Offset details) {
    _handlePan(details, true);

    _isInitHandlerSelected = false;
    _isEndHandlerSelected = false;
  }

  void _handlePan(Offset details, bool isPanEnd) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);

    var angle = coordinatesToRadians(_painter.center, position);
    var percentage = radiansToPercentage(angle);
    var newValue = percentageToValue(percentage, widget.divisions);

    if (isBothHandlersSelected) {
      var newValueInit =
          (newValue - _differenceFromInitPoint) % widget.divisions;
      if (newValueInit != widget.init) {
        var newValueEnd =
            (widget.end + (newValueInit - widget.init)) % widget.divisions;
        widget.onSelectionChange(newValueInit, newValueEnd, _laps);
        if (isPanEnd) {
          widget.onSelectionEnd(newValueInit, newValueEnd, _laps);
        }
      }
      return;
    }

    // isDoubleHandler but one handler was selected
    if (_isInitHandlerSelected) {
      widget.onSelectionChange(newValue, widget.end, _laps);
      if (isPanEnd) {
        widget.onSelectionEnd(newValue, widget.end, _laps);
      }
    } else {
      widget.onSelectionChange(widget.init, newValue, _laps);
      if (isPanEnd) {
        widget.onSelectionEnd(widget.init, newValue, _laps);
      }
    }
  }

  bool _onPanDown(Offset details) {
    if (_painter == null) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);

    if (position == null) {
      return false;
    }

    if (isSingleHandler) {
      if (isPointAlongCircle(position, _painter.center, _painter.radius)) {
        _isEndHandlerSelected = true;
        _onPanUpdate(details);
      }
    } else {
      _isInitHandlerSelected = isPointInsideCircle(
          position, _painter.initHandler, widget.handlerOutterRadius);

      if (!_isInitHandlerSelected) {
        _isEndHandlerSelected = isPointInsideCircle(
            position, _painter.endHandler, widget.handlerOutterRadius);
      }

      if (isNoHandlersSelected) {
        // we check if the user pressed in the selection in a double handler slider
        // that means the user wants to move the selection as a whole
        if (isPointAlongCircle(position, _painter.center, _painter.radius)) {
          var angle = coordinatesToRadians(_painter.center, position);
          if (isAngleInsideRadiansSelection(angle, _startAngle, _sweepAngle)) {
            _isEndHandlerSelected = true;
            _isInitHandlerSelected = true;
            var positionPercentage = radiansToPercentage(angle);

            // no need to account for negative values, that will be sorted out in the onPanUpdate
            _differenceFromInitPoint =
                percentageToValue(positionPercentage, widget.divisions) -
                    widget.init;
          }
        }
      }
    }
    return _isInitHandlerSelected || _isEndHandlerSelected;
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function onPanDown;
  final Function onPanUpdate;
  final Function onPanEnd;

  CustomPanGestureRecognizer({
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    if (onPanDown(event.position)) {
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
