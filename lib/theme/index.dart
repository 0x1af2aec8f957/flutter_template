import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

abstract class CustomTheme {
  static ThemeData light = ThemeData( // 深色
    brightness: Brightness.light, // 应用整体主题的亮度。用于按钮之类的小部件，以确定在不使用主色或强调色时选择什么颜色。
    // primarySwatch: MaterialColor(),// 定义一个单一的颜色以及十个色度的色块。
    primaryColor: Colors.white, // 应用程序主要部分的背景颜色(toolbars、tab bars 等)
    primaryColorBrightness: Brightness.light, // primaryColor的亮度。用于确定文本的颜色和放置在主颜色之上的图标(例如工具栏文本)。
    primaryColorLight: const Color(0xFFF5F5F6), // primaryColor的浅色版
    primaryColorDark: const Color(0xFF27C08B), // primaryColor的深色版
    canvasColor: Colors.white, //  MaterialType.canvas 的默认颜色
    scaffoldBackgroundColor: Colors.white/*const Color(0xFFF5F6F6)*/, // Scaffold的默认颜色。典型Material应用程序或应用程序内页面的背景颜色。
    bottomAppBarColor: const Color(0xFFDEDEDF), // BottomAppBar的默认颜色
    cardColor: Colors.white, // Card的颜色
    dividerColor: const Color(0xFFECECED), // Divider和PopupMenuDivider的颜色，也用于ListTile之间、DataTable的行之间等。
    highlightColor: Colors.white.withOpacity(0), // 选中在泼墨动画期间使用的突出显示颜色，或用于指示菜单中的项。
    splashColor: Colors.transparent /* 取消水波纹效果 */,  // 墨水飞溅的颜色。InkWell
    splashFactory: InkSplash.splashFactory /* 取消水波纹效果 */, // 定义由InkWell和InkResponse反应产生的墨溅的外观。
    selectedRowColor: const Color(0xFF27C08B), // 用于突出显示选定行的颜色。
    unselectedWidgetColor: const Color(0xFF41414C), // 用于处于非活动(但已启用)状态的小部件的颜色。例如，未选中的复选框。通常与accentColor形成对比。也看到disabledColor。
    disabledColor: Colors.grey, // 禁用状态下部件的颜色，无论其当前状态如何。例如，一个禁用的复选框(可以选中或未选中)。
    // buttonColor: Color(0xFFECECED), // RaisedButton按钮中使用的Material 的默认填充颜色。
    // buttonTheme: ButtonThemeData(), // 定义按钮部件的默认配置，如RaisedButton和FlatButton。
    secondaryHeaderColor: const Color(0xFF27C08B), // 选定行时PaginatedDataTable标题的颜色。
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.black, // 文本框中文本选择的颜色，如TextField
      cursorColor: Colors.black, // 文本框中光标的颜色，如TextField
      selectionHandleColor: Colors.black,  // 用于调整当前选定的文本部分的句柄的颜色。
    ),
    backgroundColor: Color(0xFFECECED), // 与主色形成对比的颜色，例如用作进度条的剩余部分。
    dialogBackgroundColor: Colors.white, // Dialog 元素的背景颜色
    indicatorColor: const Color(0xFF27C08B), // 选项卡中选定的选项卡指示器的颜色。
    hintColor: Colors.grey, // 用于提示文本或占位符文本的颜色，例如在TextField中。
    errorColor: Colors.redAccent, // 用于输入验证错误的颜色，例如在TextField中
    toggleableActiveColor: const Color(0xFF27C08B), // 用于突出显示Switch、Radio和Checkbox等可切换小部件的活动状态的颜色。
    // String fontFamily, // 文本字体
    // TextTheme textTheme, // 文本的颜色与卡片和画布的颜色形成对比。
    // TextTheme primaryTextTheme, // 与primaryColor形成对比的文本主题
    // TextTheme accentTextTheme, // 与accentColor形成对比的文本主题。
    // InputDecorationTheme inputDecorationTheme, // 基于这个主题的 InputDecorator、TextField和TextFormField的默认InputDecoration值。
    // IconThemeData iconTheme, // 与卡片和画布颜色形成对比的图标主题
    // IconThemeData primaryIconTheme, // 与primaryColor形成对比的图标主题
    // IconThemeData accentIconTheme, // 与accentColor形成对比的图标主题。
    // SliderThemeData sliderTheme,  // 用于呈现Slider的颜色和形状
    // TabBarTheme tabBarTheme, // 用于自定义选项卡栏指示器的大小、形状和颜色的主题。
    //  CardTheme cardTheme, // Card的颜色和样式
    // ChipThemeData chipTheme, // Chip的颜色和样式
    // TargetPlatform platform,
    // MaterialTapTargetSize materialTapTargetSize, // 配置某些Material部件的命中测试大小
    // PageTransitionsTheme pageTransitionsTheme,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: const Color(0xFF41414C), opacity: 1, size: 12),
      actionsIconTheme: IconThemeData(color: const Color(0xFF41414C), opacity: 1, size: 14),
        toolbarTextStyle: TextStyle(fontSize: 18, color: const Color(0xFF41414c), fontWeight: FontWeight.w500),
        titleTextStyle: TextStyle(fontSize: 18, color: const Color(0xFF41414c), fontWeight: FontWeight.w500)
    ), // 用于自定义Appbar的颜色、高度、亮度、iconTheme和textTheme的主题。
    // BottomAppBarTheme bottomAppBarTheme, // 自定义BottomAppBar的形状、高度和颜色的主题。
    colorScheme: ColorScheme(
      // secondary: Colors.white, // 小部件的前景色(旋钮、文本、覆盖边缘效果等)。
      primary: const Color(0xFF27C08B),
      primaryVariant: const Color(0xFFE05C74),
      secondary: const Color(0xFFE05C74),
      secondaryVariant: const Color(0xFF8D8D94),
      surface: const Color(0xFF41414C),
      background: const Color(0xFFF5F6F6),
      error: const Color(0xFFCF7080),
      onPrimary: const Color(0xFF66666F),
      onSecondary: Color(0xFFB3B3B7),
      onSurface: Color(0xFFC6C6C9),
      onBackground: Colors.white,
      onError: Colors.red,
      brightness: Brightness.light,
    ), // 拥有13种颜色，可用于配置大多数组件的颜色。
    // DialogTheme dialogTheme, // 自定义Dialog的主题形状
    // Typography typography, // 用于配置TextTheme、primaryTextTheme和accentTextTheme的颜色和几何TextTheme值。
    // CupertinoThemeData cupertinoOverrideTheme
  );

  static ThemeData dark = ThemeData( // 浅色

  );
}
