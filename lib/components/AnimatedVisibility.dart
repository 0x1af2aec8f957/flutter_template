import 'package:flutter/material.dart';

class AnimatedVisibility extends StatefulWidget {
  final bool visible;
  final Widget child;
  final Curve curve;
  final Duration duration;
  final alwaysIncludeSemantics;

  AnimatedVisibility({
    Key? super.key,
    this.visible = true,
    required this.child,
    this.curve = Curves.linear,
    required this.duration,
    this.alwaysIncludeSemantics = false
  });

  @override
  _AnimatedVisibility createState() => _AnimatedVisibility();
}

class _AnimatedVisibility extends State<AnimatedVisibility> {
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: ValueKey(isShow),
      opacity: widget.visible ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      alwaysIncludeSemantics: widget.alwaysIncludeSemantics,
      child: Visibility(child: widget.child, visible: widget.visible || isShow),
      onEnd: () {
        if (widget.visible) return;
        setState(() {
          isShow = widget.visible;
        });
      },
    );
  }
}