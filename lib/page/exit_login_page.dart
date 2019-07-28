import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/business/socket_helper.dart';
import 'package:smart_one/business/tcp_control_helper.dart';
import 'package:smart_one/util/back_page_utils.dart';

class ExitLoginPage extends StatefulWidget {
  @override
  _ExitLoginPageState createState() => _ExitLoginPageState();
}

class _ExitLoginPageState extends State<ExitLoginPage> {

  TcpControlHelper tcpHelper;

  @override
  void initState() {
    super.initState();
    tcpHelper = new TcpControlHelper((json) {
      SocketHelper.instance.write(json);
    });
  }


  _exitLogin() {
    tcpHelper.exitLogin();
    Navigator.of(context).pop(true);
  }

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
          'Windows 智慧课堂已经登录',
          style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w300),
        ),
        Expanded(child: Container()),
        OutlineButton(
          onPressed: () {
            _exitLogin();
          },
          padding: EdgeInsets.symmetric(horizontal: 35),
          color: Colors.transparent,
          child: Text('退出Windows登录'),
          textColor: Colors.green,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green),
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        
        SizedBox(
          height: 75,
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
}