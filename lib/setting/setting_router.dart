import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';
import 'package:ZY_Player_flutter/setting/page/theme_page.dart';

import 'page/about_page.dart';
import 'page/account_manager_page.dart';
import 'page/setting_page.dart';

class SettingRouter implements IRouterProvider {
  static String settingPage = '/setting';
  static String aboutPage = '/setting/about';
  static String themePage = '/setting/theme';
  static String accountManagerPage = '/setting/accountManager';

  @override
  void initRouter(FluroRouter router) {
    router.define(settingPage, handler: Handler(handlerFunc: (_, __) => SettingPage()));
    router.define(aboutPage, handler: Handler(handlerFunc: (_, __) => AboutPage()));
    router.define(themePage, handler: Handler(handlerFunc: (_, __) => ThemePage()));
    router.define(accountManagerPage, handler: Handler(handlerFunc: (_, __) => AccountManagerPage()));
  }
}
