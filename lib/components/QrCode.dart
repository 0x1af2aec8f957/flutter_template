import 'package:scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import './CustomImageActionButton.dart';

/// 二维码渲染、扫描
/// 二维码扫描需要权限：https://pub.dev/packages/scan#scan

Widget _defaultQrErrorBuilder (BuildContext context, Object? error) => Container( // 二维码错误默认组件
  child: FittedBox(child: Icon(Icons.qr_code, color: Colors.grey[400], semanticLabel: '二维码错误')),
);

class QrCodeView extends QrImageView { // 二维码渲染
  final String data;
  final double? size;
  final EdgeInsets padding;
  final Color backgroundColor;
  final int version;
  final int errorCorrectionLevel;
  final QrErrorBuilder? errorStateBuilder;
  final bool constrainErrorBounds;
  final bool gapless;
  final ImageProvider? embeddedImage;
  final QrEmbeddedImageStyle? embeddedImageStyle;
  final bool embeddedImageEmitsError;
  final String semanticsLabel;
  final QrEyeStyle eyeStyle;
  final QrDataModuleStyle dataModuleStyle;

  QrCodeView({
    Key? key,
    required this.data,
    this.size,
    this.padding = const EdgeInsets.all(10),
    this.backgroundColor = Colors.white,
    this.version = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.H,
    this.errorStateBuilder,
    this.constrainErrorBounds = true,
    this.gapless = true,
    this.embeddedImage = const AssetImage('assets/images/logo.png'),
    this.embeddedImageStyle/*  = const QrEmbeddedImageStyle( // 二维码中间的 logo, 在不设置大小的情况下，会根据二维码的大小自动缩放
      size: Size.square(50),
      color: Colors.transparent,
    ) */,
    this.embeddedImageEmitsError = false,
    this.semanticsLabel = '二维码',
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.black,
    ),
  }) : super(
    key: key,
    data: data,
    size: size,
    padding: padding,
    backgroundColor: backgroundColor,
    version: version,
    errorCorrectionLevel: errorCorrectionLevel,
    errorStateBuilder: errorStateBuilder ?? _defaultQrErrorBuilder,
    constrainErrorBounds: constrainErrorBounds,
    gapless: gapless,
    embeddedImage: embeddedImage,
    embeddedImageStyle: embeddedImageStyle,
    embeddedImageEmitsError: embeddedImageEmitsError,
    semanticsLabel: semanticsLabel,
    eyeStyle: eyeStyle,
    dataModuleStyle: dataModuleStyle,
  );
}

class QrCodeScanView extends ScanView { // 二维码扫描
    static ScanController scanController = ScanController();
    final CaptureCallback? onCapture;
    final Color? scanViewLineColor;
    final double? scanViewAreaScale;

    QrCodeScanView({
      this.onCapture,
      this.scanViewLineColor,
      this.scanViewAreaScale,
    }) : super(
      controller: scanController,
      onCapture: onCapture,
      scanLineColor: scanViewLineColor ?? Colors.green,
      scanAreaScale: scanViewAreaScale ?? 0.7,
    );
}

class QrCodeScanPage extends StatefulWidget {
  final String? title;
  final Color? scanLineColor;
  final double? scanAreaScale;
  final bool Function(String data)? onValidate;

  const QrCodeScanPage({Key? key, this.title, this.onValidate, this.scanLineColor, this.scanAreaScale}) : super(key: key);

  @override
  _QrCodeScanPage createState() => _QrCodeScanPage();
}

class _QrCodeScanPage extends State<QrCodeScanPage> with WidgetsBindingObserver {
  bool isFlash = false; // 是否开启闪光灯

  Icon get FlashIcon => isFlash ? Icon(Icons.flash_off, size: 50, color: Colors.white) : Icon(Icons.flash_on, size: 50, color: Colors.white);
  Icon get AlbumIcon => Icon(Icons.add_photo_alternate, size: 50, color: Colors.white);

  ButtonStyle get iconButtonStyle => IconButton.styleFrom(
    backgroundColor: Colors.grey.withOpacity(0.5),
    padding: EdgeInsets.all(12),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    QrCodeScanView.scanController.resume(); // 恢复扫描
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    QrCodeScanView.scanController.pause(); // 暂停扫描
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // 监听应用生命周期
    if (state == AppLifecycleState.resumed) { // 应用从后台切换到前台
      QrCodeScanView.scanController.resume(); // 恢复扫描
    }

    if (state == AppLifecycleState.paused) { // 应用从前台切换到后台
      QrCodeScanView.scanController.pause(); // 暂停扫描
    }
  }

  void handleCapture (String data) { // 处理扫描结果
    if (widget.onValidate == null) {
      Navigator.pop(context, data);
      return;
    }

    return widget.onValidate!(data) ? Navigator.pop(context, data) : null;
  }

  void handleToggleFlash() { // 打开或关闭闪光灯
    setState(() {
      isFlash = !isFlash;
    });
    return QrCodeScanView.scanController.toggleTorchMode();
  }

  Future<void> handlePickImage() { // 选择图片
    return CustomImageActionButton.pickImageByAlbum()
      .then(Scan.parse)
      .then((result) {
        if (result == null) return;

        return handleCapture(result);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: widget.title == null ? null : Text(widget.title!),
        // actions: [],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            child: QrCodeScanView(
              onCapture: handleCapture,
              scanViewLineColor: widget.scanLineColor,
              scanViewAreaScale: widget.scanAreaScale,
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: FlashIcon,
                  style: iconButtonStyle,
                  onPressed: handleToggleFlash,
                ),
                IconButton(
                  icon: AlbumIcon,
                  style: iconButtonStyle,
                  onPressed: handlePickImage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}