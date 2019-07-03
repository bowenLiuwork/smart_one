import 'dart:async';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/business/course_media_helper.dart';
import 'package:smart_one/business/draw_data_helper.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/model/Point.dart';
import 'package:smart_one/model/teach_course.dart';
import 'package:smart_one/page/course_list_view.dart';
import 'package:smart_one/page/list_grid_page.dart';
import 'package:smart_one/util/device_size_manager.dart';
import 'package:smart_one/util/media_type_config.dart';
import 'package:smart_one/util/text_config.dart';
import 'package:smart_one/widget/course_botton_bar.dart';
import 'package:smart_one/widget/course_title_bar.dart';
import 'package:smart_one/widget/draw_color_selected_view.dart';
import 'package:smart_one/widget/draw_view.dart';
import 'package:smart_one/widget/image_control_view.dart';
import 'package:smart_one/widget/image_switch_view.dart';
import 'package:smart_one/widget/media_control_view.dart';
import 'package:smart_one/widget/pdf_ppt_control_view.dart';
import 'package:smart_one/widget/switch_list_bar.dart';

import '../page_constance.dart';

// ignore: must_be_immutable
class LearnPage extends StatefulWidget {
  String courseid;
  ICourse course;

  LearnPage({Key, key, @required String courseId, ICourse this.course})
      : super(key: key) {
    if (courseId != null && courseId.isNotEmpty) {
      courseid = courseId;
    } else if (course != null) {
      courseid = course.getId();
    }
  }

  @override
  State<StatefulWidget> createState() {
    return LearnPageState();
  }
}

