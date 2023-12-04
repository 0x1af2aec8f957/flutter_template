import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../utils/dialog.dart';

/// 选择或保存图片组件
/// 选择图片需要权限：https://pub.dev/packages/image_picker
/// 保存图片需要权限：https://pub.dev/packages/image_gallery_saver

enum ActionType {
  Photograph,
  Album,
  Save,
}

class CustomImageActionButton extends StatelessWidget{
  final Widget? actionWidget;
  final GlobalKey? repaintBoundaryKey;
  const CustomImageActionButton({Key? key, this.actionWidget = const Icon(Icons.more_horiz), this.repaintBoundaryKey}) : super(key: key);

  static Future<void> handleOpenMoreSheet(BuildContext context, [GlobalKey? repaintBoundaryKey]) { // 保存图 需要传入的 repaintBoundaryKey 为 `RepaintBoundary(key: key)` 中的 key
    final ImagePicker picker = ImagePicker();
    return Talk.sheetAction<ActionType>(
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ActionType.Photograph),
          child: Text('拍照')
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ActionType.Album),
          child: Text('从手机相册选择')
        ),
        if (repaintBoundaryKey != null) TextButton(
          onPressed: () => Navigator.of(context).pop(ActionType.Save),
          child: Text('保存图片')
        ),
      ],
    ).then((value) {
      if (value == ActionType.Photograph) { // 拍照
        return picker.pickImage(source: ImageSource.camera).then((XFile? image) {
          if (image == null) return;
          return Talk.toast('拍照成功');
        });
      }

      if (value == ActionType.Album) { // 从手机相册选择
        return picker.pickImage(source: ImageSource.gallery).then((XFile? image) {
          if (image == null) return;
          return Talk.toast('相册选择成功');
        });
      }

      if (value == ActionType.Save && repaintBoundaryKey != null) { // 保存图片
        final BuildContext? buildContext = repaintBoundaryKey.currentContext;
        if (buildContext == null) return null;

        return (buildContext.findRenderObject() as RenderRepaintBoundary)
          .toImage()
          .then((image) => image.toByteData(format: ImageByteFormat.png))
          .then((imageBytes) {
            if (imageBytes == null) return null;
            return ImageGallerySaver.saveImage(imageBytes.buffer.asUint8List(), isReturnImagePathOfIOS: true);
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleOpenMoreSheet(context, repaintBoundaryKey),
      child: actionWidget,
    );
  }
}