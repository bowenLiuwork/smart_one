import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/model/Point.dart';
import 'package:smart_one/model/paint_path_info.dart';
import 'package:smart_one/widget/draw_color_selected_view.dart';
import 'package:smart_one/widget/draw_view.dart';

class DrawDataManager {
  //单例 --------
  factory DrawDataManager() => _getInstance();

  static DrawDataManager get instance => _getInstance();

  static DrawDataManager _instance;

  DrawDataManager._internal() {
    // 初始化
    SocketHelper.instance.setMessageCallBack(
      onPngImage: _onPngImage,
      onSetBoardPaint: _onsetBoardPatin,
      onSetBlackBoardSize: _onSetBlackBoardSize,
      onPaintPosition: _onPaintPos,
      onPaintPosEnd: _onPaintPosEnd,
      onPaintPosStart: _onPaintPosStart,
      onMediaControl: _onMediaControl,
      onPageInfo: _onPageInfo,
      onOpenMedia: _onOpenMedia,

    );
    _tcpControlHelper = new TcpControlHelper((value) {
      SocketHelper.instance.write(value);
    });
  }

  static DrawDataManager _getInstance() {
    if (_instance == null) {
      _instance = new DrawDataManager._internal();
    }
    return _instance;
  }

//-------------------

  Uint8List image;

  double screenWidth = 0;
  double screenHeight = 0;
  num maxScreenSize = 0;
  num minScreenSize = 0;

  int socketWidth = 1;
  int socketHeight = 1;
  int paintCmdIndex = 0;

  bool _hasFullWidget = false;

  List<ITCPDrawDataListener> tcpDataList = [];

  List<PaintPathInfo> paintPathList = [];

  PaintPathInfo _pathInfo;

  TcpControlHelper _tcpControlHelper;

  bool _isUpdateUpDownPage = false;

  void addITCPDrawDataListener(ITCPDrawDataListener l) {
    tcpDataList.add(l);
  }

  void removeITCPDrawDataListener(ITCPDrawDataListener l) {
    tcpDataList.remove(l);
  }

  void setUpFullWidgetState(bool isExist) {
    _hasFullWidget = isExist;
  }

  void resetState() {
    paintPathList.clear();
    tcpDataList.clear();
    _isUpdateUpDownPage = false;
    image = null;
  }

  bool isNeedUpdateUpDownPage() {
    if (_isUpdateUpDownPage) {
      _isUpdateUpDownPage = false;
      return true;
    }
    return false;
  }

  void setUpIsUpdateUpDownPage(bool b) {
    _isUpdateUpDownPage = b;
  }

  void setUpWidgetWidth(Size size) {
    screenWidth = size.width;
    screenHeight = size.height;
    print('setUpWidgetWidth ==== $screenWidth, $screenHeight');
    num max = screenWidth > screenHeight ? screenWidth : screenHeight;
    num min = screenWidth < screenHeight ? screenWidth : screenHeight;
    if (max != maxScreenSize || min != minScreenSize) {
      maxScreenSize = max;
      minScreenSize = min;
      _sendBlackSize(max, min);
    }
  }

