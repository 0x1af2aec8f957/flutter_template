/*
 * Created by 李卓原 on 2018/9/29.
 * email: zhuoyuan93@gmail.com
 * 单位屏幕适配
 */

import 'package:flutter/material.dart';

import '../setup/config.dart';

final _navigatorKey = AppConfig.navigatorKey;

class ScreenUtil {
  static ScreenUtil _instance;
  static const int _defaultWidth = 1080;
  static const int _defaultHeight = 1920;
  static BuildContext get _context => _navigatorKey?.currentState?.overlay?.context;

  /// UI设计中手机尺寸 , px
  /// Size of the phone in UI Design , px
  num uiWidthPx;
  num uiHeightPx;

  /// 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false。
  /// allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  bool allowFontScaling;

  ScreenUtil._();
  factory ScreenUtil() => _instance;

  static void init(
      {
        num width = _defaultWidth,
        num height = _defaultHeight,
        bool allowFontScaling = false
      }) {

    _instance ??= ScreenUtil._()
      ..uiWidthPx = width
      ..uiHeightPx = height
      ..allowFontScaling = allowFontScaling;

  }

  static MediaQueryData get _mediaQueryData => MediaQuery.of(_context);
  static get _pixelRatio => _mediaQueryData.devicePixelRatio;
  static get _screenWidth => _mediaQueryData.size.width;
  static get _screenHeight => _mediaQueryData.size.height;
  static get _statusBarHeight => _mediaQueryData.padding.top;
  static get _bottomBarHeight => _mediaQueryData.padding.bottom;
  static get _textScaleFactor => _mediaQueryData.textScaleFactor;

  /// 每个逻辑像素的字体像素数，字体的缩放比例
  /// The number of font pixels for each logical pixel.
  static double get textScaleFactor => _textScaleFactor;

  /// 设备的像素密度
  /// The size of the media in logical pixels (e.g, the size of the screen).
  static double get pixelRatio => _pixelRatio;

  /// 当前设备宽度 dp
  /// The horizontal extent of this size.
  static double get screenWidthDp => _screenWidth;

  ///当前设备高度 dp
  ///The vertical extent of this size. dp
  static double get screenHeightDp => _screenHeight;

  /// 当前设备宽度 px
  /// The vertical extent of this size. px
  static double get screenWidth => _screenWidth * _pixelRatio;

  /// 当前设备高度 px
  /// The vertical extent of this size. px
  static double get screenHeight => _screenHeight * _pixelRatio;

  /// 状态栏高度 dp 刘海屏会更高
  /// The offset from the top
  static double get statusBarHeight => _statusBarHeight;

  /// 底部安全区距离 dp
  /// The offset from the bottom.
  static double get bottomBarHeight => _bottomBarHeight;

  /// 实际的dp与UI设计px的比例
  /// The ratio of the actual dp to the design draft px
  double get scaleWidth => _screenWidth / uiWidthPx;

  double get scaleHeight => _screenHeight / uiHeightPx;

  double get scaleText => scaleWidth;

  /// 根据UI设计的设备宽度适配
  /// 高度也可以根据这个来做适配可以保证不变形,比如你先要一个正方形的时候.
  /// Adapted to the device width of the UI Design.
  /// Height can also be adapted according to this to ensure no deformation ,
  /// if you want a square
  num setWidth(num width) => width * scaleWidth;

  /// 根据UI设计的设备高度适配
  /// 当发现UI设计中的一屏显示的与当前样式效果不符合时,
  /// 或者形状有差异时,建议使用此方法实现高度适配.
  /// 高度适配主要针对想根据UI设计的一屏展示一样的效果
  /// Highly adaptable to the device according to UI Design
  /// It is recommended to use this method to achieve a high degree of adaptation
  /// when it is found that one screen in the UI design
  /// does not match the current style effect, or if there is a difference in shape.
  num setHeight(num height) => height * scaleHeight;

  ///字体大小适配方法
  ///@param [fontSize] UI设计上字体的大小,单位px.
  ///Font size adaptation method
  ///@param [fontSize] The size of the font on the UI design, in px.
  ///@param [allowFontScaling]
  num setSp(num fontSize, {bool allowFontScalingSelf}) => (
      allowFontScalingSelf ?? allowFontScaling
        ? (fontSize * scaleText)
        : ((fontSize * scaleText) / _textScaleFactor)
  );
}

extension SizeExtension on num {
  num get w => ScreenUtil().setWidth(this);

  num get h => ScreenUtil().setHeight(this);

  num get sp => ScreenUtil().setSp(this);

  num get ssp => ScreenUtil().setSp(this, allowFontScalingSelf: true);
}