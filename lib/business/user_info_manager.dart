import 'package:smart_one/model/classes_info.dart';
import 'package:smart_one/model/teacher_info.dart';

class UserInfoManager {
  //单例 --------
  factory UserInfoManager() => _getInstance();

  static UserInfoManager get instance => _getInstance();

  static UserInfoManager _instance;

  UserInfoManager._internal() {
    // 初始化
  }

  static UserInfoManager _getInstance() {
    if (_instance == null) {
      _instance = new UserInfoManager._internal();
    }
    return _instance;
  }

//-------------------

  String _token;

  bool _isHighSchoolVersion = false;

  bool get isHighSchoolVersion => _isHighSchoolVersion;

  TeacherInfo _teacherInfo;

  TeacherInfo get teacherInfo => _teacherInfo;

  List<ClassesInfo> _teacherClassesInfoList;


  List<ClassesInfo> get teacherClassesInfoList => _teacherClassesInfoList;

  set teacherClassesInfoList(List<ClassesInfo> value) {
    _teacherClassesInfoList = value;
  }

  set teacherInfo(TeacherInfo value) {
    _teacherInfo = value;
  }

  void setHighSchoolVersion(bool value) {
    _isHighSchoolVersion = value;
  }

  String getToken() {
    return _token;
  }

  void setToken(var token) {
    _token = token;
  }
}
