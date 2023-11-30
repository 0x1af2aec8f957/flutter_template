import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class AppConfig {
  static String platform = Platform.operatingSystem; // 平台字符串

  // Flutter的四种运行模式: https://www.jianshu.com/p/4db65478aaa3
  static bool isProduction = const bool.fromEnvironment("dart.vm.product"); // 运行时环境

  static Future<PackageInfo> packageInfo = PackageInfo.fromPlatform(); // 应用信息
  static DeviceInfoPlugin deviceInfo = DeviceInfoPlugin(); // 设备信息
  static Locale get local => Localizations.localeOf(navigatorKey.currentState!.overlay!.context); // 当前应用的语言

  /// 外部获取context -> Context context = navigatorKey.currentState.overlay.context
  /// 外部路由跳转 -> navigatorKey.currentState.pushName('router_url')
  /// 外部fluro路由跳转 -> navigatorKey.currentState.push(CupertinoPageRoute(builder: (BuildContext context) => handler.handlerFunc(context, parameters)))
  static GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>(); // 适用于路由全局跳转的key

  static List<Locale> get locales => const [ // 支持的语言列表, 默认语言为第一个语言。
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];
}