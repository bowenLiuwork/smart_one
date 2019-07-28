import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {

    Widget appLogo = new SizedBox(height: 75,child: Center(child:
     SizedBox(height: 65, width: 65,
     child: Image.asset('images/app_logo.png'),),),);

    Widget appName = SizedBox(height: 25, 
        child: Center(child: Text("智慧课堂", style: TextStyle(fontSize: 15, 
              color: Colors.black, decoration: TextDecoration.none,
               fontWeight: FontWeight.w300),),),);
    
    Widget appVersion = SizedBox(height: 25,
       child: Row(children: <Widget>[
         Expanded(child: Container(),),
         Padding(child: Text("当前版本号：1.0", style: TextStyle(fontSize: 12, 
              color: Colors.black38, decoration: TextDecoration.none,
               fontWeight: FontWeight.w300),),
               padding: EdgeInsets.only(right: 10),)
       ],),);
    ListView listView= new ListView(children: <Widget>[
        SizedBox(height: 65,),
        appLogo,
        SizedBox(height: 10,),
        appName,
        appVersion,
    ],);


    Widget aboutContent = Container(
      color: Color(0xfafafa),
      child: listView,
    );

    return new Scaffold(appBar: AppBar(
      title: Text("关于", style: TextStyle(color: Colors.black, fontSize: 15, decoration: TextDecoration.none),),
      centerTitle: true,
      leading: GestureDetector(onTap: () {
        Navigator.of(context).pop();
      }, child: Icon(Icons.arrow_back_ios, color: Colors.black,),),
      backgroundColor:Colors.white,
    ), body: aboutContent,);
  }
}