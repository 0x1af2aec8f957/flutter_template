import 'package:flutter/services.dart' show MethodCall;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';
import '../lang/i18n.dart';
import '../setup/config.dart';
import '../utils/common.dart' show methodChannel;

final router = GoRouter(
  routes: routes,
  observers: [RouterObserver()],
  navigatorKey: AppConfig.navigatorKey, // 应用外部使用路由跳转
  debugLogDiagnostics: !AppConfig.isProduction,
  initialLocation: WidgetsBinding.instance.platformDispatcher.defaultRouteName, // 平台默认路由
  errorBuilder: AppConfig.isProduction ? (BuildContext _context, GoRouterState _state) => Scaffold(
    appBar: AppBar(
      elevation: 1,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text('Program exception'),
    ),
    body: Center(
        child: Text('Please exit and open again')
    ),
  ): null,
  onException: (BuildContext _context, GoRouterState _state, GoRouter _router) {
    print('路由异常：${_state.error}');
    /* if (AppConfig.isProduction){ // 在生产环境，将覆盖 ErrorWidget 向屏幕输出错误的信息
      ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          title: Text('Program exception'),
          centerTitle: true,
        ),
        body: Center(
            child: Text('Please exit and open again')
        ),
      );
    } */
  },
  /* redirect: (BuildContext context, GoRouterState state) { // 鉴权或其它需要重定向的逻辑
    if (AuthState.of(context).isSignedIn) {
      return '/signin';
    } else {
      return null;
    }
  }, */
);

class RouterObserver extends NavigatorObserver {
  // 对路由的鉴权拦截，可在此处理[官方路由表不可使用onGenerateRoute钩子]

  RouterObserver() {
    methodChannel.setMethodCallHandler((MethodCall call) { // 为原生提供界面控制
      final String method = call.method;
      final Map arguments = call.arguments;
      final String name = arguments['name']; // 页面
      final dynamic _arguments = arguments['arguments']; // 参数

      switch (method) {
      // 路由方法
        case "routerPush":
          return router.push(name, extra: _arguments);
        case 'routerReplace':
          return router.replace(name, extra: _arguments);
        case 'routerPop':
          try{
            router.pop(_arguments);
            return Future.value(true);
          }catch(e){
            return Future.value(false);
          }
        case 'pushAndRemoveUntil':
          try{
            router.go(name, extra: _arguments);
            return Future.value(true);
          }catch(e){
            return Future.value(false);
          }
      //  设置参数方法
        case 'setLocale':
          try {
            final _locale = (_arguments as Map);
            I18n.setLanguage(Locale(_locale['languageCode'], _locale['countryCode']));
            return Future.value(true);
          }catch(e) { // 1af2aec8f957
            return Future.value(false);
          }
      //  获取参数方法
        default:
          return Future.value(I18n.$t('common', 'customErrorMessages[1]'));
      }
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    // 对应的push方法
    // 当调用Navigator.push时回调
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // 对应的pop方法
    super.didPop(route, previousRoute);
    print('this is pop method, ${route.settings.name}');
  }
}