import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/business/user_info_manager.dart';
import 'package:smart_one/model/Point.dart';

import 'http_config.dart';

abstract class IReceiveMessage {
  void onReceive(String msg);
}

abstract class OnSocketStateListener {
  void onSocketStart(String host, int port);

  void onSocketError(var e);

  void onSocketConnected();

  void onSocketDisconnected();
}

class SocketHelper {
  //单例 --------
  factory SocketHelper() => _getInstance();

  static SocketHelper get instance => _getInstance();

  static SocketHelper _instance;

  SocketHelper._internal() {
    // 初始化
  }

  static SocketHelper _getInstance() {
    if (_instance == null) {
      _instance = new SocketHelper._internal();
    }
    return _instance;
  }

//-------------------

  OnSocketStateListener _onSocketStateListener;

  String _host = '';
  int _port;

  Socket socket;

  List<IReceiveMessage> _receiveMessageList = [];

  ChannelMessageReceive _channelMessageReceive = new ChannelMessageReceive();

  Timer _timer;

  bool _isStartConnect = false;

  void startConnect() async {
    String token = UserInfoManager.instance.getToken();
    String tcpAddress = '';
    _isStartConnect = true;
    try {
      Future<String> getTcp = Future.doWhile(() async {
        String tcpInfo = await HttpConfig.getTcpServer(token);
        print("tcpInfo=== $tcpInfo");
        if (tcpInfo == null || tcpInfo.isEmpty) {
          return true;
        } else {
          tcpAddress = tcpInfo;
          print('tcpAddress == ' + tcpAddress);
          return false;
        }
      }).then((_) {
        return tcpAddress;
      });
      getTcp.then((String address) {
        _parseTcpAddressInfo(tcpAddress);
        connect();
        addReceiveMessage(_channelMessageReceive);
      }).whenComplete(() {
        _isStartConnect = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void startHeartCheck() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(milliseconds: 1 * 1000), (timer) {
        String hearJson = TcpControlHelper.createChannelJson('1', 'hello');
        write(hearJson);
      });
    }
  }

  void stopHeartCheck() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  void _parseTcpAddressInfo(String address) {
    if (address == null || address.isEmpty) {
      return;
    }
    List<String> arr = address.split(':');
    String host = arr[0];
    int port = int.parse(arr[1]);
    print('host == $host');
    print('port == $port');
    _host = host;
    _port = port;
    if (_onSocketStateListener != null) {
      _onSocketStateListener.onSocketStart(_host, _port);
    }
  }

  void setOnSocketStateListener(OnSocketStateListener listener) {
    this._onSocketStateListener = listener;
  }

  void setMessageCallBack(
      {OnExit onExit,
      OnPngImage onPngImage,
      OnWeekChange onWeekChange,
      OnStartCourse onStartCourse,
      OnEndCourse onEndCourse,
      OnSetBlackBoardSize onSetBlackBoardSize,
      OnOpenMedia onOpenMedia,
      OnOpenTestPaper onOpenTestPaper,
      OnOpenExample onOpenExample,
      OnMediaControl onMediaControl,
      OnSetBoardPaint onSetBoardPaint,
      OnPaintPosition onPaintPosition,
      OnPaintPosStart onPaintPosStart,
      OnPaintPosEnd onPaintPosEnd,
      OnPageInfo onPageInfo,
      OnRecordState onRecordState}) {
    print("onPngImage === $onPngImage");
    _channelMessageReceive.setCallBack(
      onExit: onExit,
      onPngImage: onPngImage,
      onWeekChange: onWeekChange,
      onStartCourse: onStartCourse,
      onEndCourse: onEndCourse,
      onSetBlackBoardSize: onSetBlackBoardSize,
      onOpenMedia: onOpenMedia,
      onOpenTestPaper: onOpenTestPaper,
      onOpenExample: onOpenExample,
      onMediaControl: onMediaControl,
      onSetBoardPaint: onSetBoardPaint,
      onPaintPosition: onPaintPosition,
      onPaintPosStart: onPaintPosStart,
      onPaintPosEnd: onPaintPosEnd,
      onPageInfo: onPageInfo,
      onRecordState: onRecordState,
    );
  }

  String cacheStr = '';
  RegExp reg = new RegExp(
      r'''(\{[\s\w\"\,\;\.\(\)\*\%\&\^\$\#\@\!\~\=\?\\\:^}\+\-\*\/]*\})''');

  void onData(var ondata) {
    print('ondata == $ondata');
    _parseReceiveDataSync(ondata);
  }

  _parseReceiveDataSync(var ondata) {
    Future<List<String>> paserData = Future(() {
      var data = ondata; //utf8.decode(ondata);
      print('onData === $data');
      cacheStr = '${cacheStr}${data}';
      cacheStr = cacheStr.replaceAll(r'\s', "");
      print('onData before cacheStr === $cacheStr');
      Iterable<Match> matches = reg.allMatches(cacheStr);
      print('onData matches === ${matches.toList().length}');
      List<String> jsonList = [];
      for (Match m in matches) {
        print('m == ${m.group(0)}');
        if (m.groupCount >= 0) {
          String item = m.group(0);
          jsonList.add(item);
          cacheStr = cacheStr.replaceAll(item, "");
        }
      }
      cacheStr = cacheStr.replaceAll(" ", "");
      cacheStr = cacheStr.replaceAll(r'''\s''', "");
      print("onData cacheStr === $cacheStr");
      return jsonList;
    });
    paserData.then((jsonList) {
      for (String item in jsonList) {
        _notifyMessage(item);
      }
    });
  }

  _parseReceiveData(var data) async {
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(jsonHandler, receivePort.sendPort);
    // The 'echo' isolate sends it's SendPort as the first message
    SendPort sendPort = await receivePort.first;
    JSONParserData parserData = await sendReceive(sendPort, data, cacheStr);
    cacheStr = parserData.noJsonData == null ? '' : parserData.noJsonData;
    for (String item in parserData.jsonList) {
      _notifyMessage(item);
    }
  }

  static jsonHandler(SendPort sendPort) async {
    String cacheStr = '';
    RegExp reg = new RegExp(
        r'''(\{[\s\w\"\,\;\.\(\)\*\%\&\^\$\#\@\!\~\=\?\\\:^}\+\-\*\/]*\})''');
    // Open the ReceivePort for incoming messages.
    ReceivePort port = new ReceivePort();
    // Notify any other isolates what port this isolate listens to.
    sendPort.send(port.sendPort);

    await for (var msg in port) {
      var ondata = msg[0];
      var cacheData = msg[1];
      SendPort replyTo = msg[2];
      var data = utf8.decode(ondata);
      print('onData === $data');
      cacheStr = '${cacheData}${data}';
      cacheStr = cacheStr.replaceAll(r'\s', "");
      print('onData before cacheStr === $cacheStr');
      Iterable<Match> matches = reg.allMatches(cacheStr);
      print('onData matches === ${matches.toList().length}');
      List<String> jsonList = [];
      for (Match m in matches) {
        print('m == ${m.group(0)}');
        if (m.groupCount >= 0) {
          String item = m.group(0);
          jsonList.add(item);
          cacheStr = cacheStr.replaceAll(item, "");
        }
      }
      cacheStr = cacheStr.replaceAll(" ", "");
      cacheStr = cacheStr.replaceAll(r'''\s''', "");
      print("onData cacheStr === $cacheStr");
      replyTo.send(JSONParserData(jsonList, cacheStr));
    }
  }

  Future sendReceive(SendPort port, msg, msg1) {
    ReceivePort response = new ReceivePort();
    port.send([msg, msg1, response.sendPort]);
    return response.first;
  }

  _notifyMessage(String msg) {
    for (IReceiveMessage receiveMessage in _receiveMessageList) {
      receiveMessage.onReceive(msg);
    }
  }

  void onError(Object error, [StackTrace stackTrace]) {
    _onSocketStateListener?.onSocketError(error);
    print("onError ------------------ ");
    print('onError --- $error');
  }

  void addReceiveMessage(IReceiveMessage receive) {
    _receiveMessageList.add(receive);
  }

  void removeReceiveMessage(IReceiveMessage receive) {
    _receiveMessageList.remove(receive);
  }

  void clearReceiveMessage() {
    _receiveMessageList.clear();
  }

  void onDone() {
    print('onDone --- ');
//    _onSocketStateListener?.onSocketConnected();
  }

  void write(String json) {
    try {
      if (socket != null) {
        print('write json == $json');
        socket.write(json);
      } else {
        print('socket no conneced ----- $_isStartConnect');
        if (!_isStartConnect) {
          startConnect();
        }
        _onSocketStateListener?.onSocketDisconnected();
      }
    } catch (e) {
      print('socket no conneced ----- $e');
      print('socket no conneced ----- $_isStartConnect');
      if (!_isStartConnect) {
        startConnect();
      }
      _onSocketStateListener?.onSocketDisconnected();
    }
  }

  void close() {
    if (socket != null) {
      socket.close();
      socket.destroy();
    }
    _onSocketStateListener?.onSocketDisconnected();
  }

  void connect() async {
    if (_host != null && _host.isNotEmpty && _port != 0) {
      print('connect ----------------------- ');
      ConnectionTask<Socket> task = await Socket.startConnect(_host, _port);
      Future<Socket> future = task.socket;
      future.then((value) {
        socket = value;
        socket
            .transform(utf8.decoder)
            .listen(onData, onError: onError, onDone: onDone);
        write('hello');
        _isStartConnect = false;
        _onSocketStateListener?.onSocketConnected();
      }).whenComplete(() {
        _isStartConnect = false;
      });
    } else {
      _isStartConnect = false;
      print('connect ----------------------- fail');
      socket = null;
    }
  }
}

typedef OnExit = void Function();
typedef OnPngImage = void Function(dynamic image);
typedef OnWeekChange = void Function(int week);
typedef OnStartCourse = void Function(String courseid);
typedef OnEndCourse = void Function(String courseid);
typedef OnSetBlackBoardSize = void Function(int w, int h);
typedef OnOpenMedia = void Function(String mediaPath);
typedef OnOpenTestPaper = void Function(String paperId);
typedef OnOpenExample = void Function(String exampleId);
typedef OnMediaControl = void Function(String cmdStr);
typedef OnSetBoardPaint = void Function(int index);
typedef OnPaintPosition = void Function(List<Point> points);
typedef OnPaintPosStart = void Function(List<Point> points);
typedef OnPaintPosEnd = void Function(List<Point> points);
typedef OnPageInfo = void Function(String info);
typedef OnRecordState = void Function(bool isStartRecord);

class ChannelMessageReceive implements IReceiveMessage {
  OnExit _onExit;
  OnPngImage _onPngImage;
  OnWeekChange _onWeekChange;
  OnStartCourse _onStartCourse;
  OnEndCourse _onEndCourse;
  OnSetBlackBoardSize _onSetBlackBoardSize;
  OnOpenMedia _onOpenMedia;
  OnOpenTestPaper _onOpenTestPaper;
  OnOpenExample _onOpenExample;
  OnMediaControl _onMediaControl;
  OnSetBoardPaint _onSetBoardPaint;
  OnPaintPosition _onPaintPosition;
  OnPaintPosStart _onPaintPosStart;
  OnPaintPosEnd _onPaintPosEnd;
  OnPageInfo _onPageInfo;
  OnRecordState _onRecordState;

