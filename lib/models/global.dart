import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../setup/config.dart';
import '../setup/router.dart';
import '../plugins/dialog.dart';

class GlobalModel extends ChangeNotifier { // 全局的model
  GlobalModel(){ // 需要全局初始化的数据在此处初始化，按需初始化。
    // 不需要关心返回状态的才能在此处初始化, 需要关心状态的在lib/main.dart中的FutureBuilder处理
    initData();
  }
  // state
  bool isInitLoading = false; // 是否正在初始化数据
  BuildContext get context => AppConfig.navigatorContext; // 全局 context

  // action
  Future<void> initData() { // 切换语言需要请求接口
    if (isInitLoading) return Future.error('初始化尚未完成');
    return Future.sync(() => null).then((_) => Future.wait([
      // request1(),
      // request2(),
    ]))
    .whenComplete(() {
      isInitLoading = false;
      notifyListeners();
    });
  }
}