import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter/painting.dart' show HSLColor;

class CssColor extends Color {
  CssColor(final String strColor) : super(getColorFromString(strColor));

  static int getColorFromString(String str) {
    if (str.startsWith('#')) return getColorFromHex(str);
    if (str.startsWith('rgba')) return getColorFromRGBA(str);
    if (str.startsWith('rgb')) return getColorFromRGB(str);
    if (str.startsWith('hsla')) return getColorFromHSLA(str);
    if (str.startsWith('hls')) return getColorFromHSL(str);

    return Colors.transparent.value;
  }

  static int getColorFromHex(String str) {
    String hexColor = str.toUpperCase().replaceAll("#", "").replaceAll('0X', '');
    if (hexColor.startsWith('#') || hexColor.startsWith('0X')) {
      if (hexColor.length == 6) hexColor = "FF" + hexColor;
      return int.parse(hexColor, radix: 16);
    }

    return Colors.transparent.value;
  }

  static int getColorFromRGB(String str) {
    final String rgbColor = str.toUpperCase();
    if (rgbColor.startsWith('RGB')) {
      final rgb = rgbColor.replaceAll('RGB(', '').replaceAll(')', '').split(',').map(int.parse);
      return Color.fromRGBO(rgb.first, rgb.elementAt(1), rgb.last, 1).value;
    }

    return Colors.transparent.value;
  }

  static int getColorFromRGBA(String str) {
    final String rgbaColor = str.toUpperCase();
    if (rgbaColor.startsWith('RGBA')) {
      final rgbo = rgbaColor.replaceAll('RGBA(', '').replaceAll(')', '').split(',');
      final rgb = rgbo.sublist(0, 3).map(int.parse);
      final opacity = double.parse(rgbo.last);
      return Color.fromRGBO(rgb.first, rgb.elementAt(1), rgb.last, opacity).value;
    }

    return Colors.transparent.value;
  }

  static int getColorFromHSL(String str) {
    final String hslColor = str.toUpperCase();
    if (hslColor.startsWith('HSL')) {
      final hsl = hslColor.replaceAll('HSL(', '').replaceAll(')', '').split(',');
      final h = double.parse(hsl.first);
      final s = double.parse(hsl.elementAt(1).replaceAll('%', '')) / 100;
      final l = double.parse(hsl.last.replaceAll('%', '')) / 100;

      return HSLColor.fromAHSL(1, h, s, l).toColor().value;
    }

    return Colors.transparent.value;
  }

  static int getColorFromHSLA(String str) {
    final String hslaColor = str.toUpperCase();
    if (hslaColor.startsWith('HSLA')) {
      final hsla = hslaColor.replaceAll('HSLA(', '').replaceAll(')', '').split(',');
      final alpha = double.parse(hsla.first);
      final h = double.parse(hsla.elementAt(1));
      final s = double.parse(hsla.elementAt(2).replaceAll('%', '')) / 100;
      final l = double.parse(hsla.last.replaceAll('%', '')) / 100;

      return HSLColor.fromAHSL(alpha, h, s, l).toColor().value;
    }

    return Colors.transparent.value;
  }
}