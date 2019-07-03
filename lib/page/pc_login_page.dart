import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_one/business/http_config.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/util/back_page_utils.dart';

class PCLogin extends StatefulWidget {
  String loginUrl;

  PCLogin({Key key, @required this.loginUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PCLoginState();
  }
}

class _PCLoginState extends State<PCLogin> {
  @override
  Widget build(BuildContext context) {
    Column column = new Column(
      children: <Widget>[
        SizedBox(
          height: 75,
        ),
        Image.asset('images/pc_logo.png'),
        SizedBox(
          height: 10,
        ),
        Text(
          'Windows 智慧课堂登录确认',
          style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w300),
        ),
        Expanded(child: Container()),
        OutlineButton(
          onPressed: () {
            _login();
          },
          padding: EdgeInsets.symmetric(horizontal: 65),
          color: Colors.transparent,
          child: Text('登录'),
          textColor: Colors.green,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green),
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        SizedBox(
          height: 15,
        ),
        FlatButton(
          onPressed: () {
            _cancelLogin();
          },
          textColor: Colors.black,
          color: Colors.transparent,
          child: Text('取消登录'),
        ),
        SizedBox(
          height: 45,
        )
      ],
    );

    Scaffold scaffold = new Scaffold(
      appBar: AppBar(
        leading: BackPageUtils.getPageBackWidget(context, color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: column,
    );

    return scaffold;
  }

  void _login() async {
    print('pc login url -- ${widget.loginUrl}');
    if (widget.loginUrl != null && widget.loginUrl.isNotEmpty) {
      String res = await HttpConfig.scanLogin(widget.loginUrl);
      print('pc login -- $res');
      var resJson = json.decode(res);
      if(resJson['code'] == 200) {
        Future.delayed(Duration(milliseconds: 300), () {
          SocketHelper.instance.startConnect();
        });
        _close();
      }else {
        String errMsg = resJson['message'];
        Fluttertoast.showToast(
            msg: errMsg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    }
  }

  void _close() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _cancelLogin() {
    _close();
  }
}
