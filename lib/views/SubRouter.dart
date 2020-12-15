import 'package:flutter/material.dart';

class SubRouter extends StatefulWidget {
  final String title;

  const SubRouter({Key? key, required this.title}) : super(key: key);

  @override
  State<SubRouter> createState() => _SubRouter();
}

class _SubRouter extends State<SubRouter> with SingleTickerProviderStateMixin{
  final List tabs = ['subRouter.page_1', 'subRouter.page_2'];
  TabController? tabController; //需要定义一个Controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title),
        bottom: TabBar(
            //生成Tab菜单
            tabs: tabs.map((tabText) => Tab(text: tabText)).toList(),
            controller: tabController,
        ),
        // centerTitle: true,
      ),
      body: Navigator(
          initialRoute: 'subRouter/page_1',
          onGenerateRoute: (RouteSettings settings) {
            final String? routerName = settings.name;
            WidgetBuilder builder;

            switch (routerName) {
              case 'subRouter/page_1':
                builder = (BuildContext _) => CollectPage1();
                break;
              case 'subRouter/page_2':
                builder = (BuildContext _) => CollectPage2();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }

            return MaterialPageRoute(builder: builder, maintainState: false, settings: settings);
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this)
      ..addListener((){
        if(tabController?.index.toDouble() == tabController?.animation?.value){
          switch (tabController?.index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('subRouter');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('subRouter/page_2');
              break;
            default:
              break;
          }
        }
      });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}

class CollectPage1 extends StatelessWidget {
  // 子界面1
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('这是一个嵌套路由界面page_1')),
    );
  }
}

class CollectPage2 extends StatelessWidget {
  // 子界面2
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('这是一个嵌套路由界面page_2')),
    );
  }
}
