import 'package:flutter/material.dart';

/// 自定义 Divider 组件
class CustomDivider extends Divider {
  const CustomDivider({
    Key? super.key,
    super.color = Colors.transparent,
    super.height,
    super.indent,
    double? endIndent,
    bool isIndentEqual = true,
  }) : super(
    thickness: height,
    endIndent: isIndentEqual ? indent : endIndent,
  );
}

class CustomVerticalDivider extends VerticalDivider {
  const CustomVerticalDivider({
    Key? super.key,
    super.color = Colors.transparent,
    super.width,
    super.indent,
    double? endIndent,
    bool isIndentEqual = true,
  }) : super(
    thickness: width,
    endIndent: isIndentEqual ? indent : endIndent,
  );
}