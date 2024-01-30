import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomSliderLess extends StatelessWidget{
  final int value; // 滑动的值
  final Size thumbRect; // 滑块大小
  final BorderRadius thumbRadius; // 滑块圆角
  final BorderRadius trackRadius; // 进度条圆角
  final double trackHeight; // 进度条高度
  final Color activeTrackColor; // 进度条左边的颜色
  final Color inactiveTrackColor; // 进度条右边的颜色
  final Color thumbColor; // 滑块颜色
  final Widget? child; // 滑块上展示的元素

  const CustomSliderLess({
    this.value = 0,
    required this.thumbRect,
    this.thumbRadius = BorderRadius.zero,
    this.trackRadius = BorderRadius.zero,
    this.trackHeight = 5.5,
    this.activeTrackColor = Colors.lightBlue,
    this.inactiveTrackColor = Colors.grey,
    this.thumbColor = Colors.blue,
    this.child
  });

  Offset get thumbOffset => Offset(0, (trackHeight - thumbRect.height) / 2);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: value,
                child: Container(
                  height: trackHeight,
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: trackRadius.topLeft, bottomLeft: trackRadius.bottomLeft),
                      color: activeTrackColor
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 0,
                        top: thumbOffset.dy,
                        child: Container(
                          alignment: Alignment.center,
                          width: thumbRect.width,
                          height: thumbRect.height,
                          decoration: BoxDecoration(
                              borderRadius: thumbRadius,
                              color: thumbColor
                          ),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 100 - value,
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: trackRadius.topRight, bottomRight: trackRadius.bottomRight),
                      color: inactiveTrackColor
                  ),
                ),
              ),
            ],
          ),
        ),
        Container( // FIXME: https://github.com/flutter/flutter/issues/49631#issuecomment-582090992
          height: math.max(trackHeight, thumbRect.height),
          color: Colors.transparent,
        ),
      ],
    );
  }
}
