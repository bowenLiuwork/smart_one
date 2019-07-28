import 'package:flutter/material.dart';
import 'package:smart_one/page/full_page_details.dart';
import 'package:smart_one/page/home_page.dart';
import 'package:smart_one/page/login_page.dart';
import 'package:smart_one/page/main_page.dart';
import 'package:smart_one/page/page_details.dart';
import 'package:smart_one/page/about_page.dart';

class PageConstance {
  static String WELCOME_PAGE = '/';
  static String HOME_PAGE = '/home';
  static String LOGIN_PAGE = '/login_page';
  static String MAIN_PAGE = '/main_page';
  static String LEARN_PAGE = '/leran_page';
  static String FULL_DRAW_PAGE = '/full_draw_page';
  static String ABOUT_PAGE = '/about_page';

  static Map<String, WidgetBuilder> getRoutes() {
    var route = {
      HOME_PAGE: (BuildContext context) {
        return MyHomePage(title: 'demo app');
      },
      LOGIN_PAGE: (BuildContext context) {
        return LoginPage();
      },
      MAIN_PAGE: (BuildContext context) {
        return MainPage();
      },
      LEARN_PAGE: (BuildContext context) {
        return LearnPage(courseId: null,);
      },
      FULL_DRAW_PAGE: (BuildContext context) {
        return FullPageDetails();
      },
      ABOUT_PAGE: (BuildContext context) {
        return AboutPage();
      }
    };

    return route;
  }
}
