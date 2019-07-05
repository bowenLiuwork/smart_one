import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_one/business/draw_data_helper.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/page/my_course_page.dart';
import 'package:smart_one/page/note_book_list_page.dart';
import 'package:smart_one/page/timetable_page.txt.dart';
import 'package:smart_one/util/device_size_manager.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  List<BottomNavigationBarItem> tabBars;
  Map<int, CupertinoTabView> contentPages = new Map();
  List<IndexedWidgetBuilder> indexedWidgetBuilderList;
  int curPageIndex = 0;

  @override
  void initState() {
    _initBottomBar();
    _initContentPages();
    super.initState();
    DrawDataManager.instance;
    _initTcpAddress();
    WidgetsBinding.instance.addObserver(this);
//    SocketHelper.instance.startHeartCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("smart one AppLifecycleState == $state ");
    if (state == AppLifecycleState.resumed) {
      SocketHelper.instance.startConnect();
    }
  }

  @override
  void dispose() {
    super.dispose();
//    SocketHelper.instance.stopHeartCheck();
    SocketHelper.instance.close();
  }

  void _initTcpAddress() {
    SocketHelper socketHelper = new SocketHelper();
    socketHelper.startConnect();
    socketHelper.setOnSocketStateListener(new SocketState(context));
  }

  void _initContentPages() {
    indexedWidgetBuilderList = new List();

    indexedWidgetBuilderList.add((context, index) {
      return MyCoursePage();
//      return CourseListPage(list:CourseListHelper.getTestCourseList());
    });

    indexedWidgetBuilderList.add((context, index) {
      return TimeTablePage();
    });
    indexedWidgetBuilderList.add((context, index) {
      return new NoteBookList();
    });
    indexedWidgetBuilderList.add((context, index) {
      return new Container(
        color: Colors.red,
      );
    });
  }

  void _initBottomBar() {
    tabBars = new List();
    BottomNavigationBarItem myCourse = new BottomNavigationBarItem(
      icon: ImageIcon(AssetImage("images/curriculum_unselected.png")),
      activeIcon: ImageIcon(AssetImage("images/curriculum_selected.png")),
      title: Text(
        "我的课程",
      ),
    );
    BottomNavigationBarItem meBar = new BottomNavigationBarItem(
      icon: ImageIcon(AssetImage("images/mine_unselected.png")),
      activeIcon: ImageIcon(AssetImage("images/mine_selected.png")),
      title: Text(
        "我的",
      ),
    );

    BottomNavigationBarItem courseTable = new BottomNavigationBarItem(
      icon: ImageIcon(AssetImage("images/tab_table_unselected.png")),
      activeIcon: ImageIcon(AssetImage("images/tab_table_selected.png")),
      title: Text(
        "课程表",
      ),
    );

    BottomNavigationBarItem noteBook = new BottomNavigationBarItem(
      icon: ImageIcon(AssetImage("images/tab_note_book_unselected.png")),
      activeIcon: ImageIcon(AssetImage("images/tab_note_book_selected.png")),
      title: Text(
        "记事本",
      ),
    );

    tabBars.add(myCourse);
    tabBars.add(courseTable);
    tabBars.add(noteBook);
    tabBars.add(meBar);
  }

  Color _getSelectedColor() {
    return Color(0xff359aec);
  }

  Color _getUnSelectedColor() {
    return Color(0xff8a8a8a);
  }

  @override
  Widget build(BuildContext context) {
    DeviceSizeManager.instance.init(context);
    CupertinoTabBar tabBar = new CupertinoTabBar(
      items: tabBars,
      activeColor: _getSelectedColor(),
      inactiveColor: _getUnSelectedColor(),
      currentIndex: 0,
      onTap: (int index) {
        print('index ==== $index');
        setState(() {
          curPageIndex = index;
        });
      },
    );
    return new CupertinoTabScaffold(
      tabBar: tabBar,
      tabBuilder: (BuildContext context, int index) {
        return createTabContentWidget(context, index);
      },
    );
  }

  Widget createTabContentWidget(BuildContext context, int index) {
    if (contentPages.containsKey(index)) {
      return contentPages[index];
    } else {
      IndexedWidgetBuilder widgetBuilder =
          index >= 0 && index < indexedWidgetBuilderList.length
              ? indexedWidgetBuilderList[index]
              : buildIndexPage;
      Widget newPage = buildTabContentPage(context, index, widgetBuilder);
      contentPages[index] = newPage;
      return newPage;
    }
  }

  Widget buildTabContentPage(
      BuildContext context, int index, IndexedWidgetBuilder indexWidgetBuild) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          child: Padding(
            padding: EdgeInsets.only(top: 25.0, bottom: 50.0),
            child: indexWidgetBuild(context, index),
          ),
        );
      },
    );
  }

  Widget buildIndexPage(BuildContext context, int index) {
    return new Container(
      color: Colors.yellow,
    );
  }
}

class SocketState implements OnSocketStateListener {
  BuildContext context;

  SocketState(this.context) {}

  @override
  void onSocketConnected() {
    Fluttertoast.showToast(
        msg: "连接成功",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0);
//    showDialog(
//        context: context,
//        builder: (_) {
//          return Container(
//            width: 150,
//            height: 150,
//            child: Text("连接成功"),
//          );
//        });
  }

  @override
  void onSocketDisconnected() {
    Fluttertoast.showToast(
        msg: "连接断开",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0);
//    showDialog(
//        context: context,
//        builder: (_) {
//          return Container(
//            width: 150,
//            height: 150,
//            child: Text("连接断开"),
//          );
//        });
  }

  @override
  void onSocketError(e) {
    Fluttertoast.showToast(
        msg: "连接错误",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0);
//    showDialog(
//        context: context,
//        builder: (_) {
//          return Container(
//            width: 150,
//            height: 150,
//            child: Text("连接错误"),
//          );
//        });
  }

  @override
  void onSocketStart(String host, int port) {
    Fluttertoast.showToast(
        msg: "连接${host}:$port",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0);
//    showDialog(
//        context: context,
//        builder: (_) {
//          return Container(
//            width: 150,
//            height: 150,
//            child: Text("地址 ${host}:$port"),
//          );
//        });
  }
}
