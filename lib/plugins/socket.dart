import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

final _wsUrl = Uri.parse('wss://example.com');

class Socket {
  WebSocket? socket;

  Socket._internal() {
    SharedPreferences.getInstance().then((prefs) => WebSocket.connect(_wsUrl.toString(), headers: {
      "username": "username",
      "Authorization": prefs.getString('token'),
    }).then((_socket) {
      print('Socket 正在使用的凭证：${prefs.getString('token')})');
      socket = _socket..listen(onMessage, onDone: onDone, onError: onError);
    }));
  }

  factory Socket() => _instance;

  static late final Socket _instance = Socket._internal();

  onMessage(dynamic message) {
    print("Socket message: $message");
  }

  onDone() {
    print("Socket done");
  }

  onError(error) {
    print("Socket error: $error");
  }

  void sendMessage(String message) {
    print('Socket sendMessage: $message');
    socket?.add(message);
  }

  Future<dynamic> close() async {
    print('Socket close');
    return await socket?.close();
  }
}