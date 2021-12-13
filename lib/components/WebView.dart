import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../plugins/jockey.dart';

// NOTE: 使用CookieManager().clearCookies()在外部清理webview的cookie，在iOS设备上直接使用WebView.platform.clearCookies()会引发注册异常导致清理失败
typedef NavigationDecision _NavigationDelegate(NavigationRequest request, Type nextMethodType);

class CustomWebView extends StatelessWidget{
  final String url;
  final bool hasJavaScriptMethods;
  final List<JavascriptChannel> javascriptChannels;
  final _NavigationDelegate navigationDelegate;
  final JavascriptMode javascriptMode;
  final WebViewCreatedCallback onWebViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final PageStartedCallback onPageStarted;
  final PageFinishedCallback onPageFinished;
  final WebResourceErrorCallback onWebResourceError;
  final bool debuggingEnabled;
  final bool gestureNavigationEnabled;
  final String userAgent;
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  const CustomWebView({
    this.url,
    this.hasJavaScriptMethods,
    this.navigationDelegate,
    this.javascriptMode = JavascriptMode.unrestricted,
    this.javascriptChannels,
    this.gestureRecognizers,
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
    this.debuggingEnabled,
    this.gestureNavigationEnabled,
    this.userAgent,
    this.initialMediaPlaybackPolicy,
    this.onWebViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); // android使用混合webview,解决键盘异常问题

    return WebView(
        initialUrl: url, // URL链接
        onWebViewCreated: (WebViewController __controller){
          Jockey.init(__controller); // 初始化WebViewController控制器
          if (onWebViewCreated != null) onWebViewCreated(__controller); // 支持外部使用该钩子
        }, // webView创建完成执行的事件
        javascriptChannels: [
          ...hasJavaScriptMethods ?? false ? Jockey.javaScriptMethods : const <JavascriptChannel>[],
          ...javascriptChannels ?? const <JavascriptChannel>[],
        ].toSet(), // 给javaScript提供的事件列表
        gestureRecognizers: gestureRecognizers,
        javascriptMode: javascriptMode, // 是否支持JavaScript
        navigationDelegate: (NavigationRequest request) { // url劫持、拦截
          // final RegExp isJockeySchema = RegExp(r'^jockey://');
          final isJockey = request.url.startsWith('jockey://');

          if (isJockey) { // jockey协议阻断导航
            Jockey.schemaParse(Uri.parse(request.url)); // jockey协议解析
            return NavigationDecision.prevent;
          }

          if (navigationDelegate != null) { // 交给外部拦截处理
            return navigationDelegate(request, NavigationDecision);
          }

          return  NavigationDecision.navigate;
        },
        onPageStarted: onPageStarted, // 页面开始加载
        onPageFinished: onPageFinished, // 页面加载完成
        onWebResourceError: onWebResourceError, // 页面加载错误
        debuggingEnabled: debuggingEnabled ?? false, // webView debug
        gestureNavigationEnabled: gestureNavigationEnabled ?? true, // 手势导航
        userAgent: userAgent, // 浏览器标识
        initialMediaPlaybackPolicy: initialMediaPlaybackPolicy ?? AutoMediaPlaybackPolicy.require_user_action_for_all_media_types, // 媒体播放策略
      );
  }
}
