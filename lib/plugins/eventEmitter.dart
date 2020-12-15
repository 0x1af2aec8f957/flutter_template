import 'package:meta/meta.dart' show immutable;

typedef void _EventCallback(dynamic arg); //订阅者回调签名

@immutable
class _EventBus {
  //私有构造函数
  _EventBus._internal();

  //保存单例
  static _EventBus _singleton = _EventBus._internal();

  //工厂构造函数
  factory _EventBus()=> _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  final _eMap = Map<Object, List<_EventCallback>>();

  //添加订阅者
  void on(eventName, _EventCallback f) {
    if (eventName == null || f == null) return;
    _eMap[eventName] ??= List<_EventCallback>();
    _eMap[eventName].add(f);
  }

  //移除订阅者
  void off(eventName, [_EventCallback f]) {
    var list = _eMap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _eMap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
    var list = _eMap[eventName];
    if (list == null) return;
    list.forEach((callback) => callback(arg));
  }
}

final _EventBus event = _EventBus();
