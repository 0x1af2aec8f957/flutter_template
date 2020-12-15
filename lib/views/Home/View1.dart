import 'package:flutter/material.dart';

class View1 extends StatelessWidget{
  final TabController tabController;
  final List<dynamic> tabs;

  const View1({this.tabController, this.tabs});

  @override
  Widget build(BuildContext context) {

    return TabBarView(
      controller: tabController,
      children: tabs.map((e) { //创建3个Tab页
        return Container(
          alignment: Alignment.center,
          child: Text(e, textScaleFactor: 5),
        );
      }).toList(),
    );
  }
}