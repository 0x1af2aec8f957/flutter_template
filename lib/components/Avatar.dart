import 'package:flutter/material.dart';

import './CustomNetworkImage.dart';

class Avatar extends StatelessWidget {
  final String? url;
  final double width;
  final double? radius;
  final Animation<double>? opacity;
  final Map<String, String>? headers;

  const Avatar({
    Key? key,
    this.url,
    this.width = 50,
    this.radius,
    this.headers,
    this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomNetworkImage(
      url: url,
      width: width,
      radius: radius,
      headers: headers,
      opacity: opacity,
      errorWidget: Icon(Icons.person),
    );
  }
}