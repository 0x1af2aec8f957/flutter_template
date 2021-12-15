import 'dart:async';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

/// Jockey协议的Flutter实现，文档地址：https://github.com/tcoulter/jockeyjs
typedef void _CompleteCallback([dynamic data]);
typedef void _JockeyCallback(dynamic data, [_CompleteCallback callback]);

abstract class Jockey{
  static init(WebViewController _controller){
    controller = _controller;
  }

  static Map<String, List<_JockeyCallback>> _javaScriptChannels = {};

  static WebViewController controller;
  static List<JavascriptChannel> get javaScriptMethods {
    final List<JavascriptChannel> _methods = [];

    _javaScriptChannels.forEach((String _name, List<_JockeyCallback> _fn){
      _methods.add(JavascriptChannel(
        name: _name,
        onMessageReceived: (JavascriptMessage message) => _fn.forEach(
                (_fn) => _fn(json.decode(message.message))
        ),
      ));
    });

    return _methods/* .toSet() */;
  }

  static Map<String, dynamic> schemaParse(Uri _url, {isImplement = true}){
    /// _url -> `jockey://${type}/${envelope.id}?${encodeURIComponent(JSON.stringify(envelope))}`;
    // final List<String> _paths = _url.path.split('/');
    final Map<String, dynamic> _queryParameters = json.decode(_url.queryParameters.keys.first);

    final String _type = _queryParameters['type'];
    final int _envelopeId = _queryParameters['id']; // envelopeId用于解决webView的缓存，无其它用处无需处理
    final _payload = _queryParameters['payload']; // 发送过来的数据

    if (isImplement) _javaScriptChannels[_type].forEach((_JockeyCallback fn) => fn(_payload)); // 执行

    return {
      'type': _type,
      'envelopeId': _envelopeId, // 执行了多少次？[index = 0]
      'payload': _payload,
    };
  }

  static void on(String type, {_JockeyCallback callback, _CompleteCallback complete}){
    _javaScriptChannels[type] ??= [];
    _javaScriptChannels[type].add(complete == null ? callback : (dynamic value){callback(value);complete(value);});
  }

  static void off(String type){
    _javaScriptChannels[type]?.clear();
  }

  static Future<String> send(String type,{ Map<String, dynamic> payload, _JockeyCallback complete}){
    return controller?.runJavascript(
      '''
        (function (methods, payload){
          if (methods.length < 1) return false;
          methods.forEach(Function('fn', 'fn(' + JSON.stringify(payload) + ')'));
        })(window.Jockey.listeners['$type'] || [], ${json.encode(payload)})
      '''
    );
  }
}
