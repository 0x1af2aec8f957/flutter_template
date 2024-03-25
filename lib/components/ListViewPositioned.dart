import 'package:flutter/material.dart';

typedef void _onTapCallBack(String character, int index);
/// ListView 的任意索引定位器，类似微信联系人右侧的字母列表
class ListViewPositioned<T> extends StatelessWidget {
  final Widget child;
  final List<String> letters;
  final _onTapCallBack? onTap;

  final ValueNotifier<String> activeCharacter = ValueNotifier(''); // 当前选中的索引

  ListViewPositioned({
    super.key,
    required this.child,
    this.onTap,
    List<String> letters = const <String>[],
  }): letters = letters.isEmpty ? List.generate(26, (int index) => String.fromCharCode(index + 97))/* a-z */ : letters;

  void handleClick(int index) {
    activeCharacter.value = letters.elementAt(index);
    return onTap?.call(activeCharacter.value, index);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          child,
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
                  for (int index = 0; index < letters.length; index++) GestureDetector( // 索引
                    child: ValueListenableBuilder(
                      valueListenable: activeCharacter,
                      builder: (_, _activeCharacter, __) => Text(letters.elementAt(index), style: TextStyle(fontWeight: letters.elementAt(index) == _activeCharacter ? FontWeight.bold : FontWeight.normal)),
                    ),
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