  @override
  void onReceive(msg) {
    try {
      print("onReceive -- msg == $msg");
      Map<String, dynamic> map = json.decode(msg);
      String channel = map['channel'];
      String content = map['comtent'];
      int channelCount = -1;
      try {
        channelCount = num.parse(channel).toInt();
      } catch (e2) {
        print('onReceive ------ e2 === $e2');
      }
      print("onReceive -- channel == $channel");
      print("onReceive -- content == $content");
      switch (channelCount) {
        case -1:
          print("-1 $channel");
          break;
        case 0:
          onPngImage(content);
          break;
        case 1:
          print('heart res == $content');
          break;
        case 10:
          onExit();
          break;
        case 11:
          onRecordState(int.parse(content) == 1);
          break;
        case 20:
          onWeekChange(int.parse(content));
          break;
        case 21:
          onStartCourse(content);
          break;
        case 22:
          onEndCourse(content);
          break;
        case 23:
          print('23-------------------------- $content');
          try {
            var arr = content.split(',');
            if (arr.length == 2) {
              onSetBlackBoardSize(
                  num.parse(arr[0]).toInt(), num.parse(arr[1]).toInt());
            }
          } catch (e) {
            print(e);
          }
          break;
        case 32:
          onOpenMedia(content);
          break;
        case 33:
          onOpenTestPaper(content);
          break;
        case 34:
          onOpenExample(content);
          break;
        case 35:
          onMediaControl(content);
          break;
        case 36:
          onSetBoardPaint(int.parse(content));
          break;
        case 37:
          print('37--------------------');
          List<Point> points = parsePoints(content);
          onPaintPosition(points);
          break;
        case 38:
          print('38--------------------');
          onPaintPosStart(parsePoints(content));
          break;
        case 39:
          print('39--------------------');
          onPaintPosEnd(parsePoints(content));
          break;
        case 40:
          onPageText(content);
          break;
        default:
          print("onReceive -- msg == $msg");
      }
    } catch (e1) {
      print("onReceive -- 1111111111111---- msg == $msg");
      print("onReceive exception ------ $e1");
    }
  }

