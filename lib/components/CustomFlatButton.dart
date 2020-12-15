import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomFlatButton extends MaterialButton{
  final bool isLoading; // 是否展示loading

  const CustomFlatButton({
    Key key,
    this.isLoading = false,
    @required VoidCallback onPressed,
    VoidCallback onLongPress,
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return RawMaterialButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: isLoading ? null : onLongPress,
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
