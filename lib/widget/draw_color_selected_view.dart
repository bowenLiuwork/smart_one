import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smart_one/util/text_config.dart';

typedef OnColorSelected = void Function(Color selectedColor);
typedef OnClearClick = void Function();
typedef OnDoneClick = void Function();

class SelectedPaintColorWidget extends StatefulWidget {
  Color selectedColor;
  OnColorSelected colorSelected;
  OnClearClick clearClick;
  OnDoneClick doneClick;

  static final Color BLACK = Colors.black;
  static final Color GREEN = Color(0xff4dff4d);
  static final Color MAGENTA = Color(0xffff4dff);
  static final Color CYAN = Color(0xff4dffff);
  static final Color FLUORESCENCE = Color(0xffffff4d);

  static List<Color> colors = [
    Colors.red,
    BLACK,
    Colors.white,
    GREEN,
    MAGENTA,
    CYAN,
    FLUORESCENCE
  ];

  SelectedPaintColorWidget(
      {Key key,
      @required this.selectedColor,
      this.colorSelected,
      this.clearClick,
      this.doneClick})
      : super(
          key: key,
        ) {}

  @override
  State<StatefulWidget> createState() {
    return SelectedPaintColorWidgetState();
  }
}

class SelectedPaintColorWidgetState extends State<SelectedPaintColorWidget> {
  List<Color> colors;

  @override
  void initState() {
    colors = SelectedPaintColorWidget.colors;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Container container = new Container(
      height: 80,
      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: ShapeDecoration(
          color: Color.fromARGB(60, 51, 51, 63),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: getColorsList(),
    );
    return container;
  }

  Widget getColorsList() {
    List<Widget> colorWidgets = [];
    for (int i = 0; i < colors.length; i++) {
      Color itemColor = colors[i];
      if (i < colors.length - 1) {
        colorWidgets.add(getColorItem(itemColor));
        colorWidgets.add(SizedBox(
          width: 10,
        ));
      } else {
        colorWidgets.add(getBoldItem(itemColor));
      }
    }
    colorWidgets.add(SizedBox(
      width: 10,
    ));
    colorWidgets.add(getClearItem());
//    colorWidgets.add(SizedBox(
//      width: 10,
//    ));
    colorWidgets.add(getOkItem());

    Wrap row = new Wrap(
      children: colorWidgets,
    );
    return row;
  }

  Widget getOkItem() {
    Widget box = SizedBox(
      height: 35,
      child: FlatButton.icon(
          onPressed: () {
            if (widget.doneClick != null) {
              widget.doneClick();
            }
          },
          icon: Icon(
            Icons.done,
            size: 35,
            color: Colors.green,
          ),
          label: Text(
            "完成",
            style: TextConfig.getTextStyle(
                size: TextConfig.CONTENT_TEXT_SMALL_SIZE, color: Colors.white),
          )),
    );

    return box;
  }

  Widget getBoldItem(Color color) {
    Container box = new Container(
      width: 35,
      height: 35,
      padding:
          widget.selectedColor != color ? EdgeInsets.all(5) : EdgeInsets.all(0),
      child: widget.selectedColor != color
          ? Image.asset(
              "images/bold_paint_unselected.png",
              height: double.maxFinite,
              fit: BoxFit.fitHeight,
            )
          : Image.asset(
              "images/bold_paint_selected.png",
              height: double.maxFinite,
              fit: BoxFit.fitHeight,
            ),
    );
    GestureDetector detector = new GestureDetector(
      onTap: () {
        setState(() {
          widget.selectedColor = color;
          if (widget.colorSelected != null) {
            widget.colorSelected(color);
          }
        });
      },
      child: box,
    );
    return detector;
  }

  Widget getColorItem(Color color) {
    Container box = new Container(
      width: 35,
      height: 35,
      padding: EdgeInsets.all(5),
      decoration: widget.selectedColor == color
          ? ShapeDecoration(shape: CircleBorder(side: BorderSide(color: color)))
          : null,
      child: ClipOval(
        child: Container(
          color: color,
        ),
      ),
    );
    GestureDetector detector = new GestureDetector(
      onTap: () {
        setState(() {
          widget.selectedColor = color;
          if (widget.colorSelected != null) {
            widget.colorSelected(color);
          }
        });
      },
      child: box,
    );
    return detector;
  }

  Widget getBackItem() {
    Container box = new Container(
      width: 45,
      height: 45,
      padding: EdgeInsets.all(5),
      child: ClipOval(
        child: Icon(
          Icons.keyboard_return,
          color: Colors.black,
        ),
      ),
    );

    return box;
  }

  bool _clearItemTapDown = false;

  Widget getClearItem() {
    Container box = new Container(
      width: 35,
      height: 35,
      padding: _clearItemTapDown ? EdgeInsets.all(5) : EdgeInsets.all(0),
      child: _clearItemTapDown
          ? Image.asset(
              "images/clear_path.png",
              height: double.maxFinite,
              fit: BoxFit.fitHeight,
            )
          : Image.asset(
              "images/clear_path_selected.png",
              height: double.maxFinite,
              fit: BoxFit.fitHeight,
            ),
    );
    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        print("clear ---");
        if (widget.clearClick != null) {
          widget.clearClick();
        }
      },
      onTapDown: (d) {
        setState(() {
          _clearItemTapDown = true;
        });
      },
      onTapUp: (d) {
        setState(() {
          _clearItemTapDown = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _clearItemTapDown = false;
        });
      },
      child: box,
    );
    return gestureDetector;
  }
}
