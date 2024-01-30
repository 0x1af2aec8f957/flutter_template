// 公共方法
import 'package:flutter/services.dart' show MethodChannel, Clipboard, ClipboardData;

import './constant.dart';
import '../setup/router.dart';
import '../utils/dialog.dart';

final methodChannel = MethodChannel('com.template.flutter');

abstract class PrecisionFix {
  static bool _isNumber(String _number) => num.tryParse(_number) != null;

  static String fromString(String _number, int? digit) {
    if (!_isNumber(_number)) return numberPlaceholder;

    return fromNumber(double.parse(_number), digit ?? 0);
  }

  static String fromAllString(String _number, String? _digit) {
    if (!_isNumber(_number)) return numberPlaceholder;

    final int digit = _digit == null ? 0 : _digit.split('.').last.length;
    return fromNumber(double.parse(_number), digit);
  }

  static int fromDigitString(String? _digit) => _digit == null ? 0 : _digit.split('.').last.length;

  static String fromNumber(num _number, int? digit) {
    if (!_isNumber(_number.toString())) return numberPlaceholder;
    assert(digit == null || digit <= 20 && digit >= 0);

    final int _fractionDigits = (digit ?? 0) + 1;
    if (_fractionDigits > 1 && _fractionDigits <= 20) {
      return _number
          .toStringAsFixed(_fractionDigits)
          .replaceFirst(RegExp(r'\d$'), '');
    }

    return _number.toStringAsFixed(digit ?? 0);

  }
}

String stringFix(String? str) => str ?? stringPlaceholder; // 字符串占位符

Future<void> copy(String? text, { isToast = true }){ // 复制到粘贴板
  if (text != null) return Clipboard
      .setData(ClipboardData(text: text))
      .then((r) => isToast ? Talk.toast('复制成功') : null);

  if (isToast) Talk.toast('复制失败');
  return Future.error('复制失败');
}

Future<ClipboardData?> paste() => Clipboard.getData(Clipboard.kTextPlain);

Future<void> openSchemaUri(Uri? uri) {
  if (uri == null) return Future.error('不是从schema协议启动的，停止跳转');
  return router.push('/example');
}