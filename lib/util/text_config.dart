import 'package:flutter/material.dart';

class TextConfig {
  static const double TITLE_TEXT_SIZE = 16;
  static const double CONTENT_TEXT_NORMAL_SIZE = 14;
  static const double CONTENT_TEXT_BIG_SIZE = 20;
  static const double CONTENT_TEXT_SMALL_SIZE = 12;

  static TextStyle getTextStyle({double size = CONTENT_TEXT_NORMAL_SIZE, Color color = Colors.black}) {
    return TextStyle(
        color: color, fontSize: size, decoration: TextDecoration.none);
  }
}
