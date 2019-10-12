import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_one/business/http_config.dart';
import 'package:smart_one/business/login_data_helper.dart';
import 'package:smart_one/util/back_page_utils.dart';
import 'package:smart_one/util/text_config.dart';

import 'login_page.dart';

class SelectSchoolPage extends StatefulWidget {
  @override
  _SelectSchoolPageState createState() => _SelectSchoolPageState();
}

class _SelectSchoolPageState extends State<SelectSchoolPage> {
  List<SchoolItem> _list = [];
  String selectedSchoolNum = '';
  String userLoginName = "";
  String userLoginPwd = "";

  @override
  void initState() {
    super.initState();
    _initLoginData();
    initData();
  }

  _initLoginData() async {
    var name = await LoginDataHelper.getLoginUserName();
    var pwd = await LoginDataHelper.getLoginPWD();
    if (name != null) {
      userLoginName = name;
    }
    if (pwd != null) {
      print('pwd ---- $pwd');
      userLoginPwd = pwd;
    }
  }

  initData() {
    getSchoolList();
  }

  void _setServerClick() async {
    TextEditingController _textEditingController = TextEditingController();
    _textEditingController.text = await HttpConfig.getSchcemeUrl();

    int length = _textEditingController.text.length;
    _textEditingController.selection =
        TextSelection(baseOffset: 0, extentOffset: length);

    //监听输入改变
    _textEditingController.addListener(() {
      print('Controller监听：${_textEditingController.text}');
    });

    TextField inputField = TextField(
      controller: _textEditingController,
      keyboardType: TextInputType.text,
      maxLines: 2,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
      onChanged: (text) {
        print(text);
      },
      onEditingComplete: () {
        print('完成后：${_textEditingController.text}');
      },
      enabled: true,
      decoration: InputDecoration(
          hintText: "请输入服务器地址", contentPadding: EdgeInsets.all(10)),
    );

    showDialog(
        context: context,
        builder: (context) {
          Container container = Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                inputField,
                SizedBox(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Text(
                              "取消",
                              style: TextStyle(color: Colors.red),
                            )),
                      ),
                      SizedBox(
                        width: 1,
                        child: Container(
                          color: Colors.teal,
                        ),
                      ),
                      Expanded(
                          child: FlatButton(
                              onPressed: () {
                                String schemeUrl = _textEditingController.text;
                                print("save click $schemeUrl");
                                HttpConfig.setAndSaveSchemeUrl(schemeUrl);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                initData();
                              },
                              child: Text(
                                "确定",
                                style: TextStyle(color: Colors.black),
                              ))),
                    ],
                  ),
                ),
              ],
            ),
          );

          var w = Material(
            type: MaterialType.transparency,
            child: Center(
              child: SizedBox(
                height: 120,
                child: Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: container,
                ),
              ),
            ),
          );
          return w;
        });
  }

  getSchoolList() async {
    print("getSchoolList --------- ");
    selectedSchoolNum = "";
    String res = await HttpConfig.getSchoolList();
    print("school list == $res");
    Map<String, dynamic> resmap = json.decode(res);
    var dataList = resmap['data'];
    if (dataList != null) {
      List<SchoolItem> temp = [];
      for (var item in dataList) {
        temp.add(SchoolItem.createFromJson(item));
      }
      setState(() {
        _list = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(appBar: buildAppBar(context), body: buildBody(context));
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      leading: BackPageUtils.getPageBackWidget(context, color: Colors.black),
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: Text(
        "选择学校",
        style: TextConfig.getTextStyle(),
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            saveClick(context);
          },
          child: SizedBox(
            width: 55,
            child: Center(
              child: Text(
                "保存",
                style: TextConfig.getTextStyle(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void saveClick(BuildContext context) {
    if (selectedSchoolNum == null || selectedSchoolNum.isEmpty) {
      Fluttertoast.showToast(
          msg: "请选择学校",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      HttpConfig.setAndSaveSchoolNum(selectedSchoolNum);
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) {
        return new LoginPage(
          name: userLoginName,
          pwd: userLoginPwd,
        );
      }), (Route<dynamic> route) => false);
    }
  }

  Widget editConfigServerUrl() {
    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        _setServerClick();
      },
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.only(top: 15, bottom: 15),
        child: Text(
          "服务器地址设置",
          style: TextConfig.getTextStyle(size: 18),
        ),
      ),
    );
    return gestureDetector;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    SchoolItem item = _list[index];
    Container container = Container(
      height: 50.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              item == null ? '' : item.schoolName,
              textAlign: TextAlign.left,
              style: TextConfig.getTextStyle(size: 18),
            ),
          ),
          SizedBox(
              width: 55,
              height: 50,
              child: (item == null ? false : item.isSelected)
                  ? Icon(
                      Icons.done,
                      color: Colors.red,
                    )
                  : Container(
                      width: 55,
                      height: 50,
                    )),
        ],
      ),
    );
    Column column = new Column(
      children: <Widget>[
        container,
        SizedBox(
          height: 1,
          child: Container(
            color: Colors.grey,
          ),
        ),
      ],
    );
    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        _listViewItemClick(index);
      },
      child: column,
    );
    return gestureDetector;
  }

  void _listViewItemClick(int index) {
    print("listview ${index} item click");
    if (_list != null) {
      for (int i = 0; i < _list.length; i++) {
        if (i == index) {
          _list[i].isSelected = true;
          selectedSchoolNum = _list[i].schoolNum;
        } else {
          _list[i].isSelected = false;
        }
      }
      setState(() {
        _list = _list;
      });
    }
  }

  buildSchoolListView() {
    return ListView.builder(
        padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 5.0),
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return _itemBuilder(context, index);
        });
  }

  Widget buildBody(BuildContext context) {
    Column column = Column(
      children: <Widget>[
        editConfigServerUrl(),
        Expanded(child: buildSchoolListView()),
      ],
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.0),
      child: column,
    );
  }
}

class SchoolItem {
  String schoolName = '';
  String schoolNum = '';
  bool isSelected = false;

  SchoolItem() {}

  static SchoolItem createFromJson(Map<String, dynamic> json) {
    print("school item == $json");
    SchoolItem item = new SchoolItem();
    item.schoolName = json['school_name'];
    item.schoolNum = json['serial_number'];
    item.isSelected = false;
    return item;
  }
}
