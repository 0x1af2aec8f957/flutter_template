import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dialog.dart';

final _wsUrl = Uri.parse('wss://example.com');

class Socket {
  WebSocket? socket;

  Socket._internal() {
    SharedPreferences.getInstance().then((prefs) => WebSocket.connect(_wsUrl.toString(), headers: {
      "username": "username",
      "Authorization": prefs.getString('token'),
    }).then((_socket) {
      Talk.log('正在使用的凭证：${prefs.getString('token')})', name: 'Socket');
      socket = _socket..listen(onMessage, onDone: onDone, onError: onError);
    }));
  }

  factory Socket() => _instance;

  static late final Socket _instance = Socket._internal();

  onMessage(dynamic message) {
    Talk.log('收到 message : $message', name: 'Socket');
  }

  onDone() {
    Talk.log('Socket done', name: 'Socket');
  }

  onError(error) {
    Talk.log('Socket error: $error', name: 'Socket');
  }

  void sendMessage(String message) {
    Talk.log('发送消息: $message', name: 'Socket');
    socket?.add(message);
  }

  Future<dynamic> close() async {
    Talk.log('Socket close', name: 'Socket');
    return await socket?.close();
  }
}