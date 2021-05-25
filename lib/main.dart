import 'package:flutter/material.dart';
import 'dart:ui' show window;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; // https://github.com/noteScript/flutter_screenutil

import './setup/config.dart';
import './setup/lang.dart';
import './routes.dart';
import './setup/router.dart';
import './theme/index.dart';
import './setup/providers.dart';
import './models/global.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await MainLocalizations.localLocaleAssets(); // 先加载国际化语言包
  return runApp(MultiProvider(
    providers: providers,
    child: App(),
  ));
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  // DateTime lastTime;
  Locale _locale = AppConfig.locales.first; // 默认语言

  final GlobalKey<NavigatorState> navigatorKey = AppConfig.navigatorKey;
  final List<Locale> supportedLocales = AppConfig.locales;

  MainLocalizationsDelegate _localeOverrideDelegate = MainLocalizationsDelegate();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 设置状态栏颜色
    ));

    // ScreenUtil.init(context, width: 357, height: 667); // 设计图大小

    return NotificationListener<ChangeLocale>(
        onNotification: (notification) {
          // 语言改变
          changeLocale(notification.locale);
          return true;
        },
        child: MaterialApp(
          navigatorKey: navigatorKey, // 应用外部使用路由跳转
          localizationsDelegates: [
            // 本地化的代理类
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            // 翻译逻辑
            _localeOverrideDelegate,
          ],
          supportedLocales: supportedLocales,
          locale: _locale, //手动指定locale, 后续使用Localizations.localeOf(context)获取设备语言
          localeResolutionCallback:
              (Locale locale, Iterable<Locale> supportedLocales) {
            // 系统语言改变时回调，返回一个新的locale作为应用语言
            // 此处可以设置统一的国家语言
            print('当前设备语言：$locale');
            return supportedLocales.contains(locale)
                ? locale
                : supportedLocales.first;
          },
          // title: 'Flutter App',
          onGenerateTitle: (BuildContext context) {
            // 国际话返回的标题
            return MainLocalizations.of(context).getValue('common', 'title');
          },
          initialRoute: window.defaultRouteName, // 提供外部原生控制，home的默认值为'/'
          // home: Home(),
          onGenerateRoute: (RouteSettings settings) { // 提供url形式的路由传参
            final Uri routeObject = Uri.parse(settings.name);
            final String name = routeObject.path;
            final Map<String, dynamic> arguments = Map();
            final _arguments = settings.arguments;

            arguments.addAll(routeObject.queryParameters); // 添加url参数
            if (_arguments != null) arguments['arguments'] = _arguments; // 添加flutter路由的参数
            final RouteSettings _settings = settings.copyWith(name: name, arguments: arguments);
            final String _name = _settings.name;

            if(!routes.containsKey(_name)) return null;
            return MaterialPageRoute(
              builder: routes[_name],
              settings: _settings,
            );
          },
          navigatorObservers: <NavigatorObserver>[RouterObserver()],
          theme: CustomTheme.light,
          routes: routes,
          onUnknownRoute: (RouteSettings settings) {
            // 404
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) => Scaffold(body: Center(child: Text('Not Found'))),
            );
          },
          /*home: Scaffold(
                    appBar: AppBar(
                      title: const Text('MaterialApp Theme'),
                    ),
                    body: Builder(
                        builder: (context) => WillPopScope(
                            onWillPop: () async {
                              if (lastTime == null || DateTime.now().difference(lastTime) > Duration(seconds: 1)) {
                                lastTime = DateTime.now();
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text("再点一次退出！")));
                                return false;
                              }
                              return true;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Text("1秒内连续按两次返回键退出"),
                            )))),*/
        ));
  }

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final savedLocale = prefs.getString('locale');

      if (savedLocale != null && savedLocale != _locale.toString()) {
        // 加载用户上次选择的语言
        final _savedLocale = savedLocale.split('_');
        changeLocale(Locale(_savedLocale.first, _savedLocale.last));
      }
    });
  }

  void changeLocale(Locale locale) {
    SharedPreferences.getInstance().then((prefs){
      prefs.setString('locale', locale.toString()); // 保存设备选择的语言
    });

    setState(() {
      _locale = locale;
    });

    Provider.of<GlobalModel>(navigatorKey.currentState.overlay.context, listen: false).initData(); // 语言改变后拉取数据
  }
}
