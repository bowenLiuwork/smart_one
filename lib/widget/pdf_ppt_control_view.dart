import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';

typedef OnBarItemClick = void Function(int index);

class PdfPptControl extends StatefulWidget {
  static final int allBarCount = 8;
  List<bool> enableControlList;
  OnBarItemClick barItemClick;
  String pageText;

  PdfPptControl({
    Key key,
    this.enableControlList,
    this.pageText = '',
    this.barItemClick,
  }) : super(key: key);

  @override
  _BarListControlState createState() => _BarListControlState();
}

class _BarListControlState extends State<PdfPptControl> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(buildItem(
        0,
        ImageIcon(
          AssetImage("images/icon_first_page.png"),
          color: _indexColor(0),
        ))
    );
    list.add(buildItem(
        1,
        Icon(
          Icons.arrow_back_ios,
          color: _indexColor(1),
        ))
    );
    list.add(Text(widget.pageText,
      style: TextConfig.getTextStyle(size: TextConfig.CONTENT_TEXT_SMALL_SIZE,
          color: Colors.white),));
    list.add(buildItem(
        2,
        Icon(
          Icons.arrow_forward_ios,
          color: _indexColor(2),
        ))
    );

    list.add(buildItem(
        3,
        ImageIcon(
          AssetImage("images/icon_last_page.png"),
          color: _indexColor(3),
        ))
    );

    list.add(buildItem(
        4,
        ImageIcon(
          AssetImage("images/icon_up_down.png"),
          color: _indexColor(4),
        ))
    );
    list.add(buildItem(
        5,
        ImageIcon(
          AssetImage("images/icon_left_right.png"),
          color: _indexColor(5),
        ))
    );
    list.add(buildItem(
        6,
        ImageIcon(
          AssetImage("images/icon_scale_big.png"),
          color: _indexColor(6),
        ))
    );
    list.add(buildItem(
        7,
        ImageIcon(
          AssetImage("images/icon_scale_small.png"),
          color: _indexColor(7),
        ))
    );
    Row row = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list,
    );

    Container container = new Container(
      height: 45,
      padding: EdgeInsets.only(left: 8, right: 8),
      child: row,
    );

    return container;
  }

  Widget buildItem(int index, Widget icon) {
    GestureDetector gestureDetector = new GestureDetector(onTap: () {
      if (_indexEnable(index)) {
        _onItemClick(index);
      }
    }, child: icon,);
    return gestureDetector;
  }

  _indexColor(int index) {
    bool enable = _indexEnable(index);
    return _getColor(enable);
  }

  _indexEnable(int index) {
    bool enable = widget.enableControlList != null &&
        index >= 0 &&
        index < widget.enableControlList.length
        ? widget.enableControlList[index]
        : false;
    return enable;
  }

  _getColor(bool enable) {
    return enable ? Colors.white : Color(0xff929ba7);
  }

  _onItemClick(int index) {
    if(widget.barItemClick != null) {
      widget.barItemClick(index);
    }
  }
}
