import 'package:flutter/material.dart';

class GlobalModel extends ChangeNotifier{ // 全局的model
  GlobalModel(){ // 需要全局初始化的数据在此处初始化，按需初始化。
    // 不需要关心返回状态的才能在此处初始化, 需要关心状态的在lib/main.dart中的FutureBuilder处理

  }
  // state

  // action
  initData(){ // 切换语言需要请求接口

  }
}