import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// extension ProcessButton on RawMaterialButton {}
class ProcessButton extends ElevatedButton {
  ProcessButton({
    super.key,
    super.onPressed,
    this.onTap,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    required super.child,
  });

  final Future<void> Function()? onTap;
  bool isLoading = false;

  @override
  VoidCallback? get onPressed {
    if (super.onPressed != null) return super.onPressed!;
    if (onTap == null || isLoading) return null;

    return () {
      // markNeedsBuild();
      isLoading = true;
      onTap?.call().whenComplete(() => WidgetsBinding.instance.addPostFrameCallback((_){
        isLoading = false;
      }));
    };
  }

  @override
  Widget? get child => /* ValueListenableBuilder(valueListenable: isLoading, builder: (_, _isLoading, __) =>  */isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3) : (super.child ?? const SizedBox.shrink())/* ) */;
}