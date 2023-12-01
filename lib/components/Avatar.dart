import 'dart:math' show Random;
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? url;
  final double width;
  final double radius;

  const Avatar({
    Key? key,
    this.url,
    this.width = 50,
    this.radius = 4,
  }) : super(key: key);

  get random => Random().nextDouble() * 100;

  get placeholder => "https://picsum.photos/${(width * 3).toInt()}?random=${random}";

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // 圆角矩形
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url ?? placeholder,
        width: width,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: width),
      ),
    );
  }
}