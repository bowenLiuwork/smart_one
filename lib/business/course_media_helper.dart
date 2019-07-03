import 'dart:convert';

import 'package:smart_one/business/http_config.dart';
import 'package:smart_one/business/user_info_manager.dart';
import 'package:smart_one/model/teach_course.dart';

class CourseMediaHelper {
  TeachCourseDetails _courseDetails;

  CourseMediaHelper() {}

  Future<List<ICourseMediaNode>> getMediaList(String courseId) async {
    if (_courseDetails != null) {
      return _courseDetails.mediaList;
    }
    String res = await HttpConfig.getClassWareInfoById(
        courseId, UserInfoManager.instance.getToken());
    print('res == $res');
    var jsonRes = json.decode(res);
    var dataJson = jsonRes['data'];

    _courseDetails = TeachCourseDetails.fromJson(json.encode(dataJson));
    return _courseDetails.mediaList;
  }

  Future<List<ICourseMediaNode>> getTestMediaList(String courseId) async {
    if (_courseDetails != null) {
      return _courseDetails.testPaperMediaList;
    }
    String res = await HttpConfig.getClassWareInfoById(
        courseId, UserInfoManager.instance.getToken());
    print('res == $res');
    var jsonRes = json.decode(res);
    var dataJson = jsonRes['data'];

    _courseDetails = TeachCourseDetails.fromJson(json.encode(dataJson));
    return _courseDetails.testPaperMediaList;
  }

  Future<List<ICourseMediaNode>> getTestPaperExerciseList(String testId) async {
    String res = await HttpConfig.getCourseTestPaper(
        testId, UserInfoManager.instance.getToken());
    print('res == $res');
    var jsonRes = json.decode(res);
    var dataJson = jsonRes['data'];
    TestPaperCourseMedia testPaperCourseMedia =
        TestPaperCourseMedia.createTestPaperByJson(dataJson);
    List<ICourseMediaNode> exerciseList = testPaperCourseMedia.exerciseList;
    return exerciseList;
  }
}

enum CourseMediaWidgetType {
  Widget_Switch,
  Widget_Content,
}

abstract class ICourseMediaNode {
  num getNodeChannel();

  CourseMediaWidgetType getWidgetType();

  ICourseMediaNode getParentNode();

  String getNodePath();

  String getThumb();

  String getTitle();

  int getTimestamp();

  String getMediaType();
}
