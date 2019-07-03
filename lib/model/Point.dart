import 'dart:core';

class Point {
  double x;
  double y;

  Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  String toString() {
    return "${x.floor()},${y.floor()}";
  }
}
