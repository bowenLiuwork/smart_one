import 'dart:convert';

import 'package:smart_one/business/course_media_helper.dart';
import 'package:smart_one/page/course_list_view.dart';

class TeachCourse implements ICourse {
  /*
   * "subject_id":"100000",
      "period":"",
      "teacher_name":"飞云化龙",
      "create_time":1555661265000,
      "modify_time":1555661265000,
      "title1":"测试精品5",
      "school_year":"",
      "relation":true,
      "ready":true,
      "grade":"",
      "subject_name":"语文",
      "semester":"",
      "id":"2d835ea0d6904240bd3a62f2046bc75d"
   */
  String id;
  String subject_id;
  String period;
  String teacher_name;
  String thumbnail;
  int create_time;
  int modify_time;
  String title1;
  String school_year;
  bool relation;
  bool ready;
  String grade;
  String subject_name;
  String semester;

  TeachCourse() {}

  static TeachCourse createFromJson(String jsonstr) {
    Map<String, dynamic> map = json.decode(jsonstr);
    TeachCourse course = new TeachCourse();
    course.id = map['id'];
    course.subject_id = map['subject_id'];
    course.period = map['period'];
    course.teacher_name = map['teacher_name'];
    course.thumbnail = map['thumbnail'];
    course.create_time = map['create_time'];
    course.modify_time = map['modify_time'];
    course.title1 = map['title1'];
    course.school_year = map['school_year'];
    course.relation = map['relation'];
    course.ready = map['ready'];
    course.id = map['id'];
    course.grade = map['grade'];
    course.subject_name = map['subject_name'];
    course.semester = map['semester'];
    return course;
  }

  @override
  String getCourseImage() {
    return thumbnail;
  }

  @override
  String getCourseTeacher() {
    return teacher_name;
  }

  @override
  String getCourseTitle() {
    return title1;
  }

  @override
  int getDurationTime() {
    return new Duration(hours: 0, seconds: 0, minutes: 0).inMilliseconds;
  }

  @override
  int getPubTime() {
    return modify_time;
  }

  @override
  String getId() {
    return id;
  }
}

class ExerciseMedia implements ICourseMediaNode {
  /**
   * {
      score: 1,
      exerciseid: "100046",
      serial: 0
      }
   */

  ICourseMediaNode parentMediaNode;
  num score;
  String id;
  num serial;
  CourseMediaWidgetType courseMediaWidgetType =
      CourseMediaWidgetType.Widget_Content;

  static ExerciseMedia createSwitchMedia() {
    ExerciseMedia media = new ExerciseMedia();
    media.courseMediaWidgetType = CourseMediaWidgetType.Widget_Switch;
    return media;
  }

  @override
  String getNodePath() {
    return id;
  }

  @override
  String getMediaType() {
    return null;
  }

  @override
  String getThumb() {
    return 'images/none_image.png';
  }

  @override
  int getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String getTitle() {
    return '$serial';
  }

  @override
  CourseMediaWidgetType getWidgetType() {
    return courseMediaWidgetType;
  }

  @override
  ICourseMediaNode getParentNode() {
    return parentMediaNode;
  }

  @override
  num getNodeChannel() {
    return 34;
  }
}

class TestPaperCourseMedia implements ICourseMediaNode {
  /**
   * create_time: "Thu Apr 11 15:48:34 2019",
      title1: "测试试卷1",
      id: "07f2e3d7dec54d09a7d9a22c00a9d5a6",
      type: "0"
   */

  String title;
  String id;
  String type;
  int createTime;
  List<ExerciseMedia> exerciseList = [];

  static TestPaperCourseMedia createTestPaperByJson(var jsonMap) {
    TestPaperCourseMedia paperCourseMedia = new TestPaperCourseMedia();
    paperCourseMedia.title = jsonMap['title1'];
    paperCourseMedia.id = jsonMap['id'];
    paperCourseMedia.type = jsonMap['type'];
    paperCourseMedia.createTime = jsonMap['create_time'];
    paperCourseMedia.exerciseList = [];
    var arr = jsonMap['exercise'];
    for (var item in arr) {
      ExerciseMedia media = new ExerciseMedia();
      media.parentMediaNode = paperCourseMedia;
      media.id = item['exerciseid'];
      media.score = item['score'];
      media.serial = item['serial'];
      paperCourseMedia.exerciseList.add(media);
    }
    return paperCourseMedia;
  }

