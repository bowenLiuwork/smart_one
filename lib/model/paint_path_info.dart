import 'package:flutter/material.dart';
import 'package:smart_one/model/Point.dart';

class PaintPathInfo {
  List<Point> pathPoints;
  int pathColorIndex;

  PaintPathInfo(this.pathPoints, this.pathColorIndex);

  void addPoints(List<Point> points) {
    pathPoints.addAll(points);
  }

  Path toPath(double xRatio, yRatio, num offsetX, num offsetY) {
    Path path = new Path();
    for (int i = 0; i < pathPoints.length; i++) {
      Point p = pathPoints[i];
      double x = p.x * xRatio + offsetX;
      double y = p.y * yRatio + offsetY;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }
}