  void _onMediaControl(String cmdStr) {
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onMediaControl(cmdStr);
    }
  }

  void _sendBlackSize(num w, num h) {
    Point tcpBlackSize = Point(w, h);
    _tcpControlHelper.controlBlackBoardSize(tcpBlackSize);
    print('tcpBlackSize ---- $tcpBlackSize');
  }

  bool isExitFullWidget() {
    return _hasFullWidget;
  }

  void _onPageInfo(String info) {
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onPageInfoGet(info);
    }
  }

  void _onPngImage(var base64) {
    image = Base64Codec().decode(base64);
    print('_onPngImage ----- ');
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onDrawImage(image);
    }
  }

  void _onOpenMedia(String mediaInfo) {
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onOpenMedia(mediaInfo);
    }
  }

  _onPaintPosStart(var points) {
    onPaintPosStart(points);
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onDrawPaintStart(points);
    }
  }

  onPaintPosStart(var points) {
    List<Point> pointList = [];
    for (Point p in points) {
      print("point _onPaintPosStart == ${p.toString()}");
      pointList.add(p);
    }
    _pathInfo = new PaintPathInfo([], paintCmdIndex);
    _pathInfo.addPoints(pointList);
    paintPathList.add(_pathInfo);
  }

  _onPaintPosEnd(var points) {
    onPaintPosEnd(points);
    List<Point> pointList = points;
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onDrawPaintEnd(pointList);
    }
  }

  onPaintPosEnd(var points) {
    List<Point> pointList = [];
    for (Point p in points) {
      print("point _onPaintPosEnd == ${p.toString()}");
      pointList.add(p);
    }
    _pathInfo?.addPoints(pointList);
    _pathInfo = null;
  }

  _onPaintPos(var points) {
    onPaintPos(points);
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onDrawPaintLooping(points);
    }
  }

  onPaintPos(var points) {
    List<Point> pointList = [];
    for (Point p in points) {
      print("point _onPaintPos == ${p.toString()}");
      pointList.add(p);
    }
    _pathInfo?.addPoints(pointList);
  }

  List<Dot> paintPathToViewData(num widgetWidth, num widgetHeight,
      {num offsetTop = 0}) {
    List<Dot> dots = [];
    print('paintPathList === ${paintPathList.length}');
    if (paintPathList != null && paintPathList.isNotEmpty) {
      print(
          "paintPathToViewData w, h x, y== $widgetWidth, $widgetHeight, $offsetTop, $socketWidth , $socketHeight");
      double xRatio = widgetWidth / socketWidth;
      double yRatio = widgetHeight / socketHeight;
      for (PaintPathInfo info in paintPathList) {
        Dot dot = new Dot(
          color: toOurColor(info.pathColorIndex),
          path: info.toPath(xRatio, yRatio, 0, offsetTop),
        );
        dots.add(dot);
      }
    }
    return dots;
  }

  void clearPaintPath() {
    paintPathList?.clear();
  }

  Color toOurColor(int tcpIndex) {
    int index = tcpIndex - 1;
    if (index >= 0 && index < SelectedPaintColorWidget.colors.length) {
      return SelectedPaintColorWidget.colors[index];
    }
    return SelectedPaintColorWidget.colors[0];
  }

  Point toTcpPoint(Point ourPoint, num widgetWidth, num widgetHeight,
      {int offsetX = 0, int offsetY = 0}) {
    print(
        "toTcpPoint w, h x, y== $widgetWidth, $widgetHeight, $socketWidth , $socketHeight");
    double xRatio = socketWidth / widgetWidth;
    double yRatio = socketHeight / widgetHeight;
    print('toTcpPoint ratio x, y= $xRatio, $yRatio');
    num x = ourPoint.x * xRatio + offsetX;
    num y = ourPoint.y * yRatio + offsetY;

    return Point(x, y);
  }

  Point toOurPoint(Point p, num widgetWidth, num widgetHeight,
      {int offsetTop = 0}) {
    double x = p.x;
    double y = p.y;
    print(
        "point w, h x, y== $widgetWidth, $widgetHeight, $socketWidth , $socketHeight");
    double widthRatio = widgetWidth / socketWidth;
    double heightRatio = widgetHeight / socketHeight;
    print("point ratio x, y== $widthRatio , $heightRatio");
    x = x * widthRatio;
    y = y * heightRatio + offsetTop;
    print("point x, y== $x , $y");
    return new Point(x, y);
  }

  _onSetBlackBoardSize(int w, int h) {
    print("_onSetBlackBoardSize ----- $w, $h");
    socketWidth = w;
    socketHeight = h;
  }

  _onsetBoardPatin(int tcpIndex) {
    print('_onsetBoardPatin == $tcpIndex');
    paintCmdIndex = tcpIndex;
    for (ITCPDrawDataListener dataListener in tcpDataList) {
      dataListener.onDrawPaintSet(tcpIndex);
    }
  }
}

abstract class ITCPDrawDataListener {
  void onDrawPaintStart(List<Point> points) {}

  void onDrawPaintEnd(List<Point> points) {}

  void onDrawPaintLooping(List<Point> points) {}

  void onDrawImage(Uint8List image);

  void onDrawPaintSet(int cmdIndex) {}

  void onMediaControl(String cmdStr) {}

  void onPageInfoGet(String pageInfo) {}

  void onOpenMedia(String mediaInfo);
}
