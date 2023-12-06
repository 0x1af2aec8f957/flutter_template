import 'package:flutter/material.dart';
// import 'package:bot_toast/bot_toast.dart';

import '../setup/config.dart';
import '../components/CustomDivider.dart';

final BuildContext _globalContext = AppConfig.navigatorKey.currentState!.overlay!.context;

abstract class Talk {
  static void toast(String text, {int duration = 2}) {
    final insert = AppConfig.navigatorKey.currentState!.overlay!.insert;
    final OverlayEntry entry = OverlayEntry( // OverlayEntry本身使用Stack布局将自身放置在视图最顶层，应当避免再次使用Stack
      builder: /* Widget */(_) => Positioned(
        bottom: 50.0,
        child: Container(
          padding: MediaQuery.of(_).viewInsets, // 解决键盘弹起，提示信息被遮挡的问题
          width: MediaQuery.of(_).size.width,
          alignment: Alignment.center,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0) /* EdgeInsets.all(8) */,
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 14.0, decoration: TextDecoration.none),
              ),
            ),
            color: Colors.black.withOpacity(0.5),
          ),

        ),
      ),

      /*Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: 50.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3.0), // 3像素圆角
              ),
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              // alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 14.0, decoration: TextDecoration.none),
              ),
            ),
          ),
        ],
      ),*/
    );

    // Overlay.of(_globalContext).insert(entry);
    insert(entry);

    Future.delayed(Duration(seconds: duration), () => entry.remove());
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(Widget content, {SnackBarAction? action, Duration duration = const Duration(seconds: 4)}) { // 底部提示信息
    final instance = ScaffoldMessenger.of(_globalContext)
      ..removeCurrentSnackBar(); // 移除上一次的snackBar
    return instance.showSnackBar(SnackBar(content: content, duration: duration, action: action));
  }

  static Future<void> loading([String text = "请稍后..."]) {
    return showDialog<void>(
      context: _globalContext,
      barrierDismissible: false, //点击遮罩不关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(top: 26.0),
                child: Text(text),
              )
            ],
          ),
        );
      },
    );
  }

  static Future<bool> alert(String text, {bool isCancel = true, String title = '提示'}) {
    return showDialog<bool>(
      context: _globalContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            /*Offstage( // 需要隐藏后维护状态，请使用Visibility
              offstage: isCancel,
              child: TextButton(
                child: Text("取消"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),*/
            if (isCancel) TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("确认"),
              onPressed: () {
                // 执行删除操作
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((bool? isConfirm) => isConfirm ?? false);
  }

  static Future<T?> sheetAction<T>({List<Widget> children = const <Widget>[], bool isCancel = true}) {
    return showModalBottomSheet<T>(
      context: _globalContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...children,
            if (isCancel) CustomDivider(height: 5, color: Colors.grey),
            if (isCancel) SafeArea(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        );
      }
    );
  }

  static Future<bool> sheetAlert(String text, {bool isCancel = true}) {
    return sheetAction<bool>(
      isCancel: isCancel,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(text, style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ),
          subtitle: Column(
            children: [
              CustomDivider(height: 1, color: Colors.grey.withOpacity(0.2)),
              TextButton(
                onPressed: () => Navigator.of(_globalContext).pop(true),
                child: Text('确定', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ]
    ).then((bool? isConfirm) => isConfirm ?? false);
  }
}
