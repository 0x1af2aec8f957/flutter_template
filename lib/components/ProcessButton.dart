import 'package:flutter/material.dart';

import '../utils/common.dart';

// extension ProcessButton on RawMaterialButton {}
class ProcessButton extends StatelessWidget {
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  final Widget? child;

  ProcessButton({
    super.key,
    this.style,
    this.onPressed,
    this.child = const SizedBox.shrink(),
  });

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  handleClick() {
    if (onPressed == null || isLoading.value) return null;

    isLoading.value = true;
    onPressed?.call().whenComplete(() => isLoading.value = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (_, bool _isLoading, __) {
        return ElevatedButton(
          onPressed: _isLoading ? null : handleClick,
          style: style,
          // 去按钮背景颜色的反色
          child: _isLoading ? CircularProgressIndicator(color: style?.backgroundColor?.resolve({MaterialState.pressed})?.invert, strokeWidth: 3) : child,
        );
      }
    );
  }
}