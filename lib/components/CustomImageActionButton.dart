import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../utils/dialog.dart';

/// 选择或保存图片组件
/// 选择图片需要权限：https://pub.dev/packages/image_picker
/// 保存图片需要权限：https://pub.dev/packages/image_gallery_saver

enum ActionType { // 图片操作类型
  Photograph, // 拍照
  Album, // 从手机相册选择
  Save, // 保存图片到相册
}

class ActionResult { // 图片操作结果
  final ActionType type; // 操作类型
  final String filePath; // 文件路径
  const ActionResult(this.type, this.filePath);
}

class CustomImageActionButton extends StatelessWidget {
  final Widget? actionWidget;
  final GlobalKey? repaintBoundaryKey;
  final void Function(ActionResult imageActionResult)? onCompleted;
  const CustomImageActionButton({Key? key, this.actionWidget = const Icon(Icons.more_horiz), this.repaintBoundaryKey, this.onCompleted}) : super(key: key);

  static Future<String> pickImageByCamera() { // 拍照并选择
    final ImagePicker picker = ImagePicker();
    return picker.pickImage(source: ImageSource.camera).then((XFile? image) {
      if (image == null) return Future.error('文件不存在');
      return image.path;
    });
  }

  static Future<String> pickImageByAlbum() { // 从手机相册选择
    final ImagePicker picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery).then((XFile? image) {
      if (image == null) return Future.error('文件不存在');
      return image.path;
    });
  }

  static Future<String> saveImageByRepaintBoundaryKey(GlobalKey _repaintBoundaryKey) { // 截取 key 为 _repaintBoundaryKey 的 Widget图像，并保存到相册
    final BuildContext? buildContext = _repaintBoundaryKey.currentContext;
    if (buildContext == null) return Future.error('上下文获取失败');

    return (buildContext.findRenderObject() as RenderRepaintBoundary)
      .toImage()
      .then((image) => image.toByteData(format: ImageByteFormat.png))
      .then((imageBytes) {
        if (imageBytes == null) return Future.error('图片数据不存在');
        final result = ImageGallerySaver.saveImage(imageBytes.buffer.asUint8List(), isReturnImagePathOfIOS: true);

        if (result is! Future) return Future.error('保存失败');
        return result.then((value) {
          if (value?['isSuccess'] != true || value?['filePath'] is! String) return Future.error(value?['errorMessage'] ?? '保存失败');
          Talk.toast('保存成功');
          return Uri.parse(value['filePath']).path;
        });
      });
  }

  static Future<ActionResult> handleOpenMoreSheet(BuildContext context, {
    GlobalKey? repaintBoundaryKey, // 保存图 需要传入的 repaintBoundaryKey 为 `RepaintBoundary(key: key)` 中的 key
    bool isOnlyShowSave = false, // 是否仅显示保存图片
  }) {
    assert(repaintBoundaryKey == null || isOnlyShowSave == false);
    return Talk.sheetAction<ActionType>(
      children: [
        if (!isOnlyShowSave) TextButton(
          onPressed: () => Navigator.of(context).pop(ActionType.Photograph),
          child: Text('拍照')
        ),
        if (!isOnlyShowSave) TextButton(
          onPressed: () => Navigator.of(context).pop(ActionType.Album),
          child: Text('从手机相册选择')
        ),
        if (repaintBoundaryKey != null) TextButton(
          onPressed: () => Navigator.of(context).pop(ActionType.Save),
          child: Text('保存图片')
        ),
      ],
    ).then((type) {
      if (type == ActionType.Photograph) return pickImageByCamera().then((result) => ActionResult(type!, result)); // 拍照

      if (type == ActionType.Album) return pickImageByAlbum().then((result) => ActionResult(type!, result)); // 从手机相册选择

      if (type == ActionType.Save && repaintBoundaryKey != null) return saveImageByRepaintBoundaryKey(repaintBoundaryKey).then((result) => ActionResult(type!, result)); // 保存图片

      return Future.error('无法识别当前操作类型');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: actionWidget,
      onTap: () => handleOpenMoreSheet(context, repaintBoundaryKey: repaintBoundaryKey).then((imageActionResult) => onCompleted?.call(imageActionResult)),
    );
  }
}