import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class AppConfig {
  static String system = Platform.operatingSystem; // 操作系统字符串（小写）
  static String systemVersion = Platform.operatingSystemVersion; // 操作系统版本

  // Flutter的四种运行模式: https://www.jianshu.com/p/4db65478aaa3
  static bool isProduction = const bool.fromEnvironment("dart.vm.product"); // 运行时环境

  static Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  static DeviceInfoPlugin deviceInfo = DeviceInfoPlugin(); // 设备信息
  static Locale get local => Localizations.localeOf(navigatorContext); // 当前应用的语言

  /// 外部路由跳转 -> navigatorKey.currentState.pushName('router_url')
  /// 外部fluro路由跳转 -> navigatorKey.currentState.push(CupertinoPageRoute(builder: (BuildContext context) => handler.handlerFunc(context, parameters)))
  static GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>(); // 适用于路由全局跳转的 key
  static BuildContext get navigatorContext => navigatorKey.currentState!.overlay!.context; // 全局 context，需要在使用时直接引用使用，不能在文件头部直接申明赋值使用，防止未初始化

  static List<Locale> get locales => const [ // 支持的语言列表, 默认语言为第一个语言。
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];
}