import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 图片缓存

class CustomCachedNetworkImage extends StatelessWidget {
  final String title;

  const CustomCachedNetworkImage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: CachedNetworkImage(
            // color: Colors.grey,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            imageUrl: 'https://i.loli.net/2020/02/06/UsoNuX1FhR6KeVM.png?raw=true',
          ),
        ));
  }
}
