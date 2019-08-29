import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpConfig {
  static final String _APP_URL = "sp_app_server_url";
  static final String HOST = "http://47.107.247.14";

  static final String PORT = "8081";

  static String token = "";

  static String _saveSchecmeUrl = null;

  static void setAndSaveSchemeUrl(String schemeUrl) async {
    _saveSchecmeUrl = schemeUrl;
    if (schemeUrl == null) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool ok = await prefs.setString(_APP_URL, schemeUrl);
    print("save scheme url = $ok");
  }

  static Future<String> getSavedSchemeUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_APP_URL);
  }

  static Future<String> getSchcemeUrl() async {
    if (_saveSchecmeUrl == null || _saveSchecmeUrl.isEmpty) {
      _saveSchecmeUrl = await getSavedSchemeUrl();
    }
    if (_saveSchecmeUrl != null) {
      return _saveSchecmeUrl;
    }
    return "${HOST}" + ":$PORT";
  }

  static Future<String> getLoginUrl(String userName, String password) async {
    String appUrl = await getSchcemeUrl();
    String url =
        "$appUrl" + "/teacher/login?username=${userName}&password=${password}";
    return url;
  }

  static Future<String> login(String userName, String password) async {
    String url = await getLoginUrl(userName, password);
    print(url);
    var response = await http.get(url);
    String token = getHttpResponse(response);

    HttpConfig.token = token;
    return token;
  }

  static Future<String> scanLogin(String url) async {
    var response = await http.get(url);
    String res = getHttpResponse(response);
    print('scanLogin res === $res');
    return res;
  }

  static Future<String> getTcpServer(String token) async {
    String tcpUrl =
        await getSchcemeUrl() + "/teacher/gettcpserver?token=${token}";
    print('get tcp url == ' + tcpUrl);
    var response = await http.get(tcpUrl);
    String body = getHttpResponse(response);
    print('Response body: ${body}');
    Map<String, dynamic> user = json.decode(body);
    String tcpServer = user['data'];
    return tcpServer;
  }

  static String getHttpResponse(var response) {
    int code = response.statusCode;
    String body = response.body;
    if (code != 200) {
      return null;
    }
    return body;
  }

  static Future<String> getCourseWareByTeachWeek(
      var teachWeek, int deleted, String token) async {
    String url = await getSchcemeUrl() +
        "/teacher/getcoursewarebyteachweek?token=${token}&teachweek=$teachWeek&deleted=$deleted";
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getClassWareInfoById(
      String courseId, String token) async {
    String url = await getSchcemeUrl() +
        "/teacher/getcoursewareinfobyid?id=${courseId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCurrentWeekClassWareInfo(String token) async {
    String url = await getSchcemeUrl() +
        "/teacher/getcurrentteachingweek?token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCourseExercise(String courseId, String token) async {
    String url = await getSchcemeUrl() +
        "/teacher/getexercisebyid?id=${courseId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCourseChildExercise(
      String parentId, String token) async {
    String url = await getSchcemeUrl() +
        "/teacher/getchildbyparentid?id=${parentId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCourseTestPaper(String testId, String token) async {
    String url = await getSchcemeUrl() +
        "/teacher/gettestbyid?id=${testId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getLoginUserInfo(String token) async {
    String url = await getSchcemeUrl() + "/teacher/getmyinfo?token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }
}
