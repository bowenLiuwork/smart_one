import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';

typedef WeekTimeChanged = void Function(int week, int startTime, int endTime);

class WeekHeaderView extends StatefulWidget {
  int weekIndex;
  int startTime;
  int endTime;
  WeekTimeChanged onchange;

  WeekHeaderView(
      {Key key,
      @required int this.weekIndex,
      @required int this.startTime,
      @required this.endTime,
      this.onchange})
      : super(key: key) {}

  @override
  State<StatefulWidget> createState() {
    return WeekHeaderViewState();
  }
}

class WeekHeaderViewState extends State<WeekHeaderView> {
  @override
  Widget build(BuildContext context) {
    Container container = new Container(
      height: 45,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              previousWeekClick();
            },
            child: Container(
              child: Row(
                children: <Widget>[
                  Icon(Icons.arrow_back_ios, color: Color(0xff333333)),
                  Text(
                    "上一周",
                    style: TextConfig.getTextStyle(
                        size: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
                        color: Color(0xff333333)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                child: Text(
                  "第${widget.weekIndex}周 ${getStartToEndTimeStr()}",
                  style: TextConfig.getTextStyle(color: Color(0xff3c4549)),
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              nextWeekClick();
            },
            child: Container(
              child: Row(
                children: <Widget>[
                  Text(
                    "下一周",
                    style: TextConfig.getTextStyle(
                        size: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
                        color: Color(0xff333333)),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Color(0xff333333)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return container;
  }

  void nextWeekClick() {
    int week = widget.weekIndex;
    week++;
//    if (week > 4) {
//      week = 1;
//    }

    DateTime start = new DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    DateTime end = new DateTime.fromMillisecondsSinceEpoch(widget.endTime);
    int nextStart = start.add(new Duration(days: 7)).millisecondsSinceEpoch;
    int nextEnd = end.add(new Duration(days: 7)).millisecondsSinceEpoch;

    setState(() {
      widget.weekIndex = week;
      widget.startTime = nextStart;
      widget.endTime = nextEnd;
    });
    if (widget.onchange != null) {
      widget.onchange(week, nextStart, nextEnd);
    }
  }

  void previousWeekClick() {
    int week = widget.weekIndex;
    week--;
    if (week < 1) {
      week = 1;
    }

    DateTime start = new DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    DateTime end = new DateTime.fromMillisecondsSinceEpoch(widget.endTime);
    int previouStart =
        start.subtract(new Duration(days: 7)).millisecondsSinceEpoch;
    int previouEnd = end.subtract(new Duration(days: 7)).millisecondsSinceEpoch;

    setState(() {
      widget.weekIndex = week;
      widget.startTime = previouStart;
      widget.endTime = previouEnd;
    });

    if (widget.onchange != null) {
      widget.onchange(week, previouStart, previouEnd);
    }
  }

  String getStartToEndTimeStr() {
    DateTime start = new DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    DateTime end = new DateTime.fromMillisecondsSinceEpoch(widget.endTime);

    return "${start.year}.${start.month}.${start.day}～${end.month}.${end.day}";
  }
}
