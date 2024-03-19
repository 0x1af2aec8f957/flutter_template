import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络状态监听组件。

class NetworkState extends StatefulWidget {
  final Widget child;

  const NetworkState({
    super.key,
    required this.child // 有网络时展示的小部件
  });

  @override
  State<NetworkState> createState() => _NetworkState();
}

class _NetworkState extends State<NetworkState> {
  final Connectivity connectivity = Connectivity(); // 初始化网络侦听器
  late StreamSubscription<ConnectivityResult> connectSubscription; // 订阅网络状态流
  ConnectivityResult connectionResult = ConnectivityResult.none; // 网络状态链接结果，需要初始化一个状态为 [none] 的变量以避免启动时为空

  bool get hasNetwork => connectionResult != ConnectivityResult.none; // 网络是否可用 或 是否有网络链接
  bool get isWifi => connectionResult == ConnectivityResult.wifi; // 是否使用WiFi网络

  void updateConnectionStatus(ConnectivityResult _connectivityResult) { // 升级网络状态
    /// ConnectivityResult.Mobile: 连接到移动蜂窝网络.
    /// ConnectivityResult.WiFi: 连接到 WiFi 接入点.
    /// ConnectivityResult.Ethernet: 连接到以太网络.
    /// ConnectivityResult.None: 没有连接.
    setState((){
      connectionResult = _connectivityResult;
    });
  }

  void inspectConnectionStatus(){ // 主动检查网络状态
    connectivity.checkConnectivity().then(updateConnectionStatus); // 网络链接状态检查
  }

  @override
  void initState() {
    super.initState();

    connectSubscription = connectivity.onConnectivityChanged.listen(updateConnectionStatus); // 订阅网络状态变化事件
    if (!Platform.isAndroid /* 安卓会走两次 */) inspectConnectionStatus(); // 首次检查网络状态
  }

  @override
  dispose() {
    connectSubscription.cancel(); // 销毁时，取消订阅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return hasNetwork ? widget.child : Scaffold(
      body: SafeArea( // 安全区域，针对不规则的屏幕进行适配
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isWifi ? Icons.network_check : Icons.network_locked, size: 50),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Text('网络连接已断开，请检查网络状态', style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.black),
                        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                        overlayColor: MaterialStateProperty.all(Colors.grey[100]),
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13, horizontal: 25))
                    ),
                    onPressed: inspectConnectionStatus, icon: Icon(Icons.refresh), label: Text('刷新', style: TextStyle(fontSize: 18),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
