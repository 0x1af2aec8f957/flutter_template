import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/constant.dart' show pagination;

typedef Future<bool> LoadMoreCallback(); // 加载更多方法回调
typedef Widget LoadWidgetCallback(String stateText); // 加载更多组件样式

enum _LoadingMoreState { // 加载状态
  loading, // 正在加载时
  complete, // 加载完成
  fail,	// 加载失败
  noData,	// 没有更多数据了
  hide,	// 隐藏布局
}

mixin _LoadingState<_CustomScrollBar>{
  String filterStateText(_state){
    switch(_state){
      case _LoadingMoreState.complete:
      case _LoadingMoreState.loading:
        return '正在加载...';
      case _LoadingMoreState.fail:
        return '数据加载失败';
      case _LoadingMoreState.noData:
        return '数据加载完毕';
      default:
        return '未知加载状态';
    }
  }
}

class CustomScrollBar extends StatefulWidget {
  final LoadMoreCallback? onLoadMore;
  final RefreshCallback? onRefresh;
  final List<Widget> children;
  final LoadWidgetCallback? loadWidget;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Axis? scrollDirection;
  final bool? reverse;
  final ScrollController? controller;
  final bool? primary;
  final bool shrinkWrap;
  final double? itemExtent;
  final bool? addAutomaticKeepAlives;
  final bool? addRepaintBoundaries;
  final bool? addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior? dragStartBehavior;

  const CustomScrollBar({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    required this.children,
    this.loadWidget,
    this.physics,
    this.padding,
    this.scrollDirection,
    this.reverse,
    this.controller,
    this.primary,
    this.shrinkWrap = false,
    this.itemExtent,
    this.addAutomaticKeepAlives,
    this.addRepaintBoundaries,
    this.addSemanticIndexes,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior,
  });
  
  bool get hasRefresh => onRefresh != null;
  bool get hasLoadMore => onLoadMore != null;

  @override
  State<StatefulWidget> createState() => _CustomScrollBar();
}

class _CustomScrollBar extends State<CustomScrollBar> with _LoadingState {

  final ScrollController controller = new ScrollController();
  _LoadingMoreState loadingStatus = _LoadingMoreState.complete;

  Widget get scrollListView {
    final TextStyle loadWidgetTextStyle = TextStyle(fontSize: 12, color: Color(0xFF8D8D94), fontWeight: FontWeight.w400);

    final List<Widget> listViewChildren = [
      ...widget.children,
      if (loadingStatus != _LoadingMoreState.hide && widget.children.length >= pagination['pageSize']!) Padding(
        child: widget.loadWidget == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(loadingIcon, color: Color(0xFF8D8D94), size: 18,),
                  Padding(padding: EdgeInsets.only(left: 5), child: Text(loadingText, textAlign: TextAlign.center, style: loadWidgetTextStyle)),
                ])
            : widget.loadWidget!(loadingText),
        padding: EdgeInsets.only(top: 10.5, bottom: 3.3),
      )
    ];

    return ListView(
      physics: widget.physics ?? AlwaysScrollableScrollPhysics(), // 回弹动效（保持任何时候都能滚动）
      shrinkWrap: widget.shrinkWrap,
      children: listViewChildren,
      controller: controller,
      padding: widget.padding,
    );
  }

  String get loadingText => filterStateText(loadingStatus);
  IconData get loadingIcon{
    switch (loadingStatus){
      case _LoadingMoreState.complete:
      case _LoadingMoreState.loading:
        return Icons.data_usage;
      case _LoadingMoreState.fail:
        return Icons.error_outline;
      case _LoadingMoreState.noData:
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;

    }
  }

  @override
  Widget build(BuildContext context) {

    return widget.hasRefresh ? RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: Colors.deepOrange,
        child: scrollListView
    ) : scrollListView;
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels < controller.position.maxScrollExtent) { // TODO:解决公用该组件时，noData状态不可逆转
        setState(() {
          loadingStatus = _LoadingMoreState.complete;
        });
      }

      if (controller.position.pixels == controller.position.maxScrollExtent && loadingStatus == _LoadingMoreState.complete && widget.hasLoadMore) {
        setState(() {
          loadingStatus = _LoadingMoreState.loading;
        });

        Future.microtask((){
          widget.onLoadMore!().then((_isMoreData){
            setState(() {
              loadingStatus = _isMoreData ? _LoadingMoreState.complete : _LoadingMoreState.noData;
            });
          }).catchError((error){
            setState(() {
              loadingStatus = _LoadingMoreState.fail;
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用controller.dispose
    controller.dispose();
    super.dispose();
  }
}
