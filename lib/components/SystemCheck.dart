import 'package:flutter/material.dart';

import '../setup/config.dart';

/// 受支持的系统检测

class SystemCheck extends StatelessWidget{
  final Widget child;

  final List<String> supportSystems = const ['android', 'ios']; // 当前应用受支持的操作系统
  bool get isSupportCurrentSystem => supportSystems.contains(AppConfig.system); // 当前应用是否支持当前操作系统

  SystemCheck({
    required this.child // 有网络时展示的小部件
  });

  @override
  Widget build(BuildContext context) {
    return isSupportCurrentSystem ? child : Scaffold(
      body: SafeArea( // 安全区域，针对不规则的屏幕进行适配
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apps_outage, size: 50),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Text('应用尚未准备好在你的系统运行', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}