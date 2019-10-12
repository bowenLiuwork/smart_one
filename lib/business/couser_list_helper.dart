import 'dart:convert';

import 'package:smart_one/business/user_info_manager.dart';
import 'package:smart_one/model/teach_course.dart';
import 'package:smart_one/model/week_info.dart';
import 'package:smart_one/page/course_list_view.dart';
import 'package:http/http.dart';

import 'http_config.dart';

class CourseListHelper {
  static Future<List<ICourse>> getCourseList(int week) async {
    String res = await HttpConfig.getCourseWareByTeachWeek(
        week, 0, UserInfoManager.instance.getToken());
    print(res);
    List<ICourse> courseList = [];
    if (res != null && res.isNotEmpty) {
      var resJson = json.decode(res);
      var list = resJson['data'];
      if (list != null) {
        for (var item in list) {
          courseList.add(TeachCourse.createFromJson(json.encode(item)));
        }
      }
    }
    return courseList;
  }

  static Future<List<ICourse>> getCourseListByPage(int page) async {
    String teacherNum = UserInfoManager.instance.teacherInfo.teacherNum;
    String res = await HttpConfig.getCourseWareByTeacherAndPage(
        page, teacherNum, 0, UserInfoManager.instance.getToken());
    print(res);
    List<ICourse> courseList = [];
    if (res != null && res.isNotEmpty) {
      var resJson = json.decode(res);
      var list = resJson['data'];
      if (list != null) {
        for (var item in list) {
          courseList.add(TeachCourse.createFromJson(json.encode(item)));
        }
      }
    }
    return courseList;
  }

  static Future<WeekTimeInfo> getCurrentWeek() async {
    String res = await HttpConfig.getCurrentWeekClassWareInfo(
        UserInfoManager.instance.getToken());
    var resJson = json.decode(res);
    int weekCount = resJson['currentteachweek'];
    int beginDateTime = resJson['begindate'];
    WeekTimeInfo weekTimeInfo = new WeekTimeInfo(weekCount, beginDateTime);

    return weekTimeInfo;
  }

  static List<ICourse> getTestCourseList() {
    List<ICourse> list = new List();
    for (int i = 0; i < 20; i++) {
      list.add(new TestCourse());
    }
    return list;
  }
}

class TestCourse implements ICourse {
  @override
  String getCourseImage() {
    return "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2222127202,140139957&fm=26&gp=0.jpg";
  }

  @override
  String getCourseTeacher() {
    return "Doc liu";
  }

  @override
  String getCourseTitle() {
    return "2019 YCKJ 1730 1330 test Demo 托尔斯泰是的撒亲爱哒大发啊阿打发发顺丰";
  }

  @override
  int getDurationTime() {
    return new Duration(hours: 1, seconds: 14, minutes: 5).inMilliseconds;
  }

  @override
  int getPubTime() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String getId() {
    return null;
  }
}
