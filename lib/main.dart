import 'package:flutter/material.dart';
// import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; // https://github.com/OpenFlutter/flutter_screenutil

import '../utils/common.dart';
import './setup/config.dart';
import './setup/lang.dart';
import './setup/router.dart';
import './theme/index.dart';
import './components/NetWorkState.dart';
import './setup/providers.dart';
import './models/global.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // if(Platform.isIOS) DartPingIOS.register(); // 注册ping插件

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
    // final double dpr = View.of(buildContext).devicePixelRatio; // 获取当前设备的像素比

    return NotificationListener<ChangeLocale>(
        onNotification: (notification) {
          // 语言改变
          changeLocale(notification.locale);
          return true;
        },
        child: WillPopScope(
          onWillPop: () => AppConfig.navigatorKey.currentState!.maybePop(),
          child: MaterialApp.router(
            // navigatorKey: navigatorKey, // 应用外部使用路由跳转
            routeInformationParser: CustomInformationRouteParser(),
            // 路由解析，等价于编码+解码
            routerDelegate: CustomRouteDelegate(),
            // 路由代理（鉴权、拦截等）
            localizationsDelegates: [
              // 本地化的代理类
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              // 翻译逻辑
              _localeOverrideDelegate,
            ],
            supportedLocales: supportedLocales,
            locale: _locale, // 手动指定locale, 后续使用Localizations.localeOf(context)获取设备语言
            localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
              // 系统语言改变时回调，返回一个新的locale作为应用语言
              // 此处可以设置统一的国家语言
              print('当前设备语言：$locale');
              return supportedLocales.contains(locale) ? locale : supportedLocales.first;
            },
            title: 'PHILIPS',
            onGenerateTitle: (BuildContext context) {
              // 国际化返回的标题
              return MainLocalizations.of(context)!.getValue('common', 'title')!;
            },
            theme: CustomTheme.light,
            builder: (context, child) => NetworkState(
              child: Scaffold(
                // Global GestureDetector that will dismiss the keyboard
                body: GestureDetector( // 处理安卓键盘收起问题
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    final FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    }
                  },
                  child: child,
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    // ScreenUtil.init(context, width: 357, height: 667); // 设计图大小

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final savedLocale = prefs.getString('locale');

      if (savedLocale != null && savedLocale != _locale.toString()) {
        // 加载用户上次选择的语言
        final _savedLocale = savedLocale.split('_');
        changeLocale(Locale(_savedLocale.first, _savedLocale.last));
      }

      // checkSchema(); // 检查是否是由 schema 启动
    });
  }

  void changeLocale(Locale locale) {
    SharedPreferences.getInstance().then((prefs){
      prefs.setString('locale', locale.toString()); // 保存设备选择的语言
    });

    setState(() {
      _locale = locale;
    });

    Provider.of<GlobalModel>(navigatorKey.currentState!.overlay!.context, listen: false).initData(); // 语言改变后拉取数据
  }

  /* void checkSchema () { /// 检查是否是由 schema 启动，需要根据 uni_links 配置原生工程: https://pub.dev/packages/uni_links
    // schema example: example://example?userId=123
      try {
        getInitialUri().then(openSchemaUri); // 打开启动时的 uri

        schemaStream ??= uriLinkStream.listen(openSchemaUri,  onError: (err) { // 监听 schema-uri 并 打开热启动的 schema-uri
          // Handle exception by warning the user their action did not succeed
        });
      } on FormatException {
        // Talk.toast(I18n.$t('common', 'parseError'));
        print('schema 协议解析错误');
      }
  } */
}
