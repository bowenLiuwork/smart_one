
class TeacherInfo {
  String id;
  String teacherNum;
  String teacherName;
  String userName;
  String gender;

  static TeacherInfo createFromJson(Map<String, dynamic> json) {
    TeacherInfo teacherInfo = new TeacherInfo();
    teacherInfo.id = json['id'];
    teacherInfo.teacherNum = json['teacher_no'];
    teacherInfo.teacherName = json['teacher_name'];
    teacherInfo.userName = json['user_name'];
    teacherInfo.gender = json['gender'];
    return teacherInfo;
  }

}