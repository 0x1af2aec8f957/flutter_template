import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common.dart';

typedef WebViewCreatedCallback = void Function(WebViewController controller); // 创建 WebView 回调
typedef PageDOMContentChangeCallback = void Function(JavaScriptMessage message); // 页面 DOM 发生变更执行
typedef PageSystemOverlayStyleChange = void Function(Color color, SystemUiOverlayStyle systemOverlayStyle); // 页面 DOM 主题色发生变更执行

class CustomWebView extends StatefulWidget {
  final String? url;
  final WebViewCreatedCallback? onWebViewCreated;

  // 自定义扩展事件，不需要依赖对接WEB才能完成的操作
  final PageDOMContentChangeCallback? onPageDOMContentChangeCallback; // 页面DOM发生变更执行
  final PageSystemOverlayStyleChange? onPageSystemOverlayStyleChange; // DOM主题色发生变更执行

  CustomWebView({
    Key? key,
    this.url,
    this.onWebViewCreated,
    this.onPageDOMContentChangeCallback,
    this.onPageSystemOverlayStyleChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomWebView();
}
class _CustomWebView extends State<CustomWebView> with WidgetsBindingObserver {
  final WebViewController controller = WebViewController.fromPlatformCreationParams(WebViewPlatform.instance is WebKitWebViewPlatform ? WebKitWebViewControllerCreationParams(mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{}, allowsInlineMediaPlayback: true/* 允许自动及内联播放 */) : const PlatformWebViewControllerCreationParams());
  final _picker = ImagePicker();
  bool isLoading = true; // 是否正在加载中

Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    print('AndroidWebViewController.FileSelectorParams.acceptTypes:  ${params.acceptTypes}');
    if (params.acceptTypes.any((type) => type == 'image/*')) {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      // final picker = _picker.ImagePicker();
      // final photo = await picker.pickImage(source: image_picker.ImageSource.camera);

      if (photo == null) {
        return [];
      }

      print('photo.path: ${photo.path}');
      if (photo.path != null) {
        return [Uri.file(photo.path).toString()];
      }

      final imageData = await photo.readAsBytes();
      final decodedImage = image.decodeImage(imageData);
      final scaledImage = image.copyResize(decodedImage!, width: 500);
      // final jpg = image.encodeJpg(scaledImage, quality: 90);
      final png = image.encodePng(scaledImage, level: 9);

      final filePath = (await getTemporaryDirectory()).uri.resolve(
            // './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
            './image_${DateTime.now().microsecondsSinceEpoch}.png',
          );
      final file = await File.fromUri(filePath).create(recursive: true);
      // await file.writeAsBytes(jpg, flush: true);
      await file.writeAsBytes(png, flush: true);

      return [file.uri.toString()];
    }

    return [];
  }

  @override
  void initState() {
    super.initState();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            print('加载进度: $progress'); 
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            controller.runJavaScript(""" // 给 webview 提供监听 DOM 元素变化的能力
                /// DOM变化监听
                var ___observer = new MutationObserver(function(mutationList){
                  if (typeof window._DOMContentChange !== 'undefined') window._DOMContentChange.postMessage(JSON.stringify(mutationList||[]));
                });
                ___observer.observe(document.body, { childList: true, attributes: true, subtree: true });
                window.addEventListener('beforeunload', function(event){ // 用户离开前
                  ___observer.disconnect();
                  // Cancel the event as stated by the standard.
                  event.preventDefault();
                  // Chrome requires returnValue to be set.
                  event.returnValue = '';
                });

                /// DOM主题色监听
                var ___el = Array.from(document.getElementsByTagName('head')).shift().querySelector("[name='theme-color']");
                if (___el !== null && typeof ___el !== 'undefined' && typeof window._SystemOverlayStyleChange !== 'undefined') window._SystemOverlayStyleChange.postMessage(___el.getAttribute('content'));
            """);

            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('onWebResourceError: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('weixin') || request.url.startsWith('alipays') || request.url.startsWith('alipay') || request.url.startsWith('tel') || request.url.startsWith('sms')) { // 需要打开第三方schema协议的app链接
              print('拦截到的url：${request.url}');
              if (await canLaunchUrl(Uri.parse(request.url))) {
                await launchUrl(Uri.parse(request.url));
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel('_DOMContentChange', onMessageReceived: (message) { // DOM 变化
        if (widget.onPageDOMContentChangeCallback != null) widget.onPageDOMContentChangeCallback?.call(message);
      })
      ..addJavaScriptChannel('_SystemOverlayStyleChange', onMessageReceived: (message) { // DOM 主题色变化
        final Color _themeColor = HexColor(message.message);
        final SystemUiOverlayStyle _systemOverlayStyle = _themeColor.computeLuminance() < 0.5 ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
        if (widget.onPageSystemOverlayStyleChange != null) widget.onPageSystemOverlayStyleChange?.call(_themeColor, _systemOverlayStyle);
      })
      /* ..addJavaScriptChannel('test', onMessageReceived: (message) { // 保存域名
        print('收到 test 的消息：${message.message}');
      }) */;

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true); // android debug
      // (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
      (controller.platform as AndroidWebViewController)
        ..setOnShowFileSelector(_androidFilePicker)
        ..setMediaPlaybackRequiresUserGesture(false); // 允许自动播放
    }

    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController)
        ..setInspectable(true) // ios debug
        ..setAllowsBackForwardNavigationGestures(true); // 允许手势返回
    }

    if (widget.url != null) controller.loadRequest(Uri.parse(widget.url!)); // 加载网页地址
    widget.onWebViewCreated?.call(controller);
  }

  @override
  Widget build(BuildContext context) { // 用于构建Widget子树
    return WillPopScope(
      onWillPop: () => controller.canGoBack().then((isCanBack){
          if (isCanBack) controller.goBack();
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();

          return false;
      }),
      child: Scaffold(
        backgroundColor: Colors.white, // CircularProgressIndicator(strokeWidth: 2.5, backgroundColor: color)
        body: SafeArea(
          child: isLoading
            ? Center(child: CircularProgressIndicator())
            : WebViewWidget(
                controller: controller,
                gestureRecognizers: [
                  Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()), // 允许长按复制文本
                ].toSet(),
            ),
        ),
      ),
    );
  }
}
