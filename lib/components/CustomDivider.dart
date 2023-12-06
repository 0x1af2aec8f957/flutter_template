import 'package:flutter/material.dart';

/// 自定义 Divider 组件

class CustomDivider extends Divider {
  final Color? color;
  final double? height;
  final double? indent;
  final double? endIndent;
  final bool isIndentEqual;

  const CustomDivider({
    Key? key,
    this.color = Colors.transparent,
    this.height,
    this.indent,
    this.endIndent,
    this.isIndentEqual = true,
  }) : super(
    key: key,
    color: color,
    height: height,
    thickness: height,
    indent: indent,
    endIndent: isIndentEqual ? indent : endIndent,
  );
}

class CustomVerticalDivider extends VerticalDivider {
  final Color? color;
  final double? width;
  final double? indent;
  final double? endIndent;
  final bool isIndentEqual;

  const CustomVerticalDivider({
    Key? key,
    this.color = Colors.transparent,
    this.width,
    this.indent,
    this.endIndent,
    this.isIndentEqual = true,
  }) : super(
    key: key,
    color: color,
    width: width,
    thickness: width,
    indent: indent,
    endIndent: isIndentEqual ? indent : endIndent,
  );
}