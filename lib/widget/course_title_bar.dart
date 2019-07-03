import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/back_page_utils.dart';
import 'package:smart_one/util/device_size_manager.dart';
import 'package:smart_one/util/text_config.dart';

typedef OnRecordControlClick = void Function(bool isStartRecord);

typedef OnDrawPathClick = void Function();

class CourseTitleBar extends StatefulWidget implements PreferredSizeWidget {
  int allMills = 0;
  OnRecordControlClick recordControlClick;
  OnDrawPathClick onDrawPathClick;

  CourseTitleBar({Key key, this.recordControlClick, this.onDrawPathClick, this. allMills = 0})
      : super(key: key);

  @override
  _CourseTitleBarState createState() => _CourseTitleBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(50 + DeviceSizeManager.instance.getStatusBarHeight());
}

class _CourseTitleBarState extends State<CourseTitleBar> {
  bool _isStartRecord = false;

  @override
  Widget build(BuildContext context) {
    GestureDetector recordBtn = GestureDetector(
      onTap: () {
        setState(() {
          _isStartRecord = !_isStartRecord;
        });
        if (widget.recordControlClick != null) {
          widget.recordControlClick(_isStartRecord);
        }
      },
      child: _isStartRecord
          ? Icon(
              Icons.pause_circle_outline,
              color: Colors.red,
            )
          : Icon(
              Icons.play_circle_outline,
              color: Colors.red,
            ),
    );

    GestureDetector pathBtn = GestureDetector(
        onTap: () {
          if (widget.onDrawPathClick != null) {
            widget.onDrawPathClick();
          }
        },
        child: ImageIcon(
          AssetImage("images/btn_draw_path.png"),
          color: Colors.lightGreen,
        ));
    Row row = new Row(
      children: <Widget>[
        BackPageUtils.getPageBackWidget(context, color: Colors.black),
        Expanded(
            child: Center(
          child: Text(
            _getTimeStr(),
            style: TextConfig.getTextStyle(
                size: TextConfig.CONTENT_TEXT_SMALL_SIZE, color: Colors.red),
          ),
        )),
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: recordBtn,
        ),
        pathBtn,
      ],
    );
    Container container = new Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  top: DeviceSizeManager.instance.getStatusBarHeight(), left: 1, right: 10),
              child: row,
            ),
          ),
          SizedBox(
            height: 1,
            child: Container(
              color: Color.fromARGB(255, 230, 230, 230),
            ),
          ),
        ],
      ),
      color: Colors.white,
      height: 50 + DeviceSizeManager.instance.getStatusBarHeight(),
    );

    return container;
  }

  _getTimeStr() {
    if(widget.allMills <= 0) {
      return '';
    }
    Duration duration = new Duration(milliseconds: widget.allMills);
    return '${duration.inHours}:${duration.inMinutes}:${duration.inSeconds}';
  }
}
