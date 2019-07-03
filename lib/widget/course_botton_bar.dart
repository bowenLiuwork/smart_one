import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnQianDaoClick = void Function();
typedef OnDianMingClick = void Function();
typedef OnQiangDaClick = void Function();
typedef OnStartDianMingClick = void Function();
typedef OnStopDianMingClick = void Function();
typedef OnStartQiangDaClick = void Function();
typedef OnStopQiangDaClick = void Function();

class CourseBottomBar extends StatefulWidget {
  OnQianDaoClick qianDaoClick;
  OnDianMingClick dianMingClick;
  OnQiangDaClick qiangDaClick;
  OnStartDianMingClick startDianMingClick;
  OnStopDianMingClick stopDianMingClick;
  OnStartQiangDaClick startQiangDaClick;
  OnStopQiangDaClick stopQiangDaClick;

  CourseBottomBar(
      {Key key,
      this.qianDaoClick,
      this.dianMingClick,
      this.qiangDaClick,
      this.startDianMingClick,
      this.stopDianMingClick,
      this.startQiangDaClick,
      this.stopQiangDaClick})
      : super(key: key);

  @override
  _CourseBottomBarState createState() => _CourseBottomBarState();
}

class _CourseBottomBarState extends State<CourseBottomBar> {
  String dianmingText = "随机点名";
  String qiangDaText = "举手抢答";

  @override
  Widget build(BuildContext context) {
    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: Center(
            child: FlatButton(
                onPressed: () {
                  if (widget.qianDaoClick != null) {
                    widget.qianDaoClick();
                  }
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Image.asset(
                      "images/icon_course_qiandao.png",
                      width: 25,
                      height: 25,
                    ),
                    Text('上课签到')
                  ],
                )),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: FlatButton(
                onPressed: () {
                  if ("随机点名" == dianmingText && widget.dianMingClick != null) {
                    widget.dianMingClick();
                    setState(() {
                      dianmingText = "开始点名";
                    });
                  } else if ("开始点名" == dianmingText &&
                      widget.startDianMingClick != null) {
                    widget.startDianMingClick();
                    setState(() {
                      dianmingText = "停止点名";
                    });
                  } else if (widget.stopDianMingClick != null) {
                    widget.stopDianMingClick();
                    setState(() {
                      dianmingText = "随机点名";
                    });
                  }
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Image.asset(
                      "images/icon_dianming.png",
                      width: 25,
                      height: 25,
                    ),
                    Text('$dianmingText')
                  ],
                )),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: FlatButton(
                onPressed: () {
                  if ("举手抢答" == qiangDaText && widget.qiangDaClick != null) {
                    widget.qiangDaClick();
                    setState(() {
                      qiangDaText = "开始抢答";
                    });
                  } else if ("开始抢答" == qiangDaText &&
                      widget.startQiangDaClick != null) {
                    widget.startQiangDaClick();
                    setState(() {
                      qiangDaText = "停止抢答";
                    });
                  } else if (widget.stopQiangDaClick != null) {
                    widget.stopQiangDaClick();
                    setState(() {
                      qiangDaText = "举手抢答";
                    });
                  }
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Image.asset(
                      "images/icon_qiangda.png",
                      width: 25,
                      height: 25,
                    ),
                    Text('$qiangDaText')
                  ],
                )),
          ),
        ),
      ],
    );

    Widget container = SizedBox.expand(
      child: row,
    );

    return container;
  }
}
