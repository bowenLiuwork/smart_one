import 'dart:core';
import 'package:smart_one/model/Point.dart';

///
/// TCP 发送指令
///
typedef SendTcpMessage = void Function(String jsonMessage);

class TcpControlHelper {
  SendTcpMessage sendTcpMessage;

  MediaControl _mediaControl;

  TcpControlHelper(SendTcpMessage this.sendTcpMessage) {}

  void controlWeek(int week) {
    String json = createChannelJson(20, week);
    sendTcpMessage(json);
  }

  ///
  ///开始上课
  ///
  void controlStartClass(String courseid) {
    String json = createChannelJson(21, courseid);
    sendTcpMessage(json);
  }

  ///
  ///结束上课
  ///
  void controlEndClass(String courseid) {
    String json = createChannelJson(22, courseid);
    sendTcpMessage(json);
  }

  ///
  /// 设置黑板大小
  ///
  void controlBlackBoardSize(Point size) {
    String json = createChannelJson(23, size.toString());
    sendTcpMessage(json);
  }

  ///
  /// 打开多媒体
  ///
  void openFile(String filePath) {
    String json = createChannelJson(32, filePath);
    sendTcpMessage(json);
  }

  void openMediaNode(num nodeChannel, var path) {
    String json = createChannelJson(nodeChannel, path);
    sendTcpMessage(json);
  }

  ///
  /// 打开试卷
  ///
  void openTestPaper(int paperId) {
    String json = createChannelJson(33, paperId);
    sendTcpMessage(json);
  }

  ///
  /// 打开习题
  ///
  void openExample(int exampleId) {
    String json = createChannelJson(34, exampleId);
    sendTcpMessage(json);
  }

  void startRecord() {
    String json = createChannelJson(11, 1);
    sendTcpMessage(json);
  }

  void stopRecord() {
    String json = createChannelJson(11, 0);
    sendTcpMessage(json);
  }

  ///
  /// 上课签到
  ///
  void courseQianDao() {
    String json = createChannelJson(50, "");
    sendTcpMessage(json);
  }

  ///
  /// 上课随机点名
  ///
  void courseDianMing() {
    String json = createChannelJson(51, "");
    sendTcpMessage(json);
  }

  ///
  ///举手抢答
  ///
  void courseJuShouQiangDa() {
    String json = createChannelJson(52, "");
    sendTcpMessage(json);
  }

  void startQiangDa() {
    String json = createChannelJson(520, "");
    sendTcpMessage(json);
  }

  void stopQiangDa() {
    String json = createChannelJson(521, "");
    sendTcpMessage(json);
  }

  void startDianMing() {
    String json = createChannelJson(510, "");
    sendTcpMessage(json);
  }

  void stopDianMing() {
    String json = createChannelJson(511, "");
    sendTcpMessage(json);
  }

  ///
  /// 多媒体控制
  ///
  MediaControl getMediaControl() {
    if (_mediaControl == null) {
      _mediaControl = new MediaControl(sendTcpMessage);
    }
    return _mediaControl;
  }

  ///
  ///0-7依次激光笔、RED、BLACK、WHITE、GREEN、MAGENTA、CYAN、FLUORESCENCE；8橡皮檫、9清除画布
  ///
  void controlBlackBoard(int controlNum) {
    String json = createChannelJson(36, controlNum);
    sendTcpMessage(json);
  }

  void sendPaintPoint(List<Point> points) {
    if (points != null && points.length > 0) {
      String msg = '';
      for (int i = 0; i < points.length; i++) {
        Point point = points[i];
        if (i < points.length - 1) {
          msg = msg + "${point.toString()}";
        } else {
          msg = msg + "${point.toString()}";
        }
      }
      print('point --- ${msg}');
      String json = createChannelJson(37, msg);
      sendTcpMessage(json);
    }
  }

  void sendStartPaintPoint(Point point) {
    if (point != null) {
      String json = createChannelJson(38, point.toString());
      sendTcpMessage(json);
    }
  }

  void sendEndPaintPoint(Point point) {
    if (point != null) {
      String json = createChannelJson(39, point.toString());
      sendTcpMessage(json);
    }
  }

  static String createChannelJson(var channel, var comtent) {
    var json = '{ "channel": "${channel}", "comtent": "${comtent}" }';
    return json;
  }
}

class MediaControl {
  static final int channel = 35;
  SendTcpMessage sendTcpMessage;

  MediaControl(SendTcpMessage this.sendTcpMessage) {}

  void previous() {
    String json = TcpControlHelper.createChannelJson(channel, "previous");
    sendTcpMessage(json);
  }

  void next() {
    String json = TcpControlHelper.createChannelJson(channel, "next");
    sendTcpMessage(json);
  }

  void first() {
    String json = TcpControlHelper.createChannelJson(channel, "first");
    sendTcpMessage(json);
  }

  void last() {
    String json = TcpControlHelper.createChannelJson(channel, "last");
    sendTcpMessage(json);
  }

  void left() {
    String json = TcpControlHelper.createChannelJson(channel, "left");
    sendTcpMessage(json);
  }

  void right() {
    String json = TcpControlHelper.createChannelJson(channel, "right");
    sendTcpMessage(json);
  }

  void zoomin() {
    String json = TcpControlHelper.createChannelJson(channel, "zoomin");
    sendTcpMessage(json);
  }

  void zoomout() {
    String json = TcpControlHelper.createChannelJson(channel, "zoomout");
    sendTcpMessage(json);
  }

  void fitScreenSize() {
    String json = TcpControlHelper.createChannelJson(channel, "fitviewratio");
    sendTcpMessage(json);
  }

  void fitImageSize() {
    String json = TcpControlHelper.createChannelJson(channel, "originalratio");
    sendTcpMessage(json);
  }

  void fitWidth() {
    String json = TcpControlHelper.createChannelJson(channel, "fitviewwidth");
    sendTcpMessage(json);
  }

  void fitHeight() {
    String json = TcpControlHelper.createChannelJson(channel, "fitviewheight");
    sendTcpMessage(json);
  }

  void play() {
    String json = TcpControlHelper.createChannelJson(channel, "play");
    sendTcpMessage(json);
  }

  void pause() {
    String json = TcpControlHelper.createChannelJson(channel, "pause");
    sendTcpMessage(json);
  }

  void increasevolume() {
    String json = TcpControlHelper.createChannelJson(channel, "increasevolume");
    sendTcpMessage(json);
  }

  void reducevolume() {
    String json = TcpControlHelper.createChannelJson(channel, "reducevolume");
    sendTcpMessage(json);
  }
}
