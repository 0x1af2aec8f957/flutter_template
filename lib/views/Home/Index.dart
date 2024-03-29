import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './Drawer.dart';
import '../../lang/I18n.dart';
import '../../plugins/dialog.dart';

class Home extends StatefulWidget {
  final String title;
  final Widget child;

  Home({Key? key, required this.title, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> with SingleTickerProviderStateMixin{

  late TabController _tabController; //需要定义一个Controller
  final List tabs = ["视图1", "视图2", "视图3"];

  int get _selectedIndex {
    final String lastPath = GoRouterState.of(context).uri.pathSegments.lastOrNull ?? '';
    return (int.tryParse(lastPath) ?? 1) - 1;
  }

  void _onItemTapped(int index) {
    return context.go('/${index == 0 ? '' : index + 1}');
  }

  @override
  Widget build(BuildContext context) { // 用于构建Widget子树

    /**
        1. 在调用initState()之后。
        2. 在调用didUpdateWidget()之后。
        3. 在调用setState()之后。
        4. 在调用didChangeDependencies()之后。
        5. 在State对象从树中一个位置移除后（会调用deactivate）又重新插入到树的其它位置之后。
     **/

    return Scaffold(
      appBar: AppBar( //导航栏
        elevation: 0,
        title: Text(I18n.$t('common', 'title')),
        actions: <Widget>[ //导航栏右侧菜单
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
      drawer: LeftDrawer(), //抽屉
      bottomNavigationBar: BottomNavigationBar( // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '其它'),
          BottomNavigationBarItem(icon: Icon(Icons.android), label: '其它'),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      body: Container(
        child: Column(children: <Widget>[
          /*Visibility( // 早期的版本不能使用null，需要使用该方法隐藏小部件
            visible: _selectedIndex == 0,
            child: Container(
              color: Colors.blue,
              child: TabBar(   //生成Tab菜单
                  controller: _tabController,
                  tabs: [for (String e in tabs) Tab(text: e)]
              ),
            )
          ),*/
          if (_selectedIndex == 0) Container(
            color: Colors.blue,
            child: TabBar(   //生成Tab菜单
                controller: _tabController,
                tabs: [for (String e in tabs) Tab(text: e)]
            ),
          ),
          Expanded(child: widget.child),
        ],),
      ),
    );
  }

  @override
  void initState() { // 当Widget第一次插入到Widget树时会被调用，对于每一个State对象，Flutter framework只会调用一次该回调
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this); // 创建Controller
    Talk.log('initState', name: 'View.Home');
  }

  @override
  void didUpdateWidget(Home oldWidget) { // 在widget重新构建时调用，Flutter framework会调用Widget.canUpdate来检测Widget树中同一位置的新旧节点，然后决定是否需要更新
    super.didUpdateWidget(oldWidget);
    Talk.log('didUpdateWidget', name: 'View.Home');
  }

  @override
  void deactivate() { // 当State对象从树中被移除时，会调用此回调
    super.deactivate();
    Talk.log('deactive', name: 'View.Home');
  }

  @override
  void dispose() { // 当State对象从树中被永久移除时调用；通常在此回调中释放资源
    Talk.log('dispose', name: 'View.Home');
    _tabController.dispose(); // 资源释放
    super.dispose();
  }

  /*@override
  void reassemble() { // 此回调是专门为了开发调试而提供的，在热重载(hot reload)时会被调用，此回调在Release模式下永远不会被调用
    super.reassemble();
    Test.test.then((r){
      debugPrint('api--------\n');
      debugPrint(r.runtimeType);
      debugPrint(r);
    });
    Talk.toast('Toast测试');
    Talk.log('reassemble', name: 'View.Home');
  }*/

  @override
  void didChangeDependencies() { // 当State对象的依赖发生变化时会被调用
    super.didChangeDependencies();
    Talk.log('didChangeDependencies', name: 'View.Home');
  }
}