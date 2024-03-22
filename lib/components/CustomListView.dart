import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import './NoData.dart';

typedef Future<List<T>> LoadMoreCallback<T>(int start/* 起始位置从 1 开始，0 表示首次或刷新数据 */, T? startItem/* 起始项, null 表示首次或刷新数据 */); // 加载更多方法回调
typedef Widget _IndexedWidgetBuilder<T>(BuildContext context, T item, int index); // 列表项构建器

/// 上拉加载更多，下拉刷新
class CustomListView<T> extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  final Widget loadingWidget;
  final bool hasRefresh; // 是否有下拉刷新功能
  final LoadMoreCallback<T>? onLoadMoreData;
  final ItemPositionsListener itemPositionsListener;
  final ItemScrollController itemScrollController;
  final ScrollOffsetController scrollOffsetController;
  final ScrollOffsetListener scrollOffsetListener;
  final IndexedWidgetBuilder separatorBuilder;
  final _IndexedWidgetBuilder<T> itemBuilder;
  final int initialScrollIndex;
  final double initialAlignment;
  final Axis scrollDirection;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final int? semanticChildCount;
  final EdgeInsets? padding;
  final bool addSemanticIndexes;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final double? minCacheExtent;

  final ValueNotifier<List<T>> data = ValueNotifier(<T>[]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  late final ValueNotifier<bool> hasMoreData = ValueNotifier(onLoadMoreData != null);

  CustomListView({
    super.key,
    this.reverse = false,
    this.physics = const AlwaysScrollableScrollPhysics()/* 回弹动效（保持任何时候都能滚动 */,
    this.padding,
    this.color,
    this.backgroundColor,
    this.loadingWidget = const CupertinoActivityIndicator()/* ios */, // CircularProgressIndicator()/* android */
    this.hasRefresh = true,
    this.onLoadMoreData,
    this.shrinkWrap = false,
    required this.itemBuilder,
    this.minCacheExtent,
    this.scrollDirection = Axis.vertical,
    this.initialAlignment = 0.0,
    this.initialScrollIndex = 0,
    this.semanticChildCount,
    this.addSemanticIndexes = true,
    this.addRepaintBoundaries = true,
    this.addAutomaticKeepAlives = true,
    List<T> data = const [], // 提供初始化数据（不提供初始化数据会自动执行一次 onLoadMoreData）
    IndexedWidgetBuilder? separatorBuilder,
    ItemScrollController? itemScrollController,
    ScrollOffsetListener? scrollOffsetListener,
    ItemPositionsListener? itemPositionsListener,
    ScrollOffsetController? scrollOffsetController,
  }):
  assert(onLoadMoreData != null || data.isNotEmpty, 'onLoadMoreData 和 data 不能同时为空'),
  assert(hasRefresh || (color == null && backgroundColor == null), 'hasRefresh 为 false 时，color 和 backgroundColor 无效'),
  assert(!hasRefresh || onLoadMoreData != null, 'hasRefresh 为 true 时，onLoadMoreData 不能为空'),
  separatorBuilder = separatorBuilder ?? ((BuildContext context, int index) => SizedBox.shrink()),
  itemScrollController = itemScrollController ?? ItemScrollController(),
  scrollOffsetController = scrollOffsetController ?? ScrollOffsetController(),
  scrollOffsetListener = scrollOffsetListener ?? ScrollOffsetListener.create(),
  itemPositionsListener = itemPositionsListener ?? ItemPositionsListener.create() {
    this.data.value.addAll(data); // 初始化数据
    this.itemPositionsListener.itemPositions.addListener(() { // 监听列表项位置，上拉加载更多
      final Iterable<ItemPosition> positions = this.itemPositionsListener.itemPositions.value;
      final bool isLoadMore = positions.any((position) => position.index == this.data.value.length - 1 && position.itemTrailingEdge > 0); // 判断是否需要加载更多
      if (!isLoadMore) return;
      handleLoadMoreData(); // 加载更多
    });
    /* this.scrollOffsetListener.changes.listen((offset) {
      if (offset == 0) return;
    }); */
    // this.itemScrollController.jumpTo(index: 1);
    // this.scrollOffsetController.animateScroll(offset: 1, duration: Durations.short1);
  }

  Future<void> handleLoadMoreData() { // 上拉加载更多
    if (isLoading.value || !hasMoreData.value) return Future.value();
    isLoading.value = true;
    return onLoadMoreData!(data.value.length, data.value.lastOrNull).then((response) {
      data.value = [...data.value, ...response];
      hasMoreData.value == response.isNotEmpty;
    }).whenComplete(() => isLoading.value = false);
  }

  Future<void> handleRefresh() { // 下拉刷新
    data.value.clear(); // 清空数据，但不通知 UI 更新
    return handleLoadMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final widget = FutureBuilder(
      future: data.value.isEmpty ? handleLoadMoreData() : Future.value(), // 初始化加载数据（仅在没有提供初始 data 时执行）
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return Center(child: CircularProgressIndicator());

        return ValueListenableBuilder(
          valueListenable: data,
          builder: (_, _data, __) {
            return ValueListenableBuilder<bool>(
              valueListenable: hasMoreData,
              builder: (_, _hasMoreData, __) {
                if (_data.isEmpty && !_hasMoreData) return NoData(); // 暂无数据
            
                return ScrollablePositionedList.separated(
                  reverse: reverse,
                  physics: physics,
                  padding: padding,
                  itemCount: _data.length + 1/* loadingWidget 占位 */,
                  shrinkWrap: shrinkWrap,
                  itemBuilder: (BuildContext _context, int index) => index == _data.length ? LoadingWidget : itemBuilder(_context, _data.elementAt(index), index),
                  minCacheExtent: minCacheExtent,
                  scrollDirection: scrollDirection,
                  separatorBuilder: separatorBuilder,
                  initialAlignment: initialAlignment,
                  initialScrollIndex: initialScrollIndex,
                  semanticChildCount: semanticChildCount,
                  addSemanticIndexes: addSemanticIndexes,
                  itemScrollController: itemScrollController,
                  scrollOffsetListener: scrollOffsetListener,
                  addRepaintBoundaries: addRepaintBoundaries,
                  itemPositionsListener: itemPositionsListener,
                  scrollOffsetController: scrollOffsetController,
                  addAutomaticKeepAlives: addAutomaticKeepAlives,
                );
              }
            );
          }
        );
      }
    );

    if (hasRefresh) return RefreshIndicator(
      color: color,
      backgroundColor: backgroundColor,
      onRefresh: handleRefresh, // 下拉刷新
      child: widget,
    );

    return widget;
  }

  Widget get LoadingWidget => ValueListenableBuilder<bool>(
    valueListenable: isLoading,
    builder: (_, _isLoading, __) => _isLoading ? Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: loadingWidget,
    ) : SizedBox.shrink(),
  );
}