  onRecordState(bool isStartRecord) {
    if (_onRecordState != null) {
      _onRecordState(isStartRecord);
    }
  }

  void onPageText(String pageText) {
    if (_onPageInfo != null) {
      _onPageInfo(pageText);
    }
  }

  List<Point> parsePoints(String content) {
    List<Point> points = [];
    try {
      if (content != null && content.isNotEmpty) {
        var arr = content.split(';');
        print('arr === $arr');
        for (String item in arr) {
          var itemArr = item.split(',');
          print('item === $itemArr');
          if (itemArr.length == 2) {
            String item0 = itemArr[0];
            String item1 = itemArr[1];
            var num0 = num.tryParse(item0);
            var num1 = num.tryParse(item1);
            double x = num0.toDouble();
            double y = num1.toDouble();
            points.add(new Point(x, y));
          }
        }
      }
    } catch (e) {
      print("parsePoints ------------------- $e");
    }
    return points;
  }

  void setCallBack(
      {OnExit onExit,
      OnPngImage onPngImage,
      OnWeekChange onWeekChange,
      OnStartCourse onStartCourse,
      OnEndCourse onEndCourse,
      OnSetBlackBoardSize onSetBlackBoardSize,
      OnOpenMedia onOpenMedia,
      OnOpenTestPaper onOpenTestPaper,
      OnOpenExample onOpenExample,
      OnMediaControl onMediaControl,
      OnSetBoardPaint onSetBoardPaint,
      OnPaintPosition onPaintPosition,
      OnPaintPosStart onPaintPosStart,
      OnPaintPosEnd onPaintPosEnd,
      OnPageInfo onPageInfo,
      OnRecordState onRecordState}) {
    if (onExit != null) {
      _onExit = onExit;
    }
    if (onPngImage != null) {
      _onPngImage = onPngImage;
    }
    if (onWeekChange != null) {
      _onWeekChange = onWeekChange;
    }
    if (onStartCourse != null) {
      _onStartCourse = onStartCourse;
    }
    if (onEndCourse != null) {
      _onEndCourse = onEndCourse;
    }
    if (onSetBlackBoardSize != null) {
      _onSetBlackBoardSize = onSetBlackBoardSize;
    }
    if (onOpenMedia != null) {
      _onOpenMedia = onOpenMedia;
    }
    if (onOpenTestPaper != null) {
      _onOpenTestPaper = onOpenTestPaper;
    }
    if (onOpenExample != null) {
      _onOpenExample = onOpenExample;
    }
    if (onMediaControl != null) {
      _onMediaControl = onMediaControl;
    }
    if (onSetBoardPaint != null) {
      _onSetBoardPaint = onSetBoardPaint;
    }
    if (onPaintPosition != null) {
      _onPaintPosition = onPaintPosition;
    }
    if (onPaintPosStart != null) {
      _onPaintPosStart = onPaintPosStart;
    }
    if (onPaintPosEnd != null) {
      _onPaintPosEnd = onPaintPosEnd;
    }
    if (onPageInfo != null) {
      _onPageInfo = onPageInfo;
    }
    if (onRecordState != null) {
      _onRecordState = onRecordState;
    }
  }

