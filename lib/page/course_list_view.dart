import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';
import 'package:extended_image/extended_image.dart';

typedef OnItemClick = void Function(int index);

///
///课程页面
///
class CourseListView extends StatefulWidget {
  final List<ICourse> list;
  final OnItemClick onItemClick;

  CourseListView({
    Key key,
    @required List<ICourse> this.list,
    OnItemClick this.onItemClick,
  })  : assert(list != null),
        super(key: key) {}

  @override
  State<StatefulWidget> createState() {
    return CouserPageState();
  }
}

abstract class ICourse {
  String getId();

  ///
  /// 课程图片
  ///
  String getCourseImage();

  ///
  /// 课程标题
  ///
  String getCourseTitle();

  ///
  /// 课程教师
  ///
  String getCourseTeacher();

  ///
  /// 课程发布时间
  ///
  int getPubTime();

  ///
  /// 课程总时长时间
  ///
  int getDurationTime();
}

class CouserPageState extends State<CourseListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, index);
        });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    ICourse couser = widget.list[index];

    Container container = new Container(
      padding: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
            width: 95,
            child: AspectRatio(
              aspectRatio: 9 / 6,
              child: couser.getCourseImage() == null
                  ? Icon(Icons.crop_original, color: Colors.blueGrey, size: 80,)
                  : ExtendedImage.network(
                      couser.getCourseImage(),
                      fit: BoxFit.fitWidth,
                    ),
            ),
          ),
          SizedBox(
            width: 11,
          ),
          Expanded(
            child: buildCourseInfoWidget(index, couser),
          ),
        ],
      ),
    );

    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        _listViewItemClick(index);
      },
      child: container,
    );
    return gestureDetector;
  }

  void _listViewItemClick(int index) {
    print("listview ${index} item click");
    if (widget.onItemClick != null) {
      widget.onItemClick(index);
    }
  }

  Column buildCourseInfoWidget(int index, ICourse couser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        Text(
          couser.getCourseTitle(),
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: TextConfig.TITLE_TEXT_SIZE,
              fontWeight: FontWeight.bold,
              color: Color(0xff262626),
              decoration: TextDecoration.none),
          softWrap: true,
        ),
        Text(
          "授课老师: ${couser.getCourseTeacher()}",
          style: TextStyle(
              fontSize: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
              fontWeight: FontWeight.w500,
              color: Color(0xff262626),
              decoration: TextDecoration.none),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Text(
                "发布时间: ${getPubTimeStr(couser.getPubTime())}",
                style: TextStyle(
                    fontSize: TextConfig.CONTENT_TEXT_SMALL_SIZE,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff666666),
                    decoration: TextDecoration.none),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            // Icon(
            //   Icons.access_time,
            //   color: Color(0xffd1d1d1),
            // ),
            // Text(
            //   "${getDurationTime(couser.getDurationTime())}",
            //   softWrap: false,
            //   style: TextStyle(
            //       fontSize: TextConfig.CONTENT_TEXT_SMALL_SIZE,
            //       fontWeight: FontWeight.normal,
            //       color: Color(0xffd1d1d1),
            //       decoration: TextDecoration.none),
            // ),
          ],
        ),
        SizedBox(
          height: 2,
        ),
        SizedBox(
          height: 25,
          child: RaisedButton.icon(
              onPressed: () {
                _listViewItemClick(index);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              color: Color(0xff19b2fe),
              icon: SizedBox(
                height: 12,
                child: ImageIcon(
                  AssetImage("images/icon_start_course.png"),
                  color: Colors.white,
                ),
              ),
              label: Text(
                "开始上课",
                style: TextStyle(
                    fontSize: TextConfig.CONTENT_TEXT_SMALL_SIZE,
                    fontWeight: FontWeight.w300,
                    color: Color(0xffffffff),
                    decoration: TextDecoration.none),
              )),
        ),
        SizedBox(height: 5),
        SizedBox(
          height: 1,
          child: Container(
            color: Color.fromARGB(255, 230, 230, 230),
          ),
        )
      ],
    );
  }

  String getPubTimeStr(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dateTime.year}-${twoDigits(dateTime.month)}-${twoDigits(dateTime.day)}";
  }

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String getDurationTime(int time) {
    Duration duration = new Duration(milliseconds: time);

    if (duration.inMicroseconds < 0) {
      return "-${0}";
    }
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:${twoDigitMinutes}:${twoDigitSeconds}";
  }

  String getDownTime(int time) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    Duration duration = dateTime.difference(now);
    if (duration.inDays > 0) {
      return "${duration.inDays}:${duration.inHours}:${duration.inMinutes}:${duration.inSeconds}";
    } else {
      return "${duration.inHours}:${duration.inMinutes}:${duration.inSeconds}";
    }
  }
}
