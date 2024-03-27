import 'package:flutter/material.dart';

typedef void _onTapCallBack(String character, int index);
/// ListView 的任意索引定位器，类似微信联系人右侧的字母列表
class ListViewPositioned extends StatefulWidget {
  final Widget child;
  final List<String> letters;
  final _onTapCallBack? onTap;

  ListViewPositioned({
    super.key,
    required this.child,
    this.onTap,
    List<String> letters = const <String>[],
  }): letters = letters.isEmpty ? List.generate(26, (int index) => String.fromCharCode(index + 97))/* a-z */ : letters;

  @override
  State<ListViewPositioned> createState() => _ListViewPositioned();
}

class _ListViewPositioned extends State<ListViewPositioned> {
  String? activeCharacter;
  void handleClick(int index) {
    if (activeCharacter == widget.letters.elementAt(index)) return;

    setState(() {
      activeCharacter = widget.letters.elementAt(index);
    });
    return widget.onTap?.call(activeCharacter!, index);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          widget.child,
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            // height: double.infinity,
            child: FittedBox( // 超出布局，缩放展示
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int index = 0; index < widget.letters.length; index++) GestureDetector( // 索引
                    child: Text(widget.letters.elementAt(index), style: TextStyle(fontWeight: widget.letters.elementAt(index) == activeCharacter ? FontWeight.bold : FontWeight.normal)),
                    onTap: () => handleClick(index),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}