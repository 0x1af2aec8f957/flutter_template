import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef _ReturnPromise = Future<dynamic> Function();
typedef _DynamicCallback = dynamic Function();

// ignore: must_be_immutable
class CustomFlatButton extends MaterialButton{
  bool isLoading; // 是否展示loading

  CustomFlatButton({
    Key key,
    this.isLoading = false,
    @required _DynamicCallback onPressed,
    _DynamicCallback onLongPress,
    ValueChanged<bool> onHighlightChanged,
    MouseCursor mouseCursor,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color splashColor = Colors.transparent, // 默认关闭水波纹特效
    Brightness colorBrightness,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    VisualDensity visualDensity,
    ShapeBorder shape,
    Clip clipBehavior = Clip.none,
    FocusNode focusNode,
    bool autoFocus = false,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget child,
    double minHeight = 0,
    double minWidth = 0,
}) : assert(clipBehavior != null),
        assert(autoFocus != null),
        // assert(isLoading != null || onPressed is _ReturnPromise || onLongPress is _ReturnPromise), // loading或点击函数中返回的是Future类型
        super(
        key: key,
        height: minHeight,
        minWidth: minWidth,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHighlightChanged: onHighlightChanged,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        disabledColor: disabledColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        colorBrightness: colorBrightness,
        padding: padding,
        visualDensity: visualDensity,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autoFocus,
        materialTapTargetSize: materialTapTargetSize,
        child: child,
      );

  VoidCallback generateClickFunc(_DynamicCallback handFunc) { // 生成点击事件
    if (handFunc is _ReturnPromise) { // 传入的函数是一个Future类型会自动关闭loading

      return () { // 返回包装处理loading后的函数
        isLoading = true; // 打开loading
        handFunc().whenComplete(() => isLoading = false /* 关闭loading */);
      };
    }

    // 同步函数，不处理loading
    return handFunc;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return RawMaterialButton(
      onPressed: isLoading ? null : generateClickFunc(onPressed),
      onLongPress: isLoading ? null : generateClickFunc(onLongPress),
      onHighlightChanged: onHighlightChanged,
      mouseCursor: mouseCursor,
      fillColor: buttonTheme.getFillColor(this),
      textStyle: theme.textTheme.button.copyWith(color: buttonTheme.getTextColor(this)),
      focusColor: buttonTheme.getFocusColor(this),
      hoverColor: buttonTheme.getHoverColor(this),
      highlightColor: buttonTheme.getHighlightColor(this),
      splashColor: buttonTheme.getSplashColor(this),
      elevation: buttonTheme.getElevation(this),
      focusElevation: buttonTheme.getFocusElevation(this),
      hoverElevation: buttonTheme.getHoverElevation(this),
      highlightElevation: buttonTheme.getHighlightElevation(this),
      disabledElevation: buttonTheme.getDisabledElevation(this),
      padding: buttonTheme.getPadding(this),
      visualDensity: visualDensity ?? theme.visualDensity,
      constraints: buttonTheme.getConstraints(this).copyWith(
        minWidth: minWidth,
        minHeight: height,
      ),
      shape: buttonTheme.getShape(this),
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      materialTapTargetSize: buttonTheme.getMaterialTapTargetSize(this),
      animationDuration: buttonTheme.getAnimationDuration(this),
      child: isLoading ? SizedBox(child: CircularProgressIndicator(strokeWidth: 2.5, backgroundColor: color), width: 20, height: 20) : child,
    );
  }
}
