import 'dart:io';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomWebView extends StatefulWidget {
  final String url;

  CustomWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomWebView();
}
class _CustomWebView extends State<CustomWebView> with WidgetsBindingObserver {
  DateTime? lastPopTime; // 上次点击返回键的时间
  bool isLoading = true; // 是否正在加载中
  final WebViewController controller = WebViewController(
    WebViewPlatform.instance is WebKitWebViewPlatform ? WebKitWebViewControllerCreationParams(mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{}, allowsInlineMediaPlayback: true/* 允许自动及内联播放 */) : const PlatformWebViewControllerCreationParams()
  );
  final _picker = ImagePicker();

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
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // setState(() {
            //   isLoadFail = true;
            // });
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
      ..loadRequest(Uri.parse(widget.url))
      ..addJavaScriptChannel('test', onMessageReceived: (message) { // 保存域名
        print('收到 test 的消息：${message.message}');
      });

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
                // 允许长按复制文本
                gestureRecognizers: [
                  Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
                ].toSet(),
            ),
        ),
      ),
    );
  }
}
