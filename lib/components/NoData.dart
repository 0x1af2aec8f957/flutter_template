import 'package:flutter/material.dart';

class NoData extends StatelessWidget{
  final bool isImage;
  const NoData({
    this.isImage = false,
  });

  @override
  Widget build(BuildContext context) {
    // rootBundle.loadString(filePath)
    final Color _color = Color(0XFF8D8D94);

    return FractionallySizedBox(
      alignment: Alignment.center,
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: isImage ? Image.asset(
        'assets/images/no_data.png',
        width: 57.0,
        height: 67.0,
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.description, color: _color, size: 17),
          Padding(padding: EdgeInsets.only(left: 5), child: Text('暂无相关数据', style: TextStyle(fontSize: 12, color: _color))),
        ],
      ),
    );
  }
}