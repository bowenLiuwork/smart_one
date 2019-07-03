

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnImageControlItemClick = void Function(int index);

class ImageControlView extends StatefulWidget {
  static final int ALLBTNSIZE = 6;
  OnImageControlItemClick itemClick;
  List<bool> enableList;
  ImageControlView({Key key, this.itemClick, this.enableList}):super(key: key);

  @override
  _ImageControlViewState createState() => _ImageControlViewState();
}

class _ImageControlViewState extends State<ImageControlView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(buildItem(
        0,
        ImageIcon(
          AssetImage("images/icon_rote_left.png"),
          color: _indexColor(0),
        ))
    );
    list.add(buildItem(
        1,
        ImageIcon(
          AssetImage("images/icon_rote_right.png"),
          color: _indexColor(0),
        ))
    );
    list.add(buildItem(
        2,
        ImageIcon(
          AssetImage("images/icon_fit_screen.png"),
          color: _indexColor(0),
        ))
    );

    list.add(buildItem(
        3,
        ImageIcon(
          AssetImage("images/icon_center_screen.png"),
          color: _indexColor(3),
        ))
    );

    list.add(buildItem(
        4,
        ImageIcon(
          AssetImage("images/icon_scale_big.png"),
          color: _indexColor(4),
        ))
    );
    list.add(buildItem(
        5,
        ImageIcon(
          AssetImage("images/icon_scale_small.png"),
          color: _indexColor(5),
        ))
    );

    Row row = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list,
    );

    Container container = new Container(
      height: 45,
      padding: EdgeInsets.only(left: 50, right: 50),
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
    bool enable = widget.enableList != null &&
        index >= 0 &&
        index < widget.enableList.length
        ? widget.enableList[index]
        : false;
    return enable;
  }

  _getColor(bool enable) {
    return enable ? Colors.white : Color(0xff929ba7);
  }

  _onItemClick(int index) {
    if(widget.itemClick != null) {
      widget.itemClick(index);
    }
  }
}