  @override
  String getNodePath() {
    return id;
  }

  @override
  String getMediaType() {
    return type;
  }

  @override
  String getThumb() {
    return 'images/none_image.png';
  }

  @override
  int getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String getTitle() {
    return title;
  }

  @override
  CourseMediaWidgetType getWidgetType() {
    return CourseMediaWidgetType.Widget_Content;
  }

  @override
  ICourseMediaNode getParentNode() {
    return null;
  }

  @override
  num getNodeChannel() {
    return 33;
  }
}

class CourseMedia implements ICourseMediaNode {
  /**
   * {
      path: "20190426/20190426222115040",
      name: "《诗歌鉴赏之情感和形象》 ",
      type: "pptx"
      }
   */

  String path;
  String name;
  String type;
  String title;
  String thumbnail;

  @override
  String getThumb() {
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return thumbnail;
    }
    return "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2222127202,140139957&fm=26&gp=0.jpg";
  }

  @override
  int getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String getTitle() {
    return title;
  }

  @override
  String getNodePath() {
    return '$path/$name.$type';
  }

  @override
  String getMediaType() {
    return type;
  }

  @override
  CourseMediaWidgetType getWidgetType() {
    return CourseMediaWidgetType.Widget_Content;
  }

  @override
  ICourseMediaNode getParentNode() {
    return null;
  }

  @override
  num getNodeChannel() {
    return 32;
  }
}

class TeachCourseDetails {
  /*
  * subject_id: "100000",
template: false,
chapter: "",
teacher_name: "飞云化龙",
modify_time: 1556512220000,
recommend: false,
school_year: "",
required: false,
relation: true,
grade_id: "",
fine: false,
ready: true,
id: "d851b0b0022b411592943fefc6805159",
keyword: "",
teacher_no: "100001",
period: "",
thumbnail: "",
create_time: 1555588948000,
title1: "测试精品教案2",
title2: "热歌",
optional: false,
medias: [
{
path: "20190426/20190426222115040",
name: "《诗歌鉴赏之情感和形象》 ",
type: "pptx"
},
{
path: "20190428/20190428134250474",
name: "硅谷科技营-7月7号在上海开营(1)",
type: "pdf"
}
],
content5: "<body style=\" font-family:\"HYQiHei-60S\"; font-size:14px; font-weight:400; font-style:normal;\"> <p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><br /></p></body>",
deleted: false,
tests: [ ],
content4: "<body style=\" font-family:\"HYQiHei-60S\"; font-size:14px; font-weight:400; font-style:normal;\"> <p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><br /></p></body>",
content3: "<body style=\" font-family:\"HYQiHei-60S\"; font-size:14px; font-weight:400; font-style:normal;\"> <p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><br /></p></body>",
content2: "<body style=\" font-family:\"HYQiHei-60S\"; font-size:14px; font-weight:400; font-style:normal;\"> <p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><br /></p></body>",
grade: "",
content1: "<body style=\" font-family:\"HYQiHei-60S\"; font-size:14px; font-weight:400; font-style:normal;\"> <p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><br /></p></body>",
subject_name: "语文",
semester: ""
*/

  List<CourseMedia> mediaList;
  List<TestPaperCourseMedia> testPaperMediaList;

  TeachCourseDetails() {}

  static TeachCourseDetails fromJson(String jsonStr) {
    var jsonRes = json.decode(jsonStr);
    var mediaArr = jsonRes['medias'];
    var testArr = jsonRes['tests'];
    TeachCourseDetails details = new TeachCourseDetails();
    List<CourseMedia> list = [];
    for (var item in mediaArr) {
      CourseMedia media = new CourseMedia();
      media.path = item['path'];
      media.name = item['name'];
      media.type = item['type'];
      media.title = item['title'];
      media.thumbnail = item['thumbnail'];
      list.add(media);
    }
    details.mediaList = list;
    List<TestPaperCourseMedia> tests = [];
    for (var item in testArr) {
      TestPaperCourseMedia test = new TestPaperCourseMedia();
      test.title = item['title1'];
      test.id = item['id'];
      test.type = item['type'];
      tests.add(test);
    }
    details.testPaperMediaList = tests;

    return details;
  }
}
