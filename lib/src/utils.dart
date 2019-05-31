import 'dart:math';
import 'dart:ui';

double percentageToRadians(double percentage) => ((2 * pi * percentage) / 100);

double radiansToPercentage(double radians) {
  var normalized = radians < 0 ? -radians : 2 * pi - radians;
  var percentage = ((100 * normalized) / (2 * pi));
  // TODO we have an inconsistency of pi/2 in terms of percentage and radians
  return (percentage + 25) % 100;
}

double coordinatesToRadians(Offset center, Offset coords) {
  var a = coords.dx - center.dx;
  var b = center.dy - coords.dy;
  return atan2(b, a);
}

Offset radiansToCoordinates(Offset center, double radians, double radius) {
  var dx = center.dx + radius * cos(radians);
  var dy = center.dy + radius * sin(radians);
  return Offset(dx, dy);
}

double valueToPercentage(int time, int intervals) => (time / intervals) * 100;

int percentageToValue(double percentage, int intervals) =>
    (percentage * intervals) ~/ 100;

bool isPointInsideCircle(Offset point, Offset center, double radius) {
  return point.dx < (center.dx + radius) &&
      point.dx > (center.dx - radius) &&
      point.dy < (center.dy + radius) &&
      point.dy > (center.dy - radius);
}

bool isPointAlongCircle(Offset point, double radius) {
  // distance is root(sqr(x2 - x1) + sqr(y2 - y1))
  // i.e., (7,8) and (3,2) -> 7.21
  var d1 = pow(point.dx - radius, 2);
  var d2 = pow(point.dy - radius, 2);
  var distance = sqrt(d1 + d2);
  return (distance - radius).abs() < 10;
}

double getSweepAngle(double init, double end) {
  if (end > init) {
    return end - init;
  }
  return (100 - init + end).abs();
}

List<Offset> getSectionsCoordinatesInCircle(
    Offset center, double radius, int sections) {
  var intervalAngle = (pi * 2) / sections;
  return List<int>.generate(sections, (int index) => index).map((i) {
    var radians = (pi / 2) + (intervalAngle * i);
    return radiansToCoordinates(center, radians, radius);
  }).toList();
}
