import 'package:flutter/material.dart' show Localizations, Locale;

import '../setup/lang.dart' show MainLocalizations, ChangeLocale;
import '../setup/config.dart' show AppConfig;

abstract class I18n {
  static String $t(String module, String path, {String? sep, dynamic arg}) => MainLocalizations.of(AppConfig.navigatorContext)!.getValue(module, path, arg: arg, sep: sep)!; // 获取当前语言值
  static Locale get local => Localizations.localeOf(AppConfig.navigatorContext); // 获取当前应用的语言，config文件也会实时更新
  static void setLanguage(Locale locale) => ChangeLocale(locale).dispatch(AppConfig.navigatorContext);
}