import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzxing/fzxing.dart';
import 'package:smart_one/business/couser_list_helper.dart';
import 'package:smart_one/business/http_config.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/business/user_info_manager.dart';
import 'package:smart_one/model/classes_info.dart';
import 'package:smart_one/model/week_info.dart';
import 'package:smart_one/page/course_header_view.dart';
import 'package:smart_one/page/course_list_view.dart';
import 'package:smart_one/page/page_details.dart';
import 'package:smart_one/page/pc_login_page.dart';
import 'package:smart_one/page/week_header_page.dart';
import 'package:smart_one/page/exit_login_page.dart';
import 'package:smart_one/widget/page_header_bar.dart';

class MyCoursePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyCoursePageState();
  }
}

class MyCoursePageState extends State<MyCoursePage>
    implements OnSocketStateListener, OnClickEvent {
  int curWeek;
  int startTime;
  int endTime;
  List<ICourse> weekCourseList = [];
  TcpControlHelper tcpControlHelper;
  bool _isConnectedPC = false;
  int curPage = 1;

  @override
  void initState() {
    tcpControlHelper = new TcpControlHelper((String jsonMessage) {
      SocketHelper.instance.write(jsonMessage);
    });
    SocketHelper.instance.setOnSocketStateListener(this);
    SocketHelper.instance.setMessageCallBack(
        onWeekChange: _onWeekChange, onStartCourse: _onStartCourse);
    super.initState();
    if (UserInfoManager.instance.isHighSchoolVersion) {
      _initPageCourseData(0);
    } else {
      _initWeekParams();
    }
  }

  _onWeekChange(int week) {
    _initWeekCourseData(week: week);
    int dWeek = week - curWeek;
    DateTime startDate = dWeek > 0
        ? DateTime.fromMillisecondsSinceEpoch(startTime)
            .add(Duration(days: dWeek.abs() * 7))
        : DateTime.fromMillisecondsSinceEpoch(startTime)
            .subtract(Duration(days: dWeek.abs() * 7));
    DateTime endDate = dWeek > 0
        ? DateTime.fromMillisecondsSinceEpoch(endTime)
            .add(Duration(days: dWeek.abs() * 7))
        : DateTime.fromMillisecondsSinceEpoch(endTime)
            .subtract(Duration(days: dWeek.abs() * 7));
    setState(() {
      curWeek = week;
      startTime = startDate.millisecondsSinceEpoch;
      endTime = endDate.millisecondsSinceEpoch;
    });
  }

  _onStartCourse(String courseId) {
    print('courseId --- $courseId');
    if (courseId != null) {
      bool isContainClassesInfo = courseId.contains(";");
      String tempId = courseId;
      if (isContainClassesInfo) {
        List<String> arr = courseId.split(";");
        tempId = arr[0];
      }
      ICourse course = findCourseById(tempId);
      if (course != null) {
        _goCoursePage(course);
      }
    }
  }

  ICourse findCourseById(String courseId) {
    for (ICourse course in weekCourseList) {
      if (course.getId() == courseId) {
        return course;
      }
    }
    return null;
  }

  void _initWeekCourseData({int week = -1}) async {
    if (week == -1) {
      week = curWeek;
    }
    List<ICourse> list = await CourseListHelper.getCourseList(week);
    setState(() {
      weekCourseList = list == null ? [] : list;
    });
  }

  void _initWeekParams() async {
    DateTime dateTime = DateTime.now();
    int day = dateTime.day;
    int temp = day ~/ 7;
    curWeek = temp + 1;
    DateTime curDate =
        new DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime start = curDate.subtract(new Duration(days: curDate.weekday - 1));
    DateTime end = start.add(new Duration(days: 6));
    startTime = start.millisecondsSinceEpoch;
    endTime = end.millisecondsSinceEpoch;

    WeekTimeInfo weekInfo = await CourseListHelper.getCurrentWeek();
    setState(() {
      curWeek = weekInfo.week;
      startTime = weekInfo.startTime;
      endTime = weekInfo.endTime;
    });

    _initWeekCourseData();
  }

  _initPageCourseData(int page) async {
    List<ICourse> list = await CourseListHelper.getCourseListByPage(page);
    setState(() {
      weekCourseList = list == null ? [] : list;
    });
  }

  _onPageChanged(int page) {
    curPage = page;
    int temp = page - 1;
    if (temp < 0) {
      temp = 0;
    }
    _initPageCourseData(temp);
  }

  @override
  Widget build(BuildContext context) {
    Column column = Column(
      children: <Widget>[
        CourseHeaderView(
          isConnected: _isConnectedPC,
          clickEvent: this,
        ),
        UserInfoManager.instance.isHighSchoolVersion
            ? PageHeaderView(
                pageIndex: curPage,
                onchange: _onPageChanged,
              )
            : WeekHeaderView(
                weekIndex: curWeek,
                startTime: startTime,
                endTime: endTime,
                onchange: (week, start, end) {
                  tcpControlHelper.controlWeek(week);
                  _initWeekCourseData(week: week);
                  setState(() {
                    curWeek = week;
                    startTime = start;
                    endTime = end;
                  });
                },
              ),
        SizedBox(
          height: 1,
          child: Container(
            color: Color(0xffd3d3d3),
          ),
        ),
        Expanded(
            child: CourseListView(
          list: weekCourseList,
          onItemClick: (pos) {
            if (UserInfoManager.instance.isHighSchoolVersion) {
              _onHighSchoolCourseClick(pos);
            } else {
              tcpControlHelper.controlStartClass(weekCourseList[pos].getId());
              _goCoursePage(weekCourseList[pos]);
            }
          },
        )),
      ],
    );

    Container container = new Container(
      color: Colors.white,
      child: column,
    );
    return container;
  }

  _goClassesCourse(ICourse course, ClassesInfo info) {
    tcpControlHelper.controlStartClass("${course.getId()};${info.id}");
    _goCoursePage(course);
  }

  void _onHighSchoolCourseClick(int pos) {
    List<ClassesInfo> infoList =
        UserInfoManager.instance.teacherClassesInfoList;
    if (infoList != null) {
      List<Widget> listW = [];
      listW.add(SizedBox(
        height: 1,
        child: Container(
          color: Colors.grey,
        ),
      ));
      for (int i = 0; i < infoList.length; i++) {
        ClassesInfo info = infoList[i];
        listW.add(ListTile(
          title: Center(
            child: Text("${info.classesName}"),
          ),
          onTap: () {
            print("info ==== ${info.classesName}");
            Navigator.of(context, rootNavigator: true).pop();
            _goClassesCourse(weekCourseList[pos], info);
          },
        ));
        if (i != infoList.length - 1) {
          listW.add(SizedBox(
            height: 1,
            child: Container(
              color: Colors.grey,
            ),
          ));
        }
      }
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Center(
                child: Text("选择班级"),
              ),
              titlePadding: EdgeInsets.all(10),
              backgroundColor: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              children: listW,
            );
          });
    } else {
      tcpControlHelper.controlStartClass(weekCourseList[pos].getId());
      _goCoursePage(weekCourseList[pos]);
    }
  }

  void _goCoursePage(ICourse course) {
    Navigator.of(context, rootNavigator: true)
        .push(new CupertinoPageRoute(builder: (context) {
      return new LearnPage(
        courseId: course.getId(),
        course: course,
      );
    }));
  }

  @override
  void onSocketConnected() {
    print('onSocketConnected--------------');
    setState(() {
      _isConnectedPC = true;
    });
  }

  @override
  void onSocketDisconnected() {
    setState(() {
      _isConnectedPC = false;
    });
  }

  @override
  void onSocketError(e) {
    setState(() {
      _isConnectedPC = false;
    });
  }

  @override
  void onSocketStart(String host, int port) {
    Fluttertoast.showToast(
        msg: "连接${host}:$port",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  @override
  void onCalendarClick() {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(startTime);
    DateTime firstDate = DateTime(dateTime.year, 1, 1);
    DateTime lastDate = DateTime(dateTime.year, 12, 31);
    Future<DateTime> future = showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: firstDate,
        lastDate: lastDate);
    future.then((date) {
      if (date.millisecondsSinceEpoch < startTime) {
        int weekIndex =
            Duration(milliseconds: startTime - date.millisecondsSinceEpoch)
                        .inDays ~/
                    7 +
                1;
        _onWeekChange(curWeek - weekIndex);
      } else if (date.millisecondsSinceEpoch > endTime) {
        int weekIndex =
            Duration(milliseconds: date.millisecondsSinceEpoch - endTime)
                        .inDays ~/
                    7 +
                1;
        _onWeekChange(curWeek + weekIndex);
      }
    });
  }

  @override
  void onScanClick() {
    Future<List<String>> future = Fzxing.scan(continuousInterval: 1000);
    future.then((List<String> list) {
      print('scan value length == ${list.length}');
      if (list != null && list.length > 0) {
        String res = "${list[0]}&token=${UserInfoManager.instance.getToken()}";
        print('scan value length == ${res}');
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (_) {
          return new PCLogin(
            loginUrl: res,
          );
        }));
      }
    });
  }

  @override
  void onPCConnectClick(bool isPcConnected) {
    if (isPcConnected) {
      Future<bool> futureExited = Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (_) {
        return new ExitLoginPage();
      }));
      futureExited.then((isExited) {
        setState(() {
          _isConnectedPC = false;
        });
      });
    }
  }

  @override
  void onSearchClick(String text) {}
}
