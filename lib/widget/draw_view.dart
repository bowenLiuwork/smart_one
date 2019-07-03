import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smart_one/business/draw_data_helper.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/model/Point.dart';

import 'draw_color_selected_view.dart';

typedef OnBlackBoardSizeChange = void Function(Size blackBoradSize);

class DrawView extends StatefulWidget {
  Color paintColor;
  List<Dot> _dotList = [];
  Widget child;
  final Size size;
  final int marginTop;
  bool canTouch;
  OnBlackBoardSizeChange sizeChange;

  DrawView({
    Key key,
    @required this.size,
    Color this.paintColor = Colors.red,
    Widget this.child,
    this.sizeChange,
    List<Dot> list,
    this.canTouch = false,
    this.marginTop,
  }) : super(key: key) {
    _dotList = list != null ? list : [];
  }

  void clear() {
    print('clear 11111111111111111');
    _dotList.clear();
  }

  bool backLatest() {
    return false;
  }

  @override
  State<StatefulWidget> createState() {
    return _DrawViewState();
  }
}

class _DrawViewState extends State<DrawView> {
  Blackboard _blackboard;

  @override
  Widget build(BuildContext context) {
    _blackboard = Blackboard(
        paintColor: widget.paintColor,
        dotList: widget._dotList,
        marginTop: widget.marginTop,
        canTouch: widget.canTouch,
        sizeChange: widget.sizeChange,
        child: widget.child != null
            ? widget.child
            : Center(
                child: Text('Touch me!'),
              ));
    Container container = new Container(
      child: _blackboard,
      width: widget.size.width,
      height: widget.size.height,
    );
    return container;
  }

  void clear() {
    setState(() {});
  }
}

class Dot {
  Paint _paint;
  Path path;

  Dot({Color color, Path this.path}) {
    _paint = new Paint();
    _paint.color = color;
    _paint.style = PaintingStyle.stroke;
    _paint.strokeCap = StrokeCap.round;
    if (color.value ==
        SelectedPaintColorWidget
            .colors[SelectedPaintColorWidget.colors.length - 1].value) {
      _paint.strokeWidth = 8.0;
    } else {
      _paint.strokeWidth = 3.0;
    }
  }

  void update(Point point) {
    path.lineTo(point.x, point.y);
  }

  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawPath(path, _paint);
  }
}

class Blackboard extends SingleChildRenderObjectWidget {
  Color paintColor;
  List<Dot> dotList;
  int marginTop;

  bool canTouch;
  OnBlackBoardSizeChange sizeChange;

  Blackboard(
      {Key key,
      Widget child,
      Color this.paintColor,
      List<Dot> this.dotList,
      this.sizeChange,
      this.canTouch,
      this.marginTop})
      : super(key: key, child: child);

  @override
  RenderTouchPainter createRenderObject(BuildContext context) {
    RenderTouchPainter _touchPainter = new RenderTouchPainter(
        color: paintColor,
        dotList: dotList,
        sizeChange: sizeChange,
        marginTop: marginTop,
        canTouch: canTouch);
    return _touchPainter;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderTouchPainter renderObject) {
    print('updateRenderObject --------- ${dotList.length}');
    renderObject
      ..color = paintColor
      ..marginTop = marginTop
      ..canTouch = canTouch
      ..sizeChange = sizeChange
      ..dotList = dotList;
    renderObject.markNeedsPaint();
  }
}

class RenderTouchPainter extends RenderConstrainedBox {
  List<Dot> dotList;
  Color color;
  int marginTop;

  Path _path;
  Dot _dot;

  Point _downPoint;
  TcpControlHelper tcpControlHelper;
  bool canTouch;
  OnBlackBoardSizeChange sizeChange;

  RenderTouchPainter({
    this.color,
    List<Dot> this.dotList,
    this.marginTop,
    this.sizeChange,
    this.canTouch = false,
  }) : super(additionalConstraints: const BoxConstraints.expand()) {
    tcpControlHelper = new TcpControlHelper((msg) {
      SocketHelper.instance.write(msg);
    });
  }

  @override
  void performLayout() {
    super.performLayout();
    print('performLayout ---------------- $size');
    if(sizeChange != null) {
      sizeChange(Size(size.width ,size.height));
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (canTouch) {
      if (event is PointerDownEvent) {
        PointerDownEvent downEvent = event;
        _path = new Path();
        print('PointerDownEvent ----- color == $color');
        _dot = new Dot(color: color, path: _path);
        _downPoint = new Point(downEvent.position.dx, downEvent.position.dy);
        _path.moveTo(downEvent.position.dx, downEvent.position.dy);
      } else if (event is PointerMoveEvent) {
        if (_dot != null) {
          dotList.add(_dot);
          _dot = null;
          Point point = _toWidgetPos(_downPoint);
          tcpControlHelper.sendStartPaintPoint(point);
          DrawDataManager.instance.onPaintPosStart([_toTCPBlackBoardPoint(point)]);
        }
        print('event.position === ${event.position}');
        _path.lineTo(event.position.dx, event.position.dy);
        var widgetPos =
            _toWidgetPos(Point(event.position.dx, event.position.dy));
        List<Point> points = [widgetPos];
        tcpControlHelper.sendPaintPoint(points);
        DrawDataManager.instance.onPaintPos([_toTCPBlackBoardPoint(widgetPos)]);
        print("222222222222222");
      } else if (event is PointerCancelEvent || event is PointerUpEvent) {
        _path.lineTo(event.position.dx, event.position.dy);
        Point point = _toWidgetPos(Point(event.position.dx, event.position.dy));
        tcpControlHelper.sendEndPaintPoint(point);
        DrawDataManager.instance.onPaintPosEnd([_toTCPBlackBoardPoint(point)]);
        _dot = null;
      }
      markNeedsPaint();
    }
  }

  Point _toWidgetPos(Point p) {
    double x = p.x;
    double y = p.y - marginTop;

    return Point(x, y);
  }

  Point _toTCPBlackBoardPoint(Point p) {
    Size cSize = this.size;
    print('draw view size --- $cSize');
    return DrawDataManager.instance.toTcpPoint(p, cSize.width, cSize.height);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  void paint(PaintingContext context, Offset offset) {
    Canvas canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = Colors.transparent);
    print('draw view --- paint size == ${dotList.length} widget size == $size');
    for (Dot dot in dotList) {
      dot.paint(context, offset);
    }
    super.paint(context, offset);
  }
}
