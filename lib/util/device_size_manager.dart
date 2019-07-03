
import 'package:flutter/material.dart';

class DeviceSizeManager {
  //单例 --------
  factory DeviceSizeManager() => _getInstance();

  static DeviceSizeManager get instance => _getInstance();

  static DeviceSizeManager _instance;

  DeviceSizeManager._internal() {
    // 初始化
  }

  static DeviceSizeManager _getInstance() {
    if (_instance == null) {
      _instance = new DeviceSizeManager._internal();
    }
    return _instance;
  }

  //-------------------

  num _screenWidth = 0;
  num _screenHeight = 0;
  num _statusBarHeight;
  num _bottomStatusBarHeight;

  void init(BuildContext context) {
    if(_screenWidth <= 0 || _screenHeight <= 0) {
      EdgeInsets padding = MediaQuery.of(context).padding;
      Size screenSize = MediaQuery.of(context).size;
      _screenWidth = screenSize.width;
      _screenHeight = screenSize.height;
      _statusBarHeight = padding.top;
      _bottomStatusBarHeight = padding.bottom;
      print("size init --- $_screenWidth, $_screenHeight, $_statusBarHeight, $_bottomStatusBarHeight");
    }
  }

  getScreenWidth() {
    return _screenWidth;
  }

  getScreenHeight() {
    return _screenHeight;
  }

  getStatusBarHeight() {
    return _statusBarHeight;
  }

  getBottomStatusBarHeight() {
    return _bottomStatusBarHeight;
  }

  getScreenMaxSize() {
    return _screenWidth > _screenHeight ? _screenWidth : _screenHeight;
  }

  getScreenMinSize() {
    return _screenWidth < _screenHeight ? _screenWidth : _screenHeight;
  }
}
