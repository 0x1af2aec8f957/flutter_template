import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Example extends StatefulWidget {
  final String title;

  const Example({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Example();
}

class _Example extends /*StatelessWidget*/ State<Example> {
  Future< /*Null*/ String> loadingJson() async {
    return DefaultAssetBundle.of(context).loadString(
        'assets/json/country_code.json'); // rootBundle.loadString('assets/config.json')
  }

  Shader get shader {
    final Size size = Size(350.0, 70.0);

    return LinearGradient(
      colors: <Color>[Colors.blue, Colors.white],
    ).createShader(Rect.fromLTWH(0.0, 0.0, size.width /*size?.width ?? 0*/,
        size.height /*size?.height ?? 0*/));
  }

  void showMaterialDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("提示"),
            content: new Text("无相关路由"),
            actions: <Widget>[
              new TextButton(
                onPressed: () {
                  if (ModalRoute.of(context)!.isCurrent) context.pop();
                },
                child: new Text("确认"),
              ),
              new TextButton(
                onPressed: () {
                  if (ModalRoute.of(context)!.isCurrent) context.pop();
                },
                child: new Text("取消"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        // ListTile 需要
        body: Container(
      // 背景颜色需要
      color: Colors.grey[200],
      child: CustomScrollView(
          physics: new BouncingScrollPhysics(), // 回弹动效
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.width / 2.6,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(widget.title,
                    style: TextStyle(foreground: Paint()..shader = shader)),
                background: Image.asset("assets/images/flutter_background.png",
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid.count(
                //Grid
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
                children: <Widget>[
                  DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0)),
                      child: Icon(Icons.access_alarms)),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0)),
                      child: Icon(Icons.account_circle)),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0)),
                      child: Icon(Icons.add_a_photo)),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0)),
                      child: Icon(Icons.assignment_ind)),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0)),
                      child: Icon(Icons.folder)),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0)),
                      child: Icon(Icons.vpn_lock)),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: /*ListTile.divideTiles(context: context, color: Colors.grey,tiles: */<Widget>[
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('打开H5小程序'),
                        subtitle: Text('需要启动小程序资源下载服务，正确配置serverAddress信息'),
                        trailing: Icon(Icons.chevron_right),
                        // enabled: true,
                        // selected: true,
                        onTap: () => context.push('/smallProgramTest'),
                      ), ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('打开webview'),
                        subtitle: Text('webview示例，不稳定插件'),
                        trailing: Icon(Icons.chevron_right),
                        // enabled: true,
                        // selected: true,
                        onTap: () => context.push('/webview'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('本地JSON文件加载'),
                        subtitle: Text('本地文件加载示例，含异步widget示例'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/loadingJson'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('子路由示例'),
                        subtitle: Text('适用于tab共用路由的场景'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/subRouter'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('表单示例'),
                        subtitle: Text('用户输入信息提交示例'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/formTest'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('图片缓存'),
                        subtitle: Text('图片加载、缓存示例'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/customCachedNetworkImage'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('应用程序目录'),
                        subtitle: Text('应用程序目录示例'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/applicationDir'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('全屏应用'),
                        subtitle: Text('全屏示例'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/fullScreen'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('状态管理provider示例'),
                        subtitle: Text('provider示例-计数器'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context.push('/count'),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('手势识别'),
                        subtitle: Text('手势处理示例'),
                        // trailing: Icon(Icons.chevron_right),
                      ),
                      ListTile(
                        // leading: Image.network("https://avatars3.githubusercontent.com/u/6915570?s=460&v=4"),
                        title: Text('通知事件'),
                        subtitle: Text('全局通知处理'),
                        // trailing: Icon(Icons.chevron_right),
                      ),
                    ],
                  /*).toList()*/);
                },
                childCount: 1,
              ),
            ),
          ]),
    ));
  }
}
