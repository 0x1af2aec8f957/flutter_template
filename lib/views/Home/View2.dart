import 'package:flutter/material.dart';

class View2 extends StatelessWidget{

  const View2();

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.center,
      child: Text('TAB2', textScaler: TextScaler.linear(5)),
    );
  }
}