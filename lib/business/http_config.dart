import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpConfig {
  static final String HOST = "http://47.107.247.14";

  static final String PORT = "8081";

  static String token = "";

  static String getSchcemeUrl() {
    return "${HOST}" + ":$PORT";
  }

  static String getLoginUrl(String userName, String password) {
    String url = "${getSchcemeUrl()}" +
        "/teacher/login?username=${userName}&password=${password}";
    return url;
  }

  static Future<String> login(String userName, String password) async {
    String url = getLoginUrl(userName, password);
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
        "${getSchcemeUrl()}" + "/teacher/gettcpserver?token=${token}";
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
    String url = getSchcemeUrl() +
        "/teacher/getcoursewarebyteachweek?token=${token}&teachweek=$teachWeek&deleted=$deleted";
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getClassWareInfoById(
      String courseId, String token) async {
    String url = getSchcemeUrl() +
        "/teacher/getcoursewareinfobyid?id=${courseId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCurrentWeekClassWareInfo(String token) async {
    String url = getSchcemeUrl() +
        "/teacher/getcurrentteachingweek?token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCourseExercise(String courseId, String token) async {
    String url = getSchcemeUrl() +
        "/teacher/getexercisebyid?id=${courseId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCourseChildExercise(String parentId, String token) async {
    String url = getSchcemeUrl() +
        "/teacher/getchildbyparentid?id=${parentId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }

  static Future<String> getCourseTestPaper(String testId, String token) async {
    String url = getSchcemeUrl() +
        "/teacher/gettestbyid?id=${testId}&token=${token}";
    print('url == $url');
    var response = await http.get(url);
    String res = getHttpResponse(response);
    return res;
  }
}
