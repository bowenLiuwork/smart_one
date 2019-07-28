import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';
import 'package:smart_one/business/http_config.dart';
import 'package:smart_one/business/user_info_manager.dart';
import 'dart:convert';
import 'package:smart_one/page_constance.dart';

class MeContentPage extends StatefulWidget {
  @override
  _MeContentPageState createState() => _MeContentPageState();
}

class _MeContentPageState extends State<MeContentPage> {

  String _teacherName = '';
  String _teacherLogo;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    try{
      String res = await HttpConfig.getLoginUserInfo(UserInfoManager.instance.getToken());
      print('user info == $res');
      Map<String, dynamic> data = json.decode(res);
      Map<String, dynamic> teanerInfo = data['data'];
      String teacherName = teanerInfo['teacher_name'];
      setState(() {
        _teacherName = teacherName;
      });
    }catch (e) {
      print(e);
    }
  
  }

  @override
  Widget build(BuildContext context) {

    Row personInfoRow = new Row(children: <Widget>[
        SizedBox(width: 10, ),

        SizedBox(width: 58, height: 58,
        child: new ClipOval(
            child: _teacherLogo == null ? new Image.asset('images/app_logo.png') :
            Image.network(_teacherLogo),
        ),),
        SizedBox(width: 10,),
        Expanded(child: 
        Column
        (
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:CrossAxisAlignment.start,
          children: <Widget>[
              Text("教师：$_teacherName", style: TextStyle(fontSize: 15, 
              color: Colors.black, decoration: TextDecoration.none,
               fontWeight: FontWeight.w300),),

        ],),)
    ],);

    Widget aboutMe = new Container(
      height: 45,
      child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:CrossAxisAlignment.start,
      children: <Widget>[
      SizedBox(width: 10,),
      Center(child: Text("关于我们", style:TextStyle(fontSize: 15, 
              color: Colors.black, decoration: TextDecoration.none,
               fontWeight: FontWeight.w300),),),
      Expanded(child: Container(),),
      ],),
      color: Colors.white,
    );

    GestureDetector aboutMeClick = new GestureDetector(child: aboutMe, onTap: () {
      Navigator.of(context, rootNavigator: true).pushNamed(PageConstance.ABOUT_PAGE);
    },);

    ListView listView = new ListView(
      children: <Widget>[
        Container(height: 10, color: Colors.white,),
        Container(height: 58, child: personInfoRow, color: Colors.white,),
        Container(height: 10, color: Colors.white),
        SizedBox(height: 5, child: Container(color: Color(0xffeeeeee),),),
        SizedBox(height: 25,),
        aboutMeClick,
        
    ],);


    return Container(
      color: Colors.white24,
      child: listView,
    );
  }
}