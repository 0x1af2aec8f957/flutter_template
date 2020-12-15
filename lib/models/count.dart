import 'package:flutter/material.dart';

class CountModel extends ChangeNotifier { // ChangeNotifier将在组件生命周期结束时自动为你销毁订阅
  // state
  int value = 0;

  // action
  void increment() {
    value += 1;
    notifyListeners(); // 发布通知更新
  }
}