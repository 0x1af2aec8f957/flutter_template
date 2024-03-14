import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart' show ValueNotifier;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../setup/config.dart';

final _wsUrl = Uri.parse('wss://example.com');

class CustomStompClient {
  StompClient? client; // Stomp 客户端
  ValueNotifier<bool> isConnected = ValueNotifier(false); // 是否已连接（UI 更新可以使用 ValueListenableBuilder 构建）
  final Map<String, void Function({Map<String, String>? unsubscribeHeaders})> unSubscribeTopicFunctions = Map(); // 取消订阅函数

  Future<StompConfig> get config {
    return SharedPreferences.getInstance().then((prefs) => StompConfig( // 配置文件
      url: _wsUrl.toString(),
      onConnect: onConnect,
      onStompError: onStompError,
      onDisconnect: onDisconnect,
      beforeConnect: onBeforeConnect,
      onDebugMessage: onDebugMessage,
      stompConnectHeaders: {
        "username": "username",
        "Authorization": prefs.getString('token') ?? '',
      },
      webSocketConnectHeaders: {
        "username": "username",
        "Authorization": prefs.getString('token') ?? '',
      },
    ));
  }

  CustomStompClient._internal() {
    config.then((_config) {
      print('Stomp 正在使用的凭证：${_config.stompConnectHeaders?['Authorization']})');
      client ??= StompClient(config: _config); // 初始化
      activate(); // 自动连接
    });
  }

  factory CustomStompClient() => _instance;
  static late final CustomStompClient _instance = CustomStompClient._internal();

  void onConnect(StompFrame connectFrame) { // 连接
    isConnected.value = client?.connected ?? false;
    print('Stomp connected');
    /* subscribe('/topic/greetings', (StompFrame frame) {
      print('/topic/greetings - Received: ${frame.body}');
    });
    sendMessage('/app/hello', 'Hello, STOMP'); */
  }

  Future<void> onBeforeConnect() async { // 连接前
    isConnected.value = client?.connected ?? false;
    print('Waiting to stomp connect...');
    await Future.delayed(const Duration(milliseconds: 200));
    print('Stomp connecting...');
  }

  void onStompError(StompFrame frame) { // 错误
    isConnected.value = client?.connected ?? false;
    print('Stomp error');
  }

  void onDisconnect(StompFrame frame) { // 断开连接
    isConnected.value = client?.connected ?? false;
    print('Stomp disconnect');
  }

  Future<void Function({Map<String, String>? unsubscribeHeaders})?> subscribe(String topic, Function(StompFrame frame) callback, { Map<String, String>? headers }) { // 订阅
    return Future.doWhile(() => Future.delayed(Duration(seconds: 1), () => !isConnected.value/* 等待 stomp 连接完成 */)).then((_) { // 等待 stomp 连接完成才能订阅
      final unSubscribeFunc = client?.subscribe(
        destination: topic,
        callback: callback,
        headers: headers,
      );

      if(unSubscribeFunc != null) unSubscribeTopicFunctions.update(topic, (value) {
        value(); // 先取消上一个订阅
        return unSubscribeFunc;
      }, ifAbsent: () => unSubscribeFunc);

      return ({Map<String, String>? unsubscribeHeaders}) {
        unSubscribeTopicFunctions.remove(topic);
        return unSubscribeFunc?.call(/* unsubscribeHeaders */);
      };
    });
  }

  void sendMessage(String topic, String? body, { Map<String, String>? headers, Uint8List? binaryBody }) { // 发送消息
    return client?.send(
      destination: topic,
      body: body,
      headers: headers,
      binaryBody: binaryBody,
    );
  }

  void unSubscribe(String topic) { // 取消订阅
    unSubscribeTopicFunctions[topic]?.call(); // 取消订阅
    unSubscribeTopicFunctions.remove(topic);
  }

  void activate() { // 连接
    isConnected.value = client?.connected ?? false;
    client?.activate();
  }

  void deactivate() { // 断开连接
    isConnected.value = client?.connected ?? false;
    client?.deactivate();
  }

  void onDebugMessage(String message) { // 调试信息
    // isConnected = client?.connected ?? false;
    if (!AppConfig.isProduction) print('Stomp debug message: ${message}');
  }
}