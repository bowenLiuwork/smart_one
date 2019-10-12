import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';

typedef PageCountChanged = void Function(int page);

class PageHeaderView extends StatefulWidget {
  int pageIndex;
  PageCountChanged onchange;

  PageHeaderView({Key key, @required int this.pageIndex, this.onchange})
      : super(key: key) {}

  @override
  State<StatefulWidget> createState() {
    return PageHeaderViewState();
  }
}

class PageHeaderViewState extends State<PageHeaderView> {
  @override
  Widget build(BuildContext context) {
    Container container = new Container(
      height: 45,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              previousPageClick();
            },
            child: Container(
              child: Row(
                children: <Widget>[
                  Icon(Icons.arrow_back_ios, color: Color(0xff333333)),
                  Text(
                    "上一页",
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
                  "第${widget.pageIndex}页",
                  style: TextConfig.getTextStyle(color: Color(0xff3c4549)),
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              nextPageClick();
            },
            child: Container(
              child: Row(
                children: <Widget>[
                  Text(
                    "下一页",
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

  void nextPageClick() {
    int page = widget.pageIndex;
    page++;
//    if (page > 4) {
//      page = 1;
//    }

    setState(() {
      widget.pageIndex = page;
    });
    if (widget.onchange != null) {
      widget.onchange(page);
    }
  }

  void previousPageClick() {
    int page = widget.pageIndex;
    page--;
    if (page < 1) {
      page = 1;
    }
    setState(() {
      widget.pageIndex = page;
    });

    if (widget.onchange != null) {
      widget.onchange(page);
    }
  }
}
