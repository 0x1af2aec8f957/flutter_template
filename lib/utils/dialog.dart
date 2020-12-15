import 'package:flutter/material.dart';
// import 'package:bot_toast/bot_toast.dart';

import '../setup/config.dart';

final BuildContext globalContext = AppConfig.navigatorKey.currentState.overlay.context;

@immutable
abstract class Talk {
  static void toast(String text, {int duration}) {
    final insert = AppConfig.navigatorKey.currentState.overlay.insert;
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

    // Overlay.of(globalContext).insert(entry);
    insert(entry);

    Future.delayed(Duration(seconds: duration ?? 2), () => entry?.remove());
  }

  static void snackBar(String text, {SnackBarAction action, Duration duration}) { // 底部提示信息
    ScaffoldMessenger.of(globalContext)
      ..removeCurrentSnackBar() // 移除上一次的snackBar
      ..showSnackBar(SnackBar(content: Text(text), duration: duration, action: action));
  }

  static void loading([String text]) {
    showDialog(
      context: globalContext,
      barrierDismissible: false, //点击遮罩不关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(top: 26.0),
                child: Text(text ?? "请稍后..."),
              )
            ],
          ),
        );
      },
    );
  }

  static Future<bool> alert(String text, {bool isCancel = true, String title = '提示'}) {
    return showDialog<bool>(
      context: globalContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            /*Offstage( // 需要隐藏后维护状态，请使用Visibility
              offstage: isCancel,
              child: FlatButton(
                child: Text("取消"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),*/
            if (isCancel) FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                // 执行删除操作
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
