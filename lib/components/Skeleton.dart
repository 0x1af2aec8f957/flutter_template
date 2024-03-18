import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

/// 骨架加载
class Skeleton<T> extends StatelessWidget {
  final Future<T> future;
  final Color baseColor;
  final Color highlightColor;
  final ShimmerDirection direction;
  final Widget Function(BuildContext, T?) builder;

  const Skeleton({
    Key? super.key,
    required this.future,
    required this.baseColor,
    required this.highlightColor,
    this.direction = ShimmerDirection.ltr,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done ? builder(context, snapshot.data) : Shimmer.fromColors(
          // enabled: snapshot.connectionState != ConnectionState.done,
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: builder(context, snapshot.data),
        ),
      );
  }
}