class LearnPageState extends State<LearnPage>
    with WidgetsBindingObserver
    implements ITCPDrawDataListener, OnControlListener {
  static final int TYPE_VIDEO_AUDIO = 1001;
  static final int TYPE_PDF_PPT = 1002;
  static final int TYPE_IMAGE = 1003;

  GlobalKey drawkey = new GlobalKey();

  int drawViewTop = 78;

  TcpControlHelper tcpControlHelper;
  List<ICourseMediaNode> courseMediaList = [];
  double width = 0;
  double height = 0;

  num drawViewX = 0;
  num drawViewY = 0;

  int socketWidth;
  int socketHeight;

  double widthRatio = 0;
  double heightRatio = 0;

  String courseTitle = "title";

  List<ICourseMediaNode> _showMediaList = [];

  CourseMediaHelper mediaHelper;

  int _curMediaType = TYPE_IMAGE;

  Uint8List _image;

  bool _isShowBlackBoard = false;

  List<Dot> _paintDotList = [];
  Path _curPath;
  Color _paintColor = SelectedPaintColorWidget.colors[0];

  List<bool> _pptBtnStateList;
  String _pptPageText = '1/12';

  List<bool> _imageBtnStateList;

  int _recordMillTime = 0;
  int gesterDirection = 0;

  @override
  void initState() {
    width = DeviceSizeManager.instance.getScreenMinSize();
    height = width * 9 / 16;
    DrawDataManager.instance.addITCPDrawDataListener(this);
    SocketHelper.instance.setMessageCallBack(
      onEndCourse: _onEndCourse,
      onOpenTestPaper: _onTCPOpenTestPaper,
      onRecordState: _onRecordState,
    );
    tcpControlHelper = new TcpControlHelper((value) {
      SocketHelper.instance.write(value);
    });
    mediaHelper = new CourseMediaHelper();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    courseTitle =
        widget.course != null ? widget.course.getCourseTitle() : "title";
    _initMediaList();
    _initPPtBarState();
    _initImageBarState();
  }

  _initPPtBarState() {
    _pptBtnStateList = [];
    for (int i = 0; i < PdfPptControl.allBarCount; i++) {
      _pptBtnStateList.add(true);
    }
  }

  _initImageBarState() {
    _imageBtnStateList = [];
    for (int i = 0; i < ImageControlView.ALLBTNSIZE; i++) {
      _imageBtnStateList.add(true);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    print('deactivate --------------------- ');
  }

  @override
  void didUpdateWidget(LearnPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget -------------------------------------- ');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print('111111111111111111111');
    tcpControlHelper.controlEndClass(widget.courseid);
    DrawDataManager.instance.removeITCPDrawDataListener(this);
    DrawDataManager.instance.resetState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState ==== $state');
  }

  _onDrawViewSizeChange(Size size) {
    drawViewX = size.width;
    drawViewY = size.height;
  }

  Widget getCourseContent(String courseTitle) {
    DrawView drawView = new DrawView(
      key: drawkey,
      size: Size(width, height),
      sizeChange: _onDrawViewSizeChange,
      list: _paintDotList,
      paintColor: _paintColor,
      canTouch: false,
      marginTop: drawViewTop,
      child: new Container(),
    );

    Stack contentView = Stack(
      children: <Widget>[
        SizedBox(
          width: width,
          height: height,
          child: _image == null
              ? Container(
                  color: Colors.black,
                )
              : Stack(
                  children: <Widget>[
                    Container(
                      child: ImageSwitchView(
                        image: _image,
                        direction: gesterDirection,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.memory(_image),
                    ),
                  ],
                ),
        ),
        drawView,
        Offstage(
          offstage: !_isShowBlackBoard,
          child: Container(
            child: getPlayBar(),
            width: width,
            height: height,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ],
    );
    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        setState(() {
          _isShowBlackBoard = !_isShowBlackBoard;
        });
      },
      onHorizontalDragEnd: (drag) {
        print(
            "onHorizontalDragEnd ---drag === ${drag.velocity.pixelsPerSecond}");
        if (drag.velocity.pixelsPerSecond.dx > 0) {
          tcpControlHelper.getMediaControl().previous();
          gesterDirection = -1;
        } else if (drag.velocity.pixelsPerSecond.dx < 0) {
          tcpControlHelper.getMediaControl().next();
          gesterDirection = 1;
        } else {
          gesterDirection = 0;
        }
      },
      child: contentView,
    );
    Column column = new Column(children: <Widget>[
      Container(
        height: 45,
        padding: EdgeInsets.all(10),
        child: Text(
          courseTitle,
          textAlign: TextAlign.left,
          style: TextConfig.getTextStyle(color: Colors.black),
        ),
      ),
      gestureDetector,
    ]);

    return gestureDetector;
  }

  void _initMediaList() {
    _getCouserMediaLis();
  }

  void _onEndCourse(String id) {
    if (DrawDataManager.instance.isExitFullWidget()) {
      Navigator.of(context).pop();
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.of(context).pop();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  _onTCPOpenTestPaper(String paperId) {
    _getTestPagerExerciseList(paperId);
    setState(() {
      _courseSwitchIndex = 1;
    });
  }

  Timer timer;

  _onRecordState(bool isStartRecord) {
    if (isStartRecord) {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
      timer = new Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordMillTime += 1000;
        });
      });
      setState(() {
        _recordMillTime = 0;
      });
    } else {
      timer?.cancel();
      timer = null;
      setState(() {
        _recordMillTime = 0;
      });
    }
  }

  _getCouserMediaLis() async {
    List<ICourseMediaNode> list =
        await mediaHelper.getMediaList(widget.courseid);
    setState(() {
      _showMediaList = list;
    });
  }

  _getCouserTestPaperList() async {
    List<ICourseMediaNode> list =
        await mediaHelper.getTestMediaList(widget.courseid);
    setState(() {
      _showMediaList = list;
    });
  }

  _getTestPagerExerciseList(String id) async {
    List<ICourseMediaNode> list =
        await mediaHelper.getTestPaperExerciseList(id);
    list.insert(0, ExerciseMedia.createSwitchMedia());
    setState(() {
      _showMediaList = list;
    });
  }

  _onCourseMediaClick(ICourseMediaNode media) {
    if (media.getWidgetType() == CourseMediaWidgetType.Widget_Content) {
      if (media.getNodePath() != null) {
        tcpControlHelper.openMediaNode(
            media.getNodeChannel(), media.getNodePath());
        int type = getMediaFileType(media);
        setState(() {
          gesterDirection = 0;
          _curMediaType = type;
        });
      }
      if (media is TestPaperCourseMedia) {
        _getTestPagerExerciseList(media.id);
      }
    } else if (media.getWidgetType() == CourseMediaWidgetType.Widget_Switch) {
      if (media is ExerciseMedia) {
        _getCouserTestPaperList();
      }
      if (media.getParentNode() != null) {
        tcpControlHelper.openMediaNode(media.getParentNode().getNodeChannel(),
            media.getParentNode().getNodePath());
        int type = getMediaFileType(media.getParentNode());
        setState(() {
          _curMediaType = type;
        });
      }
    }
  }

  _setSwitchBarContentBybarIndex(int i) {
    if (i == 0) {
      _getCouserMediaLis();
    } else if (i == 1) {
      _getCouserTestPaperList();
    }
  }

  int _courseSwitchIndex = 0;

  _getCourseMediaContentBar() {
    return SwitchListBar(
      barTitleList: ['多媒体库', '习题试卷'],
      selectedIndex: _courseSwitchIndex,
      itemClick: (i) {
        _courseSwitchIndex = i;
        _setSwitchBarContentBybarIndex(i);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CourseTitleBar appBar = new CourseTitleBar(
      allMills: _recordMillTime,
      onDrawPathClick: () {
        _fullClick();
      },
      recordControlClick: (isStartRecord) {
        if (isStartRecord) {
          tcpControlHelper.startRecord();
        } else {
          tcpControlHelper.stopRecord();
        }
      },
    );

    Container titleView = Container(
      height: 45,
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      color: Colors.white,
      child: Text(
        courseTitle,
        style: TextConfig.getTextStyle(color: Colors.black),
      ),
    );

    drawViewTop = (appBar.preferredSize.height + 45).floor();

    Scaffold scaffold = new Scaffold(
      appBar: appBar,
      body: Column(
        children: <Widget>[
          titleView,
          getCourseContent(courseTitle),
          _getCourseMediaContentBar(),
          Expanded(
            child: ListGridView(
              itemClick: (index) {
                _onCourseMediaClick(_showMediaList[index]);
              },
              data: _showMediaList,
            ),
          ),
          Container(
            height: 55,
            alignment: Alignment.center,
            child: getBottomBar(),
          ),
        ],
      ),
    );

    return scaffold;
  }

  void _play() {
    print("play-----");
    tcpControlHelper.getMediaControl().play();
  }

  void _previous() {
    print('_previous----');
    tcpControlHelper.getMediaControl().previous();
  }

  void _next() {
    print('_next----');
    tcpControlHelper.getMediaControl().next();
  }

  void _fullClick() async {
    print('_fullClick -----------');
    var isUpdateDraw =
        await Navigator.of(context).pushNamed(PageConstance.FULL_DRAW_PAGE);
    print('_fullClick --- back $isUpdateDraw');
    if (isUpdateDraw is bool && isUpdateDraw) {
      setState(() {
        _paintDotList = DrawDataManager.instance
            .paintPathToViewData(drawViewX, drawViewY, offsetTop: drawViewTop);
        _paintColor = DrawDataManager.instance
            .toOurColor(DrawDataManager.instance.paintCmdIndex);
      });
    }
  }

  Widget getPlayBar() {
    Widget controlView;
    if (_curMediaType == TYPE_VIDEO_AUDIO) {
      controlView = MediaControlView(
        controlListener: this,
        downEnable: true,
        isPlaying: true,
        upEnable: true,
      );
    } else if (_curMediaType == TYPE_IMAGE) {
      controlView = ImageControlView(
        enableList: _imageBtnStateList,
        itemClick: (value) {
          if (value == 0) {
            tcpControlHelper.getMediaControl().left();
          } else if (value == 1) {
            tcpControlHelper.getMediaControl().right();
          } else if (value == 2) {
            tcpControlHelper.getMediaControl().fitScreenSize();
          } else if (value == 3) {
            tcpControlHelper.getMediaControl().fitImageSize();
          } else if (value == 4) {
            tcpControlHelper.getMediaControl().zoomin();
          } else if (value == 5) {
            tcpControlHelper.getMediaControl().zoomout();
          }
        },
      );
    } else if (_curMediaType == TYPE_PDF_PPT) {
      controlView = PdfPptControl(
        barItemClick: (index) {
          if (index == 0) {
            tcpControlHelper.getMediaControl().first();
          } else if (index == 1) {
            tcpControlHelper.getMediaControl().previous();
          } else if (index == 2) {
            tcpControlHelper.getMediaControl().next();
          } else if (index == 3) {
            tcpControlHelper.getMediaControl().last();
          } else if (index == 4) {
            tcpControlHelper.getMediaControl().fitHeight();
          } else if (index == 5) {
            tcpControlHelper.getMediaControl().fitWidth();
          } else if (index == 6) {
            tcpControlHelper.getMediaControl().zoomin();
          } else if (index == 7) {
            tcpControlHelper.getMediaControl().zoomout();
          }
        },
        enableControlList: _pptBtnStateList,
        pageText: _pptPageText,
      );
    } else {
      controlView = new Container();
    }

    Container container =
        new Container(color: Color(0x60000000), height: 50, child: controlView);

    return container;
  }

  Widget getControlBar() {
    return SizedBox(
      height: 50,
      child: Container(
        color: Color(0xff1b1d24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 25,
            ),
            IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                ),
                onPressed: _previous),
            SizedBox(
              width: 25,
            ),
            IconButton(
                icon: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: _play),
            SizedBox(
              width: 25,
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: Colors.white,
              ),
              onPressed: _next,
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 25),
              child: IconButton(
                icon: Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _fullClick,
              ),
            )),
          ],
        ),
      ),
    );
  }

  int getFileType(String mediaType) {
    int type = TYPE_IMAGE;
    if (MediaTypeConfig.TYPE_VIDEO.contains(mediaType)) {
      type = TYPE_VIDEO_AUDIO;
    } else if (MediaTypeConfig.TYPE_IMAGE.contains(mediaType)) {
      type = TYPE_IMAGE;
    } else if (MediaTypeConfig.TYPE_PPT_PDF.contains(mediaType)) {
      type = TYPE_PDF_PPT;
    }
    return type;
  }

  int getMediaFileType(ICourseMediaNode media) {
    return getFileType(media.getMediaType());
  }

  _qianDaoClick() {
    tcpControlHelper.courseQianDao();
  }

  _dianmingoClick() {
    tcpControlHelper.courseDianMing();
  }

  _qiangDaClick() {
    tcpControlHelper.courseJuShouQiangDa();
  }

  _startDianMing() {
    tcpControlHelper.startDianMing();
  }

  _stopDianMing() {
    tcpControlHelper.stopDianMing();
  }

  _startQiangDa() {
    tcpControlHelper.startQiangDa();
  }

  _stopQiangDa() {
    tcpControlHelper.stopQiangDa();
  }

  Widget getBottomBar() {
    Widget w = new CourseBottomBar(
      qianDaoClick: _qianDaoClick,
      dianMingClick: _dianmingoClick,
      qiangDaClick: _qiangDaClick,
      startDianMingClick: _startDianMing,
      stopDianMingClick: _stopDianMing,
      startQiangDaClick: _startQiangDa,
      stopQiangDaClick: _stopQiangDa,
    );
    return w;
  }

  @override
  void onDrawImage(Uint8List image) {
    print('onDrawImage ----- ');
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        clearPath();
        _image = image;
      });
    });
  }

  @override
  void onDrawPaintEnd(List<Point> points) {
    for (Point p in points) {
      print("point onDrawPaintEnd == ${p.toString()}");
      Point p1 = DrawDataManager.instance
          .toOurPoint(p, drawViewX, drawViewY, offsetTop: drawViewTop);
      _curPath?.lineTo(p1.x, p1.y);
    }
    setState(() {
      _paintDotList = _paintDotList;
    });
  }

  @override
  void onDrawPaintLooping(List<Point> points) {
    for (Point p in points) {
      print("point onDrawPaintLooping == ${p.toString()}");
      Point p1 = DrawDataManager.instance
          .toOurPoint(p, drawViewX, drawViewY, offsetTop: drawViewTop);
      _curPath?.lineTo(p1.x, p1.y);
    }

    setState(() {
      _paintDotList = _paintDotList;
    });
  }

  @override
  void onDrawPaintSet(int cmdIndex) {
    print('_onsetBoardPatin == $cmdIndex');
    int index = cmdIndex - 1;
    if (index >= 0 && index < SelectedPaintColorWidget.colors.length) {
      setState(() {
        _paintColor = SelectedPaintColorWidget.colors[index];
      });
    } else if (index == 8) {
      // 9 = 8 + 1 //清除画布
      setState(() {
        clearPath();
      });
    }
  }

  void clearPath() {
    _paintDotList.clear();
    DrawDataManager.instance.clearPaintPath();
  }

  @override
  void onDrawPaintStart(List<Point> points) {
    for (Point p in points) {
      print("point onDrawPaintStart == ${p.toString()}");
      Point p1 = DrawDataManager.instance
          .toOurPoint(p, drawViewX, drawViewY, offsetTop: drawViewTop);
      _curPath = new Path();
      _curPath.moveTo(p1.x, p1.y);
    }
    print('_paintColor === $_paintColor, $_curPath');
    Dot dot = new Dot(color: _paintColor, path: _curPath);
    setState(() {
      _paintDotList.add(dot);
    });
  }

  @override
  void onMediaControl(String cmdStr) {
    print('onMediaControl ----- $cmdStr');
    setState(() {
      clearPath();
    });
  }

  @override
  void onDown() {
    tcpControlHelper.getMediaControl().next();
  }

  @override
  void onPlay() {
    tcpControlHelper.getMediaControl().play();
  }

  @override
  void onSeek(double value) {
    // TODO: implement onSeek
  }

  @override
  void onUp() {
    tcpControlHelper.getMediaControl().previous();
  }

  @override
  void onPageInfoGet(String pageInfo) {
    print('onPageInfoGet ------ $pageInfo');
    setState(() {
      _pptPageText = pageInfo;
    });
  }

  @override
  void onOpenMedia(String mediaInfo) {
    setState(() {
      _courseSwitchIndex = 0;
      _setSwitchBarContentBybarIndex(0);
    });

    RegExp regExp = new RegExp(r'''[\w\d]*\/[\w\d]*\.([\w\d]*)''');
    String mediaType = null;
    if (mediaInfo != null) {
      List<Match> mList = regExp.allMatches(mediaInfo).toList();
      if (mList != null && mList.length > 0) {
        Match m = mList[0];
        if (m.groupCount > 0) {
          mediaType = m.group(1);
        }
      }
    }
    print('mediaType ==== $mediaType');
    if (mediaType != null) {
      int type = getFileType(mediaType);
      setState(() {
        _curMediaType = type;
      });
    }
  }

  @override
  void changeSound(changeInfo) {}

  @override
  void onPause() {
    tcpControlHelper.getMediaControl().pause();
  }
}
