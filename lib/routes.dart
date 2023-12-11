import 'package:flutter/material.dart';
// import 'package:fluro/fluro.dart';

import './views/Home/index.dart';
import './views/About.dart';
import './views/Example.dart';
import './views/LoadingJson.dart';
import './views/SubRouter.dart';
import './views/FormTest.dart';
import './views/CustomCachedNetworkImage.dart';
import './views/ApplicationDir.dart';
import './views/FullScreen.dart';
import './views/Count.dart';

final routes = <String, WidgetBuilder>{ //
  '/': (BuildContext context) => Home(title: '首页'),
  'about': (BuildContext context) => About(title: '关于', arg: ModalRoute.of(context)!.settings.arguments as Map<String, String>),
  'example': (BuildContext context) => Example(title: '示例程序'),
  'loadingJson': (BuildContext context) => LoadingJson(title: '加载本地Json文件'),
  'subRouter': (BuildContext context) => SubRouter(title: '子路由示例'),
  'formTest': (BuildContext context) => FormTest(title: '表单示例程序'),
  'customCachedNetworkImage': (BuildContext context) => CustomCachedNetworkImage(title: '图片缓存示例程序'),
  'applicationDir': (BuildContext context) => ApplicationDir(title: '应用目录示例'),
  'fullScreen': (BuildContext context) => FullScreen(title: '全屏应用示例'),
  'count': (BuildContext context) => Count(title: '计数器应用示例'),
};

/*class Routes { // fluro路由管理

  static void configureRoutes(Router router) {

    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
          print("路由地址不存在!!!");
        });
    /// handlerFunc: 第一个参数是路由地址，第二个参数是页面跳转和传参（不支持中文），第三个参数是默认的转场动画
    /// 先不设置默认的转场动画，转场动画可以在另外一个地方设置（可以看NavigatorUtil类）

    routes.forEach((String path, HandlerFunc handlerFunc) => router.define(path, handler: Handler(handlerFunc: handlerFunc)));
  }
}*/
