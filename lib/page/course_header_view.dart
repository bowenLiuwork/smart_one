import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';

///
/// 我的课程顶部栏
///
class CourseHeaderView extends StatefulWidget {
  OnClickEvent clickEvent;
  bool isConnected;

  CourseHeaderView(
      {Key key, OnClickEvent this.clickEvent, this.isConnected = false})
      : super(key: key) {}

  @override
  State<StatefulWidget> createState() {
    return CourseHeaderViewState();
  }
}

///
/// 页面事件回调
///
abstract class OnClickEvent {
  void onScanClick();

  void onPCConnectClick(bool isPcConnected);

  void onSearchClick(String text);

  void onCalendarClick();
}

class CourseHeaderViewState extends State<CourseHeaderView> {
  String _searchValue;

  void _goScan() {
    print("_goScan ---- ");
    if (widget.clickEvent != null) {
      widget.clickEvent.onScanClick();
    }
  }

  void _goCalendar() {
    print("_goCalendar ---- ");
    if (widget.clickEvent != null) {
      widget.clickEvent.onCalendarClick();
    }
  }

  void _goSearch() {
    print("_goSearch-----");
    if (widget.clickEvent != null) {
      widget.clickEvent.onSearchClick(_searchValue);
    }
  }

  void _pcConnectClick(bool isPCConnect) {
    print("_pcConnectClick-----");
    if (widget.clickEvent != null) {
      widget.clickEvent.onPCConnectClick(isPCConnect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: UnderlineTabIndicator(
          insets: EdgeInsets.all(0),
          borderSide: BorderSide(width: 2.0, color: Color(0xfff6f6f6))),
      padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 5),
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: ImageIcon(AssetImage("images/scan_camera.png")),
            ),
            onTap: () {
              _goScan();
            },
          ),
          SizedBox(
            width: 1,
            height: 15,
            child: Container(
              color: Color(0xffb2b2b2),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          GestureDetector(onTap: () {
            _pcConnectClick(widget.isConnected);
          }, child: ImageIcon(
            widget.isConnected
                ? AssetImage("images/pc_connected.png")
                : AssetImage("images/pc_disconnected.png"),
            color: widget.isConnected ? Color(0xff3a93fb) : Color(0xff767676),
          ),),
          
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: getSearchWidget(),
          )),
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: ImageIcon(AssetImage("images/icon_calendar.png")),
            ),
            onTap: () {
              _goCalendar();
            },
          ),
        ],
      ),
    );
  }

  Widget getSearchWidget() {
    Text text = new Text(
      "搜索课程或教师名称",
      style: TextStyle(
          fontSize: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
          color: Color(0xff8e8e8e),
          fontWeight: FontWeight.w300,
          decoration: TextDecoration.none),
    );

    Row row = new Row(
      children: <Widget>[
        Icon(Icons.search, color: Color(0xff4b4b4b)),
        text,
      ],
    );

    Container container = new Container(
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
      child: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget>[row],
      ),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          color: Color(0xfff4f4f4)),
    );

    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        _goSearch();
      },
      child: container,
    );
    return gestureDetector;
  }
}
