import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../plugins/jockey.dart';

// NOTE: 使用CookieManager().clearCookies()在外部清理webview的cookie，在iOS设备上直接使用WebView.platform.clearCookies()会引发注册异常导致清理失败
typedef NavigationDecision _NavigationDelegate(NavigationRequest request, Type nextMethodType);
typedef PageDOMContentChangeCallback = void Function(JavascriptMessage message);

class CustomWebView extends StatefulWidget{
  final String url;
  final bool hasJavaScriptMethods;
  final List<JavascriptChannel> javascriptChannels;
  final _NavigationDelegate navigationDelegate;
  final JavascriptMode javascriptMode;
  final WebViewCreatedCallback onWebViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final PageStartedCallback onPageStarted;
  final PageLoadingCallback onProgress;
  final PageFinishedCallback onPageFinished;
  final WebResourceErrorCallback onWebResourceError;
  final bool debuggingEnabled;
  final bool gestureNavigationEnabled;
  final String userAgent;
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  final PageDOMContentChangeCallback onPageDOMContentChangeCallback; // 页面DOM发生变更执行

  const CustomWebView({
    Key key,
    this.url,
    this.hasJavaScriptMethods,
    this.navigationDelegate,
    this.javascriptMode = JavascriptMode.unrestricted,
    this.javascriptChannels,
    this.gestureRecognizers,
    this.onPageStarted,
    this.onProgress,
    this.onPageFinished,
    this.onWebResourceError,
    this.debuggingEnabled,
    this.gestureNavigationEnabled,
    this.userAgent,
    this.initialMediaPlaybackPolicy,
    this.onWebViewCreated,

    this.onPageDOMContentChangeCallback,
  }): super(key: key);


  @override
  State<CustomWebView> createState() => _CustomWebView();
}

class _CustomWebView extends State<CustomWebView>{
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); // android 使用混合webview 解决键盘异常问题

    return WebView(
        initialUrl: widget.url, // URL链接
        onWebViewCreated: (WebViewController __controller) { // webView创建完成执行的事件
          setState(() {
             _controller = __controller; // 保存 WebViewController
           });

          Jockey.init(__controller); // 初始化WebViewController控制器
          if (widget.onWebViewCreated != null) widget.onWebViewCreated(__controller); // 支持外部使用该钩子
        },
        javascriptChannels: [ // 给javaScript提供的事件列表
          ...widget.hasJavaScriptMethods ?? false ? Jockey.javaScriptMethods : const <JavascriptChannel>[],
          ...widget.javascriptChannels ?? const <JavascriptChannel>[],
          /// 给 webview 提供额外的私有事件（或私有api）, 与flutter的互动会放在 WebView.onPageFinished 中完成
          JavascriptChannel(
              name: '_DOMContentChange', // html-dom发生变化
              onMessageReceived: (JavascriptMessage message){
                if (widget.onPageDOMContentChangeCallback != null) widget.onPageDOMContentChangeCallback(message);
              }
          )
        ].toSet(),
        gestureRecognizers: widget.gestureRecognizers,
        javascriptMode: widget.javascriptMode, // 是否支持JavaScript
        navigationDelegate: (NavigationRequest request) { // url劫持、拦截
          // final RegExp isJockeySchema = RegExp(r'^jockey://');
          final isJockey = request.url.startsWith('jockey://');

          if (isJockey) { // jockey协议阻断导航
            Jockey.schemaParse(Uri.parse(request.url)); // jockey协议解析
            return NavigationDecision.prevent;
          }

          if (widget.navigationDelegate != null) { // 交给外部拦截处理
            return widget.navigationDelegate(request, NavigationDecision);
          }

          return  NavigationDecision.navigate;
        },
        onPageStarted: widget.onPageStarted, // 页面开始加载
        onProgress: widget.onProgress, // 页面加载中
        onPageFinished: (String _url) { // 页面加载完成 
          _controller.runJavascript(""" // 给 webview 提供监听 DOM 元素变化的能力
              const ___observer = new MutationObserver(function(mutationList){
                if (typeof window._DOMContentChange !== 'undefined') window._DOMContentChange.postMessage(JSON.stringify(mutationList||[]));
              });
              ___observer.observe(document.body, { childList: true, attributes: true, subtree: true });
              window.addEventListener('beforeunload', function(event){
                ___observer.disconnect();
                // Cancel the event as stated by the standard.
                event.preventDefault();
                // Chrome requires returnValue to be set.
                event.returnValue = '';
              });
          """);

          if (widget.onPageFinished != null) widget.onPageFinished(_url);
        },
        onWebResourceError: widget.onWebResourceError, // 页面加载错误
        debuggingEnabled: widget.debuggingEnabled ?? false, // webView debug
        gestureNavigationEnabled: widget.gestureNavigationEnabled ?? true, // 手势导航
        userAgent: widget.userAgent, // 浏览器标识
        initialMediaPlaybackPolicy: widget.initialMediaPlaybackPolicy ?? AutoMediaPlaybackPolicy.require_user_action_for_all_media_types, // 媒体播放策略
      );
  }
}