  void onExit() {
    SocketHelper.instance.close();
    if (_onExit != null) {
      _onExit();
    }
  }

  void onPngImage(var msg) {
    print("onPngImage --- $msg -- $_onPngImage");
    if (_onPngImage != null) {
      _onPngImage(msg);
    }
  }

  void onWeekChange(int week) {
    if (_onWeekChange != null) {
      _onWeekChange(week);
    }
  }

  void onStartCourse(String courseid) {
    print(courseid);
    if (_onStartCourse != null) {
      _onStartCourse(courseid);
    }
  }

  void onEndCourse(String courseid) {
    if (_onEndCourse != null) {
      _onEndCourse(courseid);
    }
  }

  void onSetBlackBoardSize(int w, int h) {
    if (_onSetBlackBoardSize != null) {
      print('23------- set-----------');
      _onSetBlackBoardSize(w, h);
    }
  }

  void onOpenMedia(String mediaPath) {
    if (_onOpenMedia != null) {
      _onOpenMedia(mediaPath);
    }
  }

  void onOpenTestPaper(String paperId) {
    if (_onOpenTestPaper != null) {
      _onOpenTestPaper(paperId);
    }
  }

  void onOpenExample(String exampleId) {
    if (_onOpenExample != null) {
      _onOpenExample(exampleId);
    }
  }

  void onMediaControl(String cmdStr) {
    if (_onMediaControl != null) {
      _onMediaControl(cmdStr);
    }
  }

  void onSetBoardPaint(int index) {
    if (_onSetBoardPaint != null) {
      _onSetBoardPaint(index);
    }
  }

  void onPaintPosition(List<Point> points) {
    if (_onPaintPosition != null) {
      _onPaintPosition(points);
    }
  }

  void onPaintPosStart(List<Point> points) {
    if (_onPaintPosStart != null) {
      _onPaintPosStart(points);
    }
  }

  void onPaintPosEnd(List<Point> points) {
    if (_onPaintPosEnd != null) {
      _onPaintPosEnd(points);
    }
  }
}

class JSONParserData {
  List<String> jsonList;
  String noJsonData;

  JSONParserData(this.jsonList, this.noJsonData);
}
