import 'package:flutter/material.dart';

import './CustomNetworkImage.dart';

class Avatar extends StatelessWidget {
  final String? url;
  final double width;
  final double? radius;
  final Animation<double>? opacity;
  final Map<String, String>? headers;
  final Widget errorWidget;

  const Avatar({
    Key? key,
    this.url,
    this.width = 50,
    this.radius,
    this.headers,
    this.opacity,
    this.errorWidget = const Icon(Icons.person),
  }) : super(key: key);

  static Group({
    required List<String> urls,
    double width = 50,
    double radius = 0,
    Map<String, String>? headers,
    Animation<double>? opacity,
    Widget errorWidget = const Icon(Icons.person),
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        children: [
          for (final url in urls) Avatar(
            url: url,
            width: (width - 3) / 2,
            radius: radius,
            headers: headers,
            opacity: opacity,
            errorWidget: errorWidget,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomNetworkImage(
      url: url,
      width: width,
      radius: radius,
      headers: headers,
      opacity: opacity,
      errorWidget: errorWidget,
    );
  }
}