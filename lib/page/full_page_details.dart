import 'dart:typed_data';
import 'dart:ui';

//import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'package:smart_one/business/draw_data_helper.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/model/Point.dart';
import 'package:smart_one/util/device_size_manager.dart';
import 'package:smart_one/util/screen_utils.dart';
import 'package:smart_one/widget/draw_color_selected_view.dart';
import 'package:smart_one/widget/draw_view.dart';
import 'package:event_bus/event_bus.dart';
import 'package:smart_one/widget/image_switch_view.dart';

class FullPageDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FullPageDetailsState();
  }
}

class _FullPageDetailsState extends State<FullPageDetails>
    with WidgetsBindingObserver
    implements ITCPDrawDataListener {
  GlobalKey drawKey = new GlobalKey();
  TcpControlHelper tcpControlHelper;
  List<Dot> _dotList = [];
  Color _paintColor = SelectedPaintColorWidget.colors[0];
  Path _path;
  Dot _dot;

  Uint8List _image;
  num width;
  num height;

  num drawViewMaxX;
  num drawViewMaxY;

  EventBus eventBus = EventBus();

  @override
  void initState() {
    tcpControlHelper = new TcpControlHelper((value) {
      SocketHelper.instance.write(value);
    });
    ScreenUtils.landScreen();
    DrawDataManager.instance.addITCPDrawDataListener(this);
    DrawDataManager.instance.setUpFullWidgetState(true);
    width = DeviceSizeManager.instance.getScreenMaxSize();
    height = DeviceSizeManager.instance.getScreenMinSize() -
        DeviceSizeManager.instance.getBottomStatusBarHeight();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (DrawDataManager.instance.paintCmdIndex == 0) {
      tcpControlHelper.controlBlackBoard(0 + 1);
    } else {
      tcpControlHelper
          .controlBlackBoard(DrawDataManager.instance.paintCmdIndex);
    }
    _paintColor = DrawDataManager.instance
        .toOurColor(DrawDataManager.instance.paintCmdIndex);
    print('_dotList == ${_dotList.length}');
    _image = DrawDataManager.instance.image;
    _onsetBoardPatin(DrawDataManager.instance.paintCmdIndex);
    eventBus.on<Size>().listen((size) {
      print('event size ==== $size');
      setState(() {
        _dotList =
            DrawDataManager().paintPathToViewData(drawViewMaxX, drawViewMaxY);
      });
    });
  }

  @override
  void dispose() {
    DrawDataManager.instance.setUpFullWidgetState(false);
    DrawDataManager.instance.removeITCPDrawDataListener(this);
    WidgetsBinding.instance.removeObserver(this);
    ScreenUtils.portScreen();
    super.dispose();
  }

  void didChangeMetrics() {
    print('didChangeMetrics --------------- ');
    Size size = WidgetsBinding.instance.window.physicalSize;
    width = size.width;
    height = size.height;
  }

  void _drawViewSizeChange(Size size) {
    print('_drawViewSizeChange ------------ $size');
    drawViewMaxX = size.width;
    drawViewMaxY = size.height;
    DrawDataManager.instance.setUpWidgetWidth(size);
    eventBus.fire(size);
  }

  @override
  Widget build(BuildContext context) {
    print('full page init state --- ${window.physicalSize}');
    Size showSize = new Size(width, height);
    print('showSize ==== $showSize');
    DrawView drawView = new DrawView(
      key: drawKey,
      size: showSize,
      list: _dotList,
      sizeChange: _drawViewSizeChange,
      paintColor: _paintColor,
      canTouch: true,
      marginTop: 0,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 45,
          child: SelectedPaintColorWidget(
            selectedColor: _paintColor,
            colorSelected: _onPaintColorSelected,
            clearClick: _clearPaintDot,
            doneClick: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ),
    );

    SizedBox imageView = SizedBox.expand(
      child: Container(
        child: _image == null
            ? Container(
                color: Colors.black,
              )
            : ImageSwitchView(
                image: _image,
              ),
      ),
    );

    Stack stack = new Stack(
      children: <Widget>[
        imageView,
        drawView,
      ],
    );

    WillPopScope willPopScope = new WillPopScope(
        child: stack,
        onWillPop: () {
          Navigator.of(context).pop(true);
          return Future.value(false);
        });

    return willPopScope;
  }

  _clearPaintDot() {
    tcpControlHelper.controlBlackBoard(9);
    DrawDataManager.instance.clearPaintPath();
    setState(() {
      clearPaint();
    });
  }

  void clearPaint() {
    DrawDataManager.instance.clearPaintPath();
    _dotList.clear();
  }

  _onPaintColorSelected(Color color) {
    print('_onPaintColorSelected ----- $color');
    int colorIndex = SelectedPaintColorWidget.colors.indexOf(color);
    tcpControlHelper.controlBlackBoard(colorIndex + 1);
    setState(() {
      _paintColor = color;
    });
  }

  _onPaintPosEnd(var points) {
    for (Point p in points) {
      print("point _onPaintPosEnd == ${p.toString()}");
      Point p1 =
          DrawDataManager.instance.toOurPoint(p, drawViewMaxX, drawViewMaxY);
      _path.lineTo(p1.x, p1.y);
    }

    setState(() {
      _dotList = _dotList;
    });
  }

  _onPaintPos(var points) {
    print('point == ${points.length}');
    for (Point p in points) {
      print("point _onPaintPos == ${p.toString()}");
      Point p1 =
          DrawDataManager.instance.toOurPoint(p, drawViewMaxX, drawViewMaxY);
      _path.lineTo(p1.x, p1.y);
    }

    setState(() {
      _dotList = _dotList;
    });
  }

  _onsetBoardPatin(int tcpIndex) {
    print('_onsetBoardPatin == $tcpIndex');
    int index = tcpIndex - 1;
    if (index >= 0 && index < SelectedPaintColorWidget.colors.length) {
      setState(() {
        _paintColor = SelectedPaintColorWidget.colors[index];
      });
    } else if (index == 8) {
      // 9 = 8 + 1 //清除画布
      DrawDataManager.instance.clearPaintPath();
      setState(() {
        clearPaint();
      });
    }
  }

  @override
  void onDrawImage(Uint8List image) {
    setState(() {
      clearPaint();
      _image = image;
    });
  }

  @override
  void onDrawPaintEnd(List<Point> points) {
    _onPaintPosEnd(points);
  }

  @override
  void onDrawPaintLooping(List<Point> points) {
    _onPaintPos(points);
  }

  @override
  void onDrawPaintSet(int cmdIndex) {
    _onsetBoardPatin(cmdIndex);
  }

  @override
  void onDrawPaintStart(List<Point> points) {
    _path = new Path();
    for (Point p in points) {
      print("point _onPaintPosStart == ${p.toString()}");
      Point p1 =
          DrawDataManager.instance.toOurPoint(p, drawViewMaxX, drawViewMaxY);
      _path.moveTo(p1.x, p1.y);
    }
    _dot = new Dot(color: _paintColor, path: _path);
    setState(() {
      _dotList.add(_dot);
      print('point ==== ${_dotList.length}');
    });
  }

  @override
  void onMediaControl(String cmdStr) {}

  @override
  void onPageInfoGet(String pageInfo) {}

  @override
  void onOpenMedia(String mediaInfo) {}
}
