import 'package:flutter/material.dart';

typedef OnBarItemClick = void Function(int index);

class SwitchListBar extends StatefulWidget {
  List<String> barTitleList;
  OnBarItemClick itemClick;
  int selectedIndex;

  SwitchListBar({Key key, this.barTitleList, this.itemClick, this.selectedIndex = 0}) : super(key: key);

  @override
  _SwitchListBarState createState() => _SwitchListBarState();
}

class _SwitchListBarState extends State<SwitchListBar> {

  @override
  Widget build(BuildContext context) {
    List<Widget> barList = [];

    for (int i = 0; i < widget.barTitleList.length; i++) {
      barList.add(_buidItem(i, widget.barTitleList[i]));
      if (i < widget.barTitleList.length - 1) {
        barList.add(SizedBox(
          width: 20,
        ));
      }
    }

    Wrap row = Wrap(
      children: barList,
    );

    Container container = new Container(
        color: Colors.white,
        height: 50,
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 1),
              height: 4,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: SizedBox(
                height: 1,
                child: Container(
                  color: Color.fromARGB(255, 204, 204, 204),
                ),
              ),
            ),
            row,
          ],
        ));

    return container;
  }

  _buidItem(int i, String itemStr) {
    Column column = Column(
      children: <Widget>[
        Text(
          itemStr,
          style: TextStyle(
              color: _getColor(i),
              fontSize: 17,
              decoration: TextDecoration.none),
        ),
        SizedBox(
          height: 7,
        ),
        i == widget.selectedIndex
            ? Container(
                width: 17.0 * 4,
                height: 4,
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: _getColor(i), width :2,),
                        borderRadius: BorderRadius.circular(2))),
              )
            : Container(
                width: 17.0 * 4,
                height: 4,
              ),
      ],
    );

    Container container = new Container(
      child: column,
    );
    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        setState(() {
          widget.selectedIndex = i;
        });
        if (widget.itemClick != null) {
          widget.itemClick(i);
        }
      },
      child: container,
    );
    return gestureDetector;
  }

  _getColor(int i) {
    return i == widget.selectedIndex
        ? Color.fromARGB(255, 53, 154, 236)
        : Color.fromARGB(255, 102, 102, 102);
  }
}
