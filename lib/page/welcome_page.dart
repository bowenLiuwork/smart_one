import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_one/business/login_data_helper.dart';
import 'package:smart_one/common/skip_down_time.dart';
import 'package:smart_one/page/login_page.dart';
import 'package:smart_one/page_constance.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() {
    return new _WelcomePageState();
  }
}

class _WelcomePageState extends State<WelcomePage>
    implements OnSkipClickListener {
  var welcomeImageUrl = '';
  bool isLoginActive = false;
  String userLoginName = "";
  String userLoginPwd = "";

  @override
  void initState() {
    _initLoginData();
    super.initState();
    _initLoginStatus();
    _getWelcomeImage();
    _delayedGoHomePage();
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

  _initLoginStatus() async {
    bool active = await LoginDataHelper.isLoginActive();
    setState(() {
      isLoginActive = active == null ? false : active;
    });
  }

  _delayedGoHomePage() {
    Future.delayed(new Duration(seconds: 5), () {
      _goHomePage();
    });
  }

  _goHomePage() {
    print("-------------- ${isLoginActive}");
    if (isLoginActive) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          PageConstance.HOME_PAGE, (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) {
        return new LoginPage(
          name: userLoginName,
          pwd: userLoginPwd,
        );
      }), (Route<dynamic> route) => false);
//      Navigator.of(context).pushNamedAndRemoveUntil(
//          PageConstance.LOGIN_PAGE, (Route<dynamic> route) => false);
    }
  }

  _getWelcomeImage() async {
//    String url = AppConstance.makeUrl('services/app_ad_cover.json', null);
//    var response = await http.get(url);
//    print(response.body);
//    List list = json.decode(response.body);
//    String cover = '';
//    var item;
//    for (item in list) {
//      cover = item['field_app_ad_cover'];
//      if (cover != null && cover.isNotEmpty) {
//        cover = StringUtil.getSrcImagePath(cover);
//        break;
//      }
//    }

//    print('cover===$cover');
//    setState(() {
//      welcomeImageUrl = cover;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        new Container(
          color: Colors.white,
          child: welcomeImageUrl.isNotEmpty
              ? new Image.network(
                  welcomeImageUrl,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.white,
                  child: Center(
                    child: Text("Weclome!",
                        style: Theme.of(context).textTheme.display1),
                  ),
                ),
          constraints: new BoxConstraints.expand(),
        ),
        new Container(
          child: Align(
            alignment: Alignment.topRight,
            child: new Container(
              padding: const EdgeInsets.only(top: 30.0, right: 20.0),
              child: new SkipDownTimeProgress(
                Colors.red,
                22.0,
                new Duration(seconds: 5),
                new Size(25.0, 25.0),
                skipText: "跳过",
                clickListener: this,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onSkipClick() {
    _goHomePage();
  }
}
