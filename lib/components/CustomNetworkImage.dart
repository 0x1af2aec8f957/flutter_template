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

  get random => Random().nextDouble() * 100;
  get isValidAbsoluteUrl => url != null && Uri.parse(url!).isAbsolute;

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // 圆角矩形
      borderRadius: BorderRadius.circular(radius ?? 4),
      child: SizedBox(
        width: width,
        child: LayoutBuilder( /// NOTE: 避免使用 IntrinsicWidth 与 IntrinsicHeight，它们的开支非常昂贵，这里得到布局限制信息即可，无需强制限制内部子组件的布局大小。
          builder: (BuildContext _context, BoxConstraints constraints) { // 支持解析传入宽度为 double.infinity 的图片渲染
            final double _width = constraints.biggest.width;
            final String placeholder = "https://picsum.photos/${(_width * 3).toInt()}?random=${random}"; // 随机图片
            return Image.network(
              isValidAbsoluteUrl ? url! : placeholder,
              fit: fit,
              width: _width,
              headers: headers,
              opacity: opacity,
              errorBuilder: errorBuilder,
            );
          }
        ),
      ),
    );
  }
}