import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/business/course_media_helper.dart';
import 'package:smart_one/util/string_utils.dart';
import 'package:smart_one/util/text_config.dart';

typedef OnGridItemClick = void Function(int itemIndex);

class ListGridView extends StatefulWidget {
  List<ICourseMediaNode> data;
  OnGridItemClick itemClick;

  ListGridView({Key key, this.data, this.itemClick}) : super(key: key);

  @override
  _ListGridViewState createState() => _ListGridViewState();
}

class _ListGridViewState extends State<ListGridView> {
  @override
  Widget build(BuildContext context) {
    GridView gridView = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 16 / 9, crossAxisSpacing: 10),
      itemBuilder: _itemBuilder,
      itemCount: widget.data == null ? 0 : widget.data.length,
    );
    Container container = new Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: gridView,
    );

    return container;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    ICourseMediaNode media = widget.data[index];
    Widget contentView =
        media.getWidgetType() == CourseMediaWidgetType.Widget_Content
            ? _buildItemContentView(media)
            : _buildItemSwitchView();

    Container container = new Container(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        child: contentView,
        decoration: ShapeDecoration(
            color: Color(0xfff0f0f0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      ),
    );

    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        if (widget.itemClick != null) {
          widget.itemClick(index);
        }
      },
      child: container,
    );
    return gestureDetector;
  }

  _buildItemSwitchView() {
    return Container(
      alignment: Alignment.center,
      child: Icon(
        Icons.assignment_return,
        color: Color.fromARGB(255, 102, 102, 102),
      ),
    );
  }

  _buildItemContentView(ICourseMediaNode media) {
    Column column = new Column(
      children: <Widget>[
        Expanded(
            child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: media.getThumb() != null &&
                          !media.getThumb().startsWith("http")
                      ? AssetImage(media.getThumb())
                      : ExtendedNetworkImageProvider(media.getThumb()))),
        )),
        Row(
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Container(
              width: 6 * 12.0,
              child: Text(
                media.getTitle(),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextConfig.getTextStyle(
                    size: TextConfig.CONTENT_TEXT_SMALL_SIZE,
                    color: Color.fromARGB(255, 102, 102, 102)),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                StringUtils.getTimestampStr(media.getTimestamp()),
                style: TextConfig.getTextStyle(
                    size: TextConfig.CONTENT_TEXT_SMALL_SIZE,
                    color: Color.fromARGB(255, 102, 102, 102)),
              ),
            )),
            SizedBox(
              width: 5,
            ),
          ],
        )
      ],
    );

    return column;
  }
}
