import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, SystemNavigator;
// import 'package:fluro/fluro.dart';

import '../setup/config.dart';
import '../utils/common.dart' show methodChannel;
import '../lang/i18n.dart';

// 路由寻找规则：routes -> onGenerateRoute -> onUnknownRoute -> throw error

final _navigatorKey = AppConfig.navigatorKey;

class RouterObserver extends NavigatorObserver {
  // 对路由的鉴权拦截，可在此处理[官方路由表不可使用onGenerateRoute钩子]

  RouterObserver(){ // 为原生提供界面控制
    methodChannel.setMethodCallHandler((MethodCall call) {
      final String method = call.method;
      final Map arguments = call.arguments;
      final String name = arguments['name']; // 页面
      final dynamic _arguments = arguments['arguments']; // 参数

      switch (method) {
      // 路由方法
        case "routerPush":
          return Router.push(name, _arguments);
        case 'routerReplace':
          return Router.replace(name, _arguments);
        case 'routerPop':
          try{
            Router.pop(_arguments);
            return Future.value(true);
          }catch(e){
            return Future.value(false);
          }
          break;
        case 'pushAndRemoveUntil':
          return Future.value(Router.pushAndRemoveUntil(name, arguments['withName'], _arguments));
      //  设置参数方法
        case 'setLocale':
          try {
            final _locale = (_arguments as Map);
            I18n.setLanguage(Locale(_locale['languageCode'], _locale['countryCode']));
            return Future.value(true);
          }catch(e) { // 1af2aec8f957
            return Future.value(false);
          }
          break;
      //  获取参数方法
        default:
          return Future.value(I18n.$t('common', 'customErrorMessages[1]'));
      }
    });
  }

  @override
  void didPush(Route route, Route previousRoute) {
    // 对应的push方法
    // 当调用Navigator.push时回调
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    // 对应的pop方法
    super.didPop(route, previousRoute);
    print('this is pop method, ${route.settings.name}');
  }
}

@immutable
abstract class Router { // 外部路由跳转

  static Future push(String routeName, [Object arguments]) {
    return _navigatorKey.currentState.pushNamed(routeName, arguments: arguments ?? {});
  }

  static Future nativePush(String routeName, [Object arguments]) { // 向原生跳转
    return methodChannel.invokeMethod('routerPush', <String, dynamic> {'name': routeName, 'arguments': arguments});
  }

  static Future replace(String routeName,[Object arguments, Object result]){
    return _navigatorKey.currentState.pushReplacementNamed(routeName, arguments: arguments ?? {}, result: result);
  }

  static Future nativeReplace(String routeName,[Object arguments, Object result]){ // 向原生跳转
    return methodChannel.invokeMethod('routerReplace', <String, dynamic> {'name': routeName, 'arguments': arguments ?? result});
  }

  static void pop([Object result]){
    return _navigatorKey.currentState.pop(result);
  }

  static Future nativePop([Object result]){ // 向原生返回
    return methodChannel.invokeMethod('routerPop', <String, dynamic> {'arguments': result});
  }

  static Future pushAndRemoveUntil(String routeName, [String withName, Object arguments]){
    return _navigatorKey.currentState.pushNamedAndRemoveUntil(routeName, withName == null ? (Route<dynamic> route) => false : ModalRoute.withName(withName), arguments: arguments ?? {});
  }

  static nativePushAndRemoveUntil(String routeName, [String withName, Object arguments]){ // 跳转并删除原生前路由
    methodChannel.invokeMethod('pushAndRemoveUntil', <String, dynamic> {'name': routeName, 'arguments': <String, dynamic>{withName: withName, arguments: arguments}});
  }

  static Future navigatorPop() async{ // 关闭flutter实例
    return methodChannel.invokeMethod('navigatorPop').then((r) => pushAndRemoveUntil('transform'));
  }
}

/*
class NavigatorUtils { // fluro路由管理

  //不需要页面返回值的跳转
  static push(
      BuildContext context,
      String path,
      {bool replace = false,
        bool clearStack = false}
        ) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Application.router.navigateTo(context, path, replace: replace, clearStack: clearStack, transition: TransitionType.native);
  }

  //需要页面返回值的跳转
  static pushResult(
      BuildContext context,
      String path,
      Function(Object) function,
      {bool replace = false, bool clearStack = false}
      ) {

    FocusScope.of(context).requestFocus(new FocusNode());

    Application.router.navigateTo(context, path, replace: replace, clearStack: clearStack, transition: TransitionType.native).then((result){
      // 页面返回result为null
      if (result == null){
        return;
      }
      function(result);
    }).catchError((error) {
      print("$error");
    });
  }

  /// 返回
  static void goBack(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
  }

  /// 带参数返回
  static void goBackWithParams(BuildContext context, result) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context, result);
  }

}*/
