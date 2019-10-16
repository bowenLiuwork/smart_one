import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_one/business/http_config.dart';
import 'package:smart_one/business/login_data_helper.dart';
import 'package:smart_one/business/user_info_manager.dart';
import 'package:smart_one/model/classes_info.dart';
import 'package:smart_one/model/teacher_info.dart';
import 'package:smart_one/page_constance.dart';
import 'package:smart_one/util/back_page_utils.dart';
import 'package:smart_one/util/text_config.dart';
import 'package:smart_one/widget/net_loading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  String name;
  String pwd;

  LoginPage({Key key, this.name = "", this.pwd = ""}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _LoginState();
  }
}

class _LoginState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _userAccount = "";
  String _password = "";
  bool _isObscure = true;
  Color _eyeColor;

  @override
  void initState() {
    initCacheUser();
    super.initState();
  }

  void initCacheUser() {}

  void _goLogin() {
    print("go login-------");
    var _form = _formKey.currentState;
    _form.save();

    if (_userAccount == null || _userAccount.isEmpty) {
      Fluttertoast.showToast(
          msg: "请输入用户名",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: 16.0);
      return;
    }

    if (_password == null || _password.isEmpty) {
      Fluttertoast.showToast(
          msg: "请输入密码",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: 16.0);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new NetLoadingDialog(
            requestCallBack: _login(),
            outsideDismiss: true,
            dismissCallback: () {
              print('11111111111111111111');
              String token = UserInfoManager.instance.getToken();
              if (token != null && token.isNotEmpty) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    PageConstance.MAIN_PAGE, (Route<dynamic> route) => false);
              }
            },
          );
        });
  }

  Future<String> _login() async {
    await LoginDataHelper.saveLoginPwd(_password);
    await LoginDataHelper.saveLoginUserName(_userAccount);
    String res = await HttpConfig.login(_userAccount, _password);
    print(res);
    if (res != null) {
      Map<String, dynamic> data = json.decode(res);
      String token = data['token'];
      UserInfoManager.instance.setToken(token);
      try {
        String teacherInfo = await HttpConfig.getLoginUserInfo(token);
        Map<String, dynamic> teacherJson = json.decode(teacherInfo)['data'];
        TeacherInfo info = TeacherInfo.createFromJson(teacherJson);
        UserInfoManager.instance.teacherInfo = info;
        if (UserInfoManager.instance.isHighSchoolVersion) {
          String tClassInfoRes =
              await HttpConfig.getTeacherClasses(token, info.teacherNum);
          print("tClassInfoRes = $tClassInfoRes");
          List temp = json.decode(tClassInfoRes)['data'];
          List<ClassesInfo> classesList = [];
          for (var item in temp) {
            classesList.add(ClassesInfo.createFromJson(item));
          }
          UserInfoManager.instance.teacherClassesInfoList = classesList;
        }
      } catch (e) {
        print(e);
      }
    }
    return res;
  }

  void _goRegister() {
    //TODO 注册
    print("go register-------");
  }

  void _goFindPassword() {
    //TODO 忘记密码
    print("go find password-------");
  }

  @override
  Widget build(BuildContext context) {
    print('build----------------------');
    return new Scaffold(appBar: buildAppBar(context), body: buildBody(context));
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      leading: BackPageUtils.getPageBackWidget(context, color: Colors.black),
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: Text(
        "登录",
        style: TextConfig.getTextStyle(),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget getCloseButton() {
    return IconButton(
        icon: Icon(
          Icons.close,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.of(context).dispose();
        });
  }

  Widget buildBody(BuildContext context) {
    Column column = Column(
      children: <Widget>[
        SizedBox(
          height: 40,
        ),
        buildTitleImage(),
        SizedBox(
          height: 20,
        ),
        buildUserAccountTextField(),
        SizedBox(
          height: 20,
        ),
        buildPasswordTextField(context),
        SizedBox(
          height: 40,
        ),
        buildLoginButton(),
        SizedBox(
          height: 10,
        ),
        buildBelowLogin(),
        Expanded(
          child: Container(),
        ),
        Container(
          height: 30,
          child: Row(
            children: <Widget>[
              FlatButton(
                  onPressed: () {
                    _setServerClick();
                  },
                  child: Text(
                    "服务器设置",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.black38,
                        decoration: TextDecoration.none),
                  )),
              Expanded(
                child: Container(),
              )
            ],
          ),
        )
      ],
    );
    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.0),
          child: column,
        ));
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

  Widget buildLoginButton() {
    SizedBox box = new SizedBox(
      height: 45,
      width: double.maxFinite,
      child: CupertinoButton(
          child: Text(
            "登录",
            style: TextStyle(
                color: Colors.white,
                fontSize: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
                decoration: TextDecoration.none),
          ),
          color: Colors.blueAccent,
          onPressed: () {
            _goLogin();
          }),
    );
    return box;
  }

  Widget buildBelowLogin() {
    return SizedBox(
      height: 25,
      child: Row(
        children: <Widget>[
          IconButton(
              iconSize: 75,
              padding: EdgeInsets.symmetric(horizontal: 10),
              icon: Text(
                "快速注册",
                style: TextStyle(
                  fontSize: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
                  color: Color(0xff484848),
                ),
                softWrap: false,
              ),
              onPressed: () {
                _goRegister();
              }),
          Expanded(flex: 2, child: Container()),
          IconButton(
              iconSize: 80,
              padding: EdgeInsets.symmetric(horizontal: 10),
              icon: Text(
                "忘记密码?",
                softWrap: false,
                style: TextStyle(
                  fontSize: TextConfig.CONTENT_TEXT_NORMAL_SIZE,
                  color: Color(0xff484848),
                ),
              ),
              onPressed: () {
                _goFindPassword();
              })
        ],
      ),
    );
  }

  TextFormField buildPasswordTextField(BuildContext context) {
    print('init value ---- ${widget.pwd}');
    return TextFormField(
      onSaved: (String value) => _password = value,
      initialValue: widget.pwd,
      obscureText: _isObscure,
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入密码';
        }
      },
      decoration: InputDecoration(
          hintText: '请输入密码',
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.black,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = _isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color;
                });
              })),
    );
  }

  TextFormField buildUserAccountTextField() {
    print('_userAccount ---- $_userAccount');
    return TextFormField(
      initialValue: widget.name,
      decoration: InputDecoration(
          hintText: "请输入账号",
          prefixIcon: Icon(
            Icons.perm_identity,
            color: Colors.black,
          )),
      validator: (String value) {
        return value;
      },
      onSaved: (String value) {
        print(value);
        _userAccount = value;
      },
    );
  }

  Widget buildTitleImage() {
    return Container(
      child: Center(
        child: new Column(
          children: <Widget>[
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset("images/app_logo.png"),
            ),
            Center(
              child: Text(
                "智慧课堂",
                style: TextConfig.getTextStyle(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
