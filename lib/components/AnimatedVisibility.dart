import 'package:flutter/material.dart';

class AnimatedVisibility extends StatelessWidget {
  bool isNotBuild = true;

  final bool visible;
  final Widget child;
  final Curve curve;
  final Duration duration;
  final alwaysIncludeSemantics;

  AnimatedVisibility({
    super.key,
    this.visible = true,
    required this.child,
    this.curve = Curves.linear,
    required this.duration,
    this.alwaysIncludeSemantics = false
  });

  @override
  Widget build(BuildContext context) {
    isNotBuild = false;

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration,
      curve: curve,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: FutureBuilder(
        future: Future.delayed(isNotBuild ? Duration.zero : duration),
        builder: (_, snapshot) => Visibility(child: child, visible: snapshot.connectionState != ConnectionState.done || visible),
      ),
    );
  }
}