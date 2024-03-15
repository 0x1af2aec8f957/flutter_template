import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart' show ValueNotifier;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../setup/config.dart';
import '../utils/dialog.dart';

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
      Talk.log('正在使用的凭证：${_config.stompConnectHeaders?['Authorization']}', name: 'Stomp');
      client ??= StompClient(config: _config); // 初始化
      activate(); // 自动连接
    });
  }

  factory CustomStompClient() => _instance;
  static late final CustomStompClient _instance = CustomStompClient._internal();

  void onConnect(StompFrame connectFrame) { // 连接
    isConnected.value = client?.connected ?? false;
    Talk.log('connected', name: 'Stomp');
    /* subscribe('/topic/greetings', (StompFrame frame) {
      Talk.log('/topic/greetings - Received: ${frame.body}', name: 'Stomp');
    });
    sendMessage('/app/hello', 'Hello, STOMP'); */
  }

  Future<void> onBeforeConnect() async { // 连接前
    isConnected.value = client?.connected ?? false;
    Talk.log('Waiting connect...', name: 'Stomp');
    await Future.delayed(const Duration(milliseconds: 200));
    Talk.log('connecting...', name: 'Stomp');
  }

  void onStompError(StompFrame frame) { // 错误
    isConnected.value = client?.connected ?? false;
    Talk.log('error: ${frame.body}', name: 'Stomp');
  }

  void onDisconnect(StompFrame frame) { // 断开连接
    isConnected.value = client?.connected ?? false;
    Talk.log('disconnect', name: 'Stomp');
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
    if (!AppConfig.isProduction) Talk.log('Debug message: $message', name: 'Stomp');
  }
}