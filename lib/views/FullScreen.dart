import 'package:flutter/material.dart';

import '../lang/I18n.dart';

class FullScreen extends StatefulWidget{
  final String title;
  FullScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState()=> _FullScreen();
}

class _FullScreen extends State<FullScreen>{

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: AlignmentDirectional.center,
      color: Colors.yellow /*.withOpacity(1)*/,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
              '${widget.title}',
              style: TextStyle(fontSize: 16, color: Colors.red.withOpacity(0.5), decoration: TextDecoration.none)),
          Text(I18n.$t('home', 'title')),
        ],
      ),
      // transform: Matrix4.rotationZ(0.1),
    );
  }
}
