import 'dart:math' show Random;
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? radius;
  final Widget? errorWidget;
  final Animation<double>? opacity;
  final Map<String, String>? headers;
  final BoxFit fit;

  get errorBuilder => (context, error, stackTrace) => Container( // 图片错误
    width: width,
    child: FittedBox(child: errorWidget ?? Icon(Icons.broken_image_outlined)),
  );

  const CustomNetworkImage({
    Key? key,
    this.url,
    this.width,
    this.radius,
    this.headers,
    this.opacity,
    this.errorWidget,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  get isValidAbsoluteUrl => url != null && Uri.parse(url!).isAbsolute;
  get random => Random().nextDouble() * 100;

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // 圆角矩形
      borderRadius: BorderRadius.circular(radius ?? 4),
      child: LayoutBuilder(
        builder: (BuildContext _context, BoxConstraints constraints) {
          final String placeholder = "https://picsum.photos/${(constraints.biggest.width * 3).toInt()}?random=${random}"; // 随机图像
          return Image.network(
            isValidAbsoluteUrl ? url! : placeholder,
            fit: fit,
            width: width,
            headers: headers,
            opacity: opacity,
            errorBuilder: errorBuilder,
          );
        }
      ),
    );
  }
}