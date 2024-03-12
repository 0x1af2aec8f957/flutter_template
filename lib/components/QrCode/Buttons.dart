import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../CustomImageActionButton.dart';

ButtonStyle get _iconButtonStyle => IconButton.styleFrom(
  backgroundColor: Colors.grey.withOpacity(0.5),
  padding: EdgeInsets.all(12),
);

class StaticButtons extends IconButton {
  final MobileScannerController controller;

  StaticButtons.AnalyzeImageFromGallery({required this.controller}): super( // 识别相册中的二维码
    icon: const Icon(Icons.image),
    onPressed: () => CustomImageActionButton.pickImageByAlbum().then((String _path) => controller.analyzeImage(_path)),
    style: _iconButtonStyle,
    color: Colors.white,
  );

  StaticButtons.StartStopMobileScannerButton({required this.controller}): super( // 开始|停止 扫描
    style: _iconButtonStyle,
    color: Colors.white,
    icon: controller.isStarting ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
    onPressed: controller.isStarting ? controller.stop : controller.start,
  );
}

class ValueListenableButtons extends ValueListenableBuilder {
  final double iconSize;
  final MobileScannerController controller;

  ValueListenableButtons.SwitchCamera({ // 切换相机
    required this.controller,
    this.iconSize = 32,
  }): super(
    valueListenable: controller.cameraFacingState,
    builder: (context, state, child) => IconButton(
      style: _iconButtonStyle,
      iconSize: iconSize,
      color: Colors.white,
      icon: state == CameraFacing.front ? const Icon(Icons.camera_front) : const Icon(Icons.camera_rear),
      onPressed: controller.switchCamera,
    ),
  );

  ValueListenableButtons.ToggleFlashlight({ // 切换闪光灯
    required this.controller,
    this.iconSize = 32,
  }): super(
    valueListenable: controller.torchState,
    builder: (context, state, child) => IconButton(
      style: _iconButtonStyle,
      iconSize: iconSize,
      color: state == TorchState.off ? Colors.white : Colors.yellow,
      icon: state == TorchState.on ? const Icon(Icons.flash_on) : const Icon(Icons.flash_off),
      onPressed: controller.toggleTorch,
    ),
  );
}