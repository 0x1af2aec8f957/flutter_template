import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodCall;
// import 'package:fluro/fluro.dart';

import '../setup/config.dart';
import '../utils/common.dart' show methodChannel;
import '../lang/i18n.dart';
import '../routes.dart';

// typedef RedirectMethod = CustomRouteInformation Function (CustomRouteInformation to); // 重定向时目标路由的配置信息
// 路由寻找规则：routes -> onGenerateRoute -> onUnknownRoute -> throw error

final _navigatorKey = AppConfig.navigatorKey;
final router = _Router.of(_navigatorKey.currentState!);

class RouterObserver extends NavigatorObserver {
  // 对路由的鉴权拦截，可在此处理[官方路由表不可使用onGenerateRoute钩子]

  RouterObserver(){
    methodChannel.setMethodCallHandler((MethodCall call) { // 为原生提供界面控制
      final String method = call.method;
      final Map arguments = call.arguments;
      final String name = arguments['name']; // 页面
      final dynamic _arguments = arguments['arguments']; // 参数

      switch (method) {
      // 路由方法
        case "routerPush":
          return router.push(name, _arguments);
        case 'routerReplace':
          return router.replace(name, _arguments);
        case 'routerPop':
          try{
            router.pop(_arguments);
            return Future.value(true);
          }catch(e){
            return Future.value(false);
          }
        case 'pushAndRemoveUntil':
          return Future.value(router.pushAndRemoveUntil(name, arguments['withName'], _arguments));
      //  设置参数方法
        case 'setLocale':
          try {
            final _locale = (_arguments as Map);
            I18n.setLanguage(Locale(_locale['languageCode'], _locale['countryCode']));
            return Future.value(true);
          }catch(e) { // 1af2aec8f957
            return Future.value(false);
          }
      //  获取参数方法
        default:
          return Future.value(I18n.$t('common', 'customErrorMessages[1]'));
      }
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    // 对应的push方法
    // 当调用Navigator.push时回调
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // 对应的pop方法
    super.didPop(route, previousRoute);
    print('this is pop method, ${route.settings.name}');
  }
}

/// 在模板1.5版本中的Router已被官方实现，但没有context用于应用外的跳转，这里主要针对应用外的场景进行二次封装
class _Router { // 外部路由跳转
  final NavigatorState _state;

  const _Router(this._state);

  static _Router of([NavigatorState? state]) { // 传不同的state进来管理不同的路由组（仅适配 Navigator2.0以上场景）
    final NavigatorState scope = state ?? _navigatorKey.currentState!;
    return _Router(scope);
  }

  Future<T?> push<T>(String routeName, [Object? arguments]) {
    return _state.pushNamed<T>(routeName, arguments: arguments ?? {});
  }

  Future<T?> nativePush<T>(String routeName, [Object? arguments]) { // 向原生跳转
    return methodChannel.invokeMethod<T>('routerPush', <String, dynamic> {'name': routeName, 'arguments': arguments});
  }

  Future<T?> replace<T>(String routeName, [Object? arguments, Object? result]){
    return _state.pushReplacementNamed<T, Object>(routeName, arguments: arguments ?? {}, result: result);
  }

  Future<T?> nativeReplace<T>(String routeName, [Object? arguments, Object? result]){ // 向原生跳转
    return methodChannel.invokeMethod<T>('routerReplace', <String, dynamic> {'name': routeName, 'arguments': arguments ?? result});
  }

  void pop<T>([Object? result]){
    return _state.pop<T>(result as T?);
  }

  Future nativePop<T>([Object? result]){ // 向原生返回
    return methodChannel.invokeMethod<T>('routerPop', <String, dynamic> {'arguments': result});
  }

  Future<T?> pushAndRemoveUntil<T>(String routeName, [String? withName, Object? arguments]){
    return _state.pushNamedAndRemoveUntil<T>(routeName, withName == null ? (Route<dynamic> route) => false : ModalRoute.withName(withName), arguments: arguments ?? {});
  }

  Future<T?> nativePushAndRemoveUntil<T>(String routeName, [String? withName, Object? arguments]){ // 跳转并删除原生前路由
    return methodChannel.invokeMethod<T>('pushAndRemoveUntil', <String, dynamic> {'name': routeName, 'arguments': <String, dynamic>{'withName': withName, 'arguments': arguments}});
  }

  Future<T?> navigatorPop<T>() async{ // 关闭flutter实例
    return methodChannel.invokeMethod<T>('navigatorPop').then((r) => pushAndRemoveUntil<T>('transform'));
  }
}

/*
// 自定义路由页面控制器
class CustomPage<T> extends Page<T> { // 自定义路由页面实现
  final Widget child;

  CustomPage({
    LocalKey key,
    this.child
  }) : super(key: key);

  @override
  @factory
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      maintainState: false,
      builder: (BuildContext context) {
        return child;
      },
    );
  }
}
*/

/// 路由代理，对路由的鉴权拦截，可在此处理[官方路由表不可使用onGenerateRoute钩子]
class CustomRouteDelegate extends RouterDelegate<String> with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  final List<String> _stack = []; // 路由栈堆(活动栈堆)
  CustomRouteDelegate(){ // 在这里处理Flutter路由及渲染错误
    if (AppConfig.isProduction){ // 在生产环境，将覆盖 ErrorWidget 向屏幕输出错误的信息
      ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 1,
            title: Text('Program exception'),
            centerTitle: true,
          ),
          body: Center(
              child: Text('Please exit and open again')
          ));
    }
  }

  static CustomRouteDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is CustomRouteDelegate, 'Delegate类型必须匹配');
    return delegate as CustomRouteDelegate;
  }

  /*MaterialPage<dynamic> _convertPage(CustomRouteInformation route) => MaterialPage( // 将CustomRouteInformation配置转换为MaterialPage
    key: ValueKey<String>(route.name),
    name: route.path,
    arguments: route.arguments,
    child: Builder(builder: (BuildContext context) => route.builder(context)),
  );*/

  void push(String newPage) { // push方法
    _stack.add(newPage);
    notifyListeners();
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) { // 当决定弹出时，一定要更新Pages，即也把Pages的最后一个Page(也就是栈顶的Page)移除，否则Flutter在弹出栈顶Page后发现栈内页面与Navigator的pages不符合，还会根据Navigator的pages重新生成路由，这样pop相当于无效了。
    if (_stack.isNotEmpty && _stack.last == route.settings.name) _stack.remove(route.settings);
    notifyListeners();
    return route.didPop(result);
  }

  void pop() {
    if (_stack.isNotEmpty) {
      _stack.remove(_stack.last);
    }
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  String? get currentConfiguration => _stack.isNotEmpty ? _stack.last : null; // 获取当前配置的路由（每个获取路由栈堆的地方都会调用）

  /*
  @override
  Future<void> setInitialRoutePath(String configuration) { // 应用中调用setInitialRoutePath方法会触发setInitialRoutePath
    return setNewRoutePath(configuration);
  }
  */

  /*Route<dynamic> _generateRoute(RouteSettings settings) { // 提供url形式的路由传参
    final Uri routeObject = Uri.parse(settings.name); // 解析URL
    final String routeName = routeObject.path; // 路由路径

    final arguments = CustomMaterialPageArguments( // 添加url参数
        queryParameters: routeObject.queryParameters,
        fragment: routeObject.fragment,
        arguments: settings.arguments
    );

    final RouteSettings _settings = settings.copyWith(name: routeName, arguments: arguments);
    final String _name = _settings.name;

    final targetRoute = routes.firstWhere((CustomRouteInformation route) => [ // 查找目标匹配路由
      route.path,
      route.alias,
      if (route.redirect != null) route.redirect(settings).path
    ].contains(_name), orElse: () => null);
    if(targetRoute == null) return null; // 调用unknownRoute钩子继续查找

    return MaterialPageRoute(
      builder: targetRoute.builder,
      maintainState: false,
      settings: _settings,
    );
  }*/

  Route<dynamic>? _generateRoute(RouteSettings settings) { // 提供url形式的路由传参
    final Uri routeObject = Uri.parse(settings.name!);
    final String name = routeObject.path;
    final Map<String, dynamic> arguments = Map();
    final _arguments = settings.arguments;

    arguments.addAll(routeObject.queryParameters); // 添加url参数
    if (_arguments != null) arguments['arguments'] = _arguments; // 添加flutter路由的参数
    final RouteSettings _settings = RouteSettings(name: name, arguments: arguments);
    final String? _name = _settings.name;

    if(!routes.containsKey(_name)) return null;
    return MaterialPageRoute(
        builder: routes[_name]!,
        settings: _settings,
        maintainState: true // 影响路由的push、pop等操作，开启时将在内存中维护路由状态，关闭时将只保留路由中第一个和最后一个页面的状态，这会导致执行pop操作时父级页面会始终刷新(在future的回调中context将不可用会发生变更)
    );
  }

  Route<dynamic> _unknownRoute(RouteSettings settings){ // 404
    return MaterialPageRoute<void>(
      settings: settings,
      // settings: settings.copyWith(arguments: CustomMaterialPageArguments(arguments: settings.arguments)),
      maintainState: false,
      builder: (BuildContext context) => Scaffold(body: Center(child: Text('Not Found'))),
    );
  }

  /*
  @override
  Future<void> setInitialRoutePath(String configuration) { // 设置初始路由地址
    return setNewRoutePath(configuration);
  }
  */

  @override
  Future<void> setNewRoutePath(String configuration) { // routeNameProvider 系统出发打开新路由页面的通知时，直接调用 setNewRoutePath 方法，参数就是由 <RouteInformationParser<T>>routeNameParser 解析的结果
    _stack
      ..clear()
      ..add(configuration);
    return SynchronousFuture<void>(null);
  }

  /*
  @override
  Future<bool> popRoute() { // 路由回退时会调用, 混入的 PopNavigatorRouterDelegateMixin<T> 已实现
    final NavigatorState? navigator = navigatorKey?.currentState;
    if (navigator == null) return SynchronousFuture<bool>(false);
    return navigator.maybePop();
  }
  */

  @override
  Widget build(BuildContext context) {
    // 匹配规则：onGenerateRoute -> onUnknownRoute -> throw error（routes在这里没有开放该API）
    return Navigator( // MaterialApp.router() 会使 Navigator 成为 Router 的子组件
      key: AppConfig.navigatorKey, // 应用外部使用路由跳转
      /* FIXME 无法正常生效，只能借助onGenerateRoute来处理
      pages: <Page<dynamic>>[ // 路由当前维护的栈堆, 为空时将会始终走generateRoute的逻辑
        // for (CustomRouteInformation route in routes) _convertPage(route)
      ],
      */
      onPopPage: _onPopPage,
      onGenerateRoute: _generateRoute, // routes未找到的情况下会进入这里处理, 已提供url形式的路由传参
      onUnknownRoute: _unknownRoute, // 未知路由处理
      observers: <NavigatorObserver>[RouterObserver()], // 路由动作监听
      initialRoute: WidgetsBinding.instance.platformDispatcher.defaultRouteName, // 提供外部原生控制，home的默认值为'/'
    );
  }
}

/// 路由元数据结构体信息的解码和编码, 在 CustomRouteDelegate 中接收使用
class CustomInformationRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(Uri.decodeComponent(routeInformation.uri.toString()));
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration));
  }
}
