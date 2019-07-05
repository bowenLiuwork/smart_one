import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';

class TimeTablePage extends StatefulWidget {
  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Widget bodyData() => DataTable(
      onSelectAll: (b) {},
      sortColumnIndex: null,
      sortAscending: false,
      columns: <DataColumn>[
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("课程表"),
          )),
          numeric: false,
          onSort: (i, b) {
            print("$i $b");
          },
          tooltip: "To display first name of the Name",
        ),
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("周一"),
          )),
          numeric: false,
          onSort: (i, b) {
            print("$i $b");
          },
          tooltip: "To display last name of the Name",
        ),
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("周二"),
          )),
          numeric: false,
          onSort: (i, b) {
            print("$i $b");
          },
          tooltip: "To display last name of the Name",
        ),
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("周三"),
          )),
          numeric: false,
          onSort: (i, b) {
            print("$i $b");
          },
          tooltip: "To display last name of the Name",
        ),
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("周四"),
          )),
          numeric: false,
          onSort: (i, b) {
            print("$i $b");
          },
          tooltip: "To display last name of the Name",
        ),
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("周五"),
          )),
          numeric: false,
          onSort: (i, b) {
            print("$i $b");
          },
          tooltip: "To display last name of the Name",
        ),
      ],
      rows: rowsTime.map(
        (time) {
          List<DataCell> cells = [];
          for (int i = 0; i < dayColumns.length; i++) {
            DayCourse dayCourse = dayColumns[i];
            String firstText = "";
            String lastText = "";
            bool has = dayCourse.courseMap != null &&
                dayCourse.courseMap.containsKey(time);
            if (has) {
              CourseItem item = dayCourse.courseMap[time];
              if (item != null) {
                firstText = item.firstName;
                lastText = item.lastName;
              }
            }
            cells.add(new DataCell(
                Center(
                  child: firstText.isNotEmpty || lastText.isNotEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            firstText != null && firstText.isNotEmpty
                                ? Text(firstText)
                                : Container(),
                            lastText != null && lastText.isNotEmpty
                                ? Text(lastText)
                                : Container(),
                          ],
                        )
                      : Icon(
                          Icons.add,
                          color: Colors.orange,
                        ),
                ),
                showEditIcon: false,
                placeholder: false, onTap: () {
              _onTableItemClick(i, time);
              print('timetable --- $time ---- $i');
            }));
          }
          return DataRow(cells: cells);
        },
      ).toList());

  _onTableItemClick(int weekIndex, int timeId) {
    if (weekIndex <= 0) {
      return;
    }
    String editText = '';
    DayCourse dayCourse = dayColumns[weekIndex];
    CourseItem item = dayCourse.getCourseItem(timeId);
    if (item != null) {
      editText = item.firstName;
    } else {
      item = new CourseItem(id: timeId);
    }
    showCupertinoDialog(
        context: context,
        builder: (context) {
          AlertDialog alertDialog = new AlertDialog(
            title: Text("编辑"),
            content: Form(
                key: _formKey,
                child: TextFormField(
                    initialValue: editText,
                    decoration: InputDecoration(
                      hintText: "请输入课程名称",
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (String value) {
                      return value;
                    },
                    onSaved: (String value) {
                      print('title -- $value');
                      editText = value;
                    })),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    var _form = _formKey.currentState;
                    _form.save();
                    item.firstName = editText;
                    setState(() {
                      dayCourse?.addCourseItem(timeId, item);
                    });
                  },
                  child: Text("确定")),
            ],
          );
          return alertDialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "课程表",
          style:
              TextConfig.getTextStyle(size: TextConfig.CONTENT_TEXT_BIG_SIZE),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: SizedBox.expand(child: bodyData()),
      ),
    );
  }
}

class DayCourse {
  int startTime;
  Map<int, CourseItem> courseMap;

  DayCourse({this.startTime, this.courseMap});

  void addCourseItem(int id, CourseItem item) {
    if (courseMap == null) {
      courseMap = new Map();
    }
    courseMap[id] = item;
  }

  CourseItem getCourseItem(int id) {
    if (courseMap == null) {
      return null;
    }
    return courseMap[id];
  }

  static DayCourse createStartIndexDay() {
    Map<int, CourseItem> courseMap = new Map();
    DayCourse dayCourse = new DayCourse(startTime: 0, courseMap: courseMap);
    for (int i = 0; i < rowsTime.length; i++) {
      int id = rowsTime[i];
      String firstTime = "";
      if (id < 10) {
        firstTime = '''0$id:00''';
      } else {
        firstTime = '''$id:00''';
      }
      courseMap[id] =
          new CourseItem(id: id, firstName: firstTime, lastName: "$i");
    }
    return dayCourse;
  }
}

class CourseItem {
  int id;
  String firstName;
  String lastName;

  CourseItem({this.id, this.firstName, this.lastName});
}

var rowsTime = <int>[9, 10, 11, 12, 13, 14, 15, 16, 17];

var dayColumns = <DayCourse>[
  DayCourse.createStartIndexDay(),
  DayCourse(startTime: 1, courseMap: null),
  DayCourse(startTime: 2, courseMap: null),
  DayCourse(startTime: 3, courseMap: null),
  DayCourse(startTime: 4, courseMap: null),
  DayCourse(startTime: 5, courseMap: null),
];
