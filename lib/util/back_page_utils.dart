import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackPageUtils {
  static Widget getPageBackWidget(BuildContext context, {Color color}) {
    return new IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: color,
      ),
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          SystemNavigator.pop();
        }
      },
    );
  }
}
