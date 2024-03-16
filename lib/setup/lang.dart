import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show SynchronousFuture;

import './config.dart';
import '../plugins/dialog.dart';

final Map<String, YamlMap> _languages = Map(); // 语言包

final List<String> languageModule = [ // 语言模块路径
  'assets/locale/home.yaml',
  'assets/locale/common.yaml',
];

// 改变语言通知
class ChangeLocale extends Notification {
  final Locale locale;
  const ChangeLocale(this.locale);
}

// Locale资源类
class MainLocalizations {
  final Locale locale;

  const MainLocalizations(this.locale);

  static Future<void> localLocaleAssets() async{
    if(_languages.isEmpty){
      for (int index = 0; index < languageModule.length; index += 1){
        final String filePath = languageModule[index];
        final String name = path.basenameWithoutExtension(filePath);

        _languages[name] = loadYaml(await rootBundle.loadString(filePath)); // 解析翻译配置文件[按模块配置]
      }
    }
  }

  static MainLocalizations? of(BuildContext context) {
    return Localizations.of<MainLocalizations>(context, MainLocalizations);
  }

  static Map<String, YamlMap> get _localizedValues => _languages;

  /*String get title {
    Talk.log(_localizedValues.runtimeType, name: 'MainLocalizations');
    Talk.log('${locale.toString()}: ${_localizedValues[locale.toString()]}', name: 'MainLocalizations');
    return _localizedValues[locale.toString()]['title'];
  }*/

  String? getValue(String module, String _path, {String? sep, dynamic arg}){ // 获取最终国际化后的值
    final String country = locale.toString();
    final moduleValue = _localizedValues[module]?[country];

    if (moduleValue.runtimeType != YamlMap) return 'Module or country is not Map';

    final List<String> _keys = _path.split('.');
    final dynamic result = _keys.fold(/* moduleValue */null, (dynamic _value, String _key) {
      final _moduleValue = _value ?? moduleValue;

      final RegExp listIndexRegExp = RegExp(r'\[[^\]]+\]');
      if (listIndexRegExp.hasMatch(_key)) { // 匹配到List
        // TODO: ！！！目前仅支持YAML文件value值为数组嵌套的情况为一层
        final String mapKey =  _key.replaceAll(listIndexRegExp, ''); // 去掉中括号内容，涵盖中括号
        final String _idx = listIndexRegExp.stringMatch(_key)!.replaceAll(RegExp(r'\[|\]'), ''); // 匹配到中括号内容，去掉中括号得到数字
        return _moduleValue[mapKey][int.parse(_idx)]; // 返回数组
      }

      return _moduleValue[_key == 'null' ? null : _key];
    });

    if (arg == null) return result;
    return _insetValue(result, sep ?? '', arg);
  }

  String? _insetValue(String? _value , String separator, dynamic _insetValue){ // 国际化插值，遵循I18n插值规范，支持Map/List参数格式化
    return _value?.replaceAllMapped(RegExp(r'\{[^\}]+\}'), (Match match) {
      final String? _key = match.group(0)?.replaceAll(RegExp(r'^\{|\}$'), '');
      final String joinValue = ((_joinValue) => _joinValue == null ? '' : _joinValue.toString())(_insetValue[_key]);

      if (separator.isEmpty) return joinValue; // 无separator的情况下，直接返回结果，无需再次处理

      final String prefix = match.start == 0 ? '' : separator;
      final String suffix = match.end == _value.length ? '' : separator;
      return '$prefix$joinValue$suffix';
    });
  }
}

// Locale代理类
class MainLocalizationsDelegate extends LocalizationsDelegate<MainLocalizations> {
  final Locale? overriddenLocale;
  const MainLocalizationsDelegate([this.overriddenLocale]);

  @override
  bool isSupported(Locale locale) => AppConfig.locales.contains(locale/*.languageCode*/); // 是否支持该语言

  @override
  Future<MainLocalizations> load(Locale locale) { // 语言包初始化
//  final savedLocale = prefs.getString('locale')?.split('_');
//  final _locale = overriddenLocale ?? savedLocale != null ? Locale(savedLocale.first, savedLocale.last) : locale; // 初始化传入的语言 - 用户保存的语言 - 设备语言
    Talk.log('设备即将加载语言包：$locale', name: 'MainLocalizationsDelegate');
    return SynchronousFuture<MainLocalizations>(MainLocalizations(locale));
  }

  @override
  bool shouldReload(MainLocalizationsDelegate old) => false; // false时，不执行上述重写函数
}
