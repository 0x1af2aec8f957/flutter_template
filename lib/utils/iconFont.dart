import 'package:flutter/material.dart';
// 自定义字体库

class IconFont {
  final int hexData;
  final Color color;
  final num size;

  IconFont(this.hexData, {this.color = Colors.black, this.size = 24}): assert(hexData != null);
  Widget call() => Icon(IconData(hexData, fontFamily: 'iconFont'), color: color, size: size?.toDouble());

  static back({color, size}) => IconFont(0xe66f, color: color, size: size)(); // 返回
  static share({color, size}) => IconFont(0xe660, color: color, size: size)(); // 分享
  static transaction({color, size}) => IconFont(0xe661, color: color, size: size)(); // 合约交易
  static filter({color, size}) => IconFont(0xe662, color: color, size: size)(); // 筛选
  static up({color, size}) => IconFont(0xe663, color: color, size: size)(); // 向上
  static down({color, size}) => IconFont(0xe66b, color: color, size: size)(); // 向下
  static noSelect({color, size}) => IconFont(0xe664, color: color, size: size)(); // 单选未选中
  static select({color, size}) => IconFont(0xe666, color: color, size: size)(); // 单选选中
  static info({color, size}) => IconFont(0xe665, color: color, size: size)(); // 合约信息
  static about({color, size}) => IconFont(0xe667, color: color, size: size)(); // 合约关于
  static question({color, size}) => IconFont(0xe668, color: color, size: size)(); // 合约帮助
  static limit({color, size}) => IconFont(0xe66a, color: color, size: size)(); // 合约限制
  static transfer({color, size}) => IconFont(0xe66c, color: color, size: size)(); // 资金划转
  static cancelOrder({color, size}) => IconFont(0xe66d, color: color, size: size)(); // 全部撤单
  static rate({color, size}) => IconFont(0xe66e, color: color, size: size)(); // 费率
}
