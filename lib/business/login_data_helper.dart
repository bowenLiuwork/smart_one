import 'package:shared_preferences/shared_preferences.dart';

class LoginDataHelper {
  static final String _LOGIN_ACTIVE_STATUS =
      "LoginDataHelper_LOGIN_ACTIVE_STATUS";
  static final String _LOGIN_USER_NAME = "LoginDataHelper_LOGIN_USER_NAME";
  static final String _LOGIN_USER_PWD = "LoginDataHelper_LOGIN_USER_PWD";

  //登录状态是否是激活状态
  static Future<bool> isLoginActive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_LOGIN_ACTIVE_STATUS);
  }

  static void setLoginActiveState(bool isActiveState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_LOGIN_ACTIVE_STATUS, isActiveState);
  }

  static saveLoginUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_LOGIN_USER_NAME, userName);
  }

  static saveLoginPwd(String pwd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool ok = await prefs.setString(_LOGIN_USER_PWD, pwd);
    print("saveLoginPwd ---- $pwd, === $ok");
  }

  static Future<String> getLoginUserName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_LOGIN_USER_NAME);
  }

  static Future<String> getLoginPWD() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('getLoginPWD-------------');
    return prefs.getString(_LOGIN_USER_PWD);
  }
}
