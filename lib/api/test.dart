import 'package:meta/meta.dart';
import '../plugins/http.dart';

final api = Http(basePath: '/api')();

@immutable
abstract class Test {
  /// 使用示例：
  ///  Test.test.then((r){
  ///  print('api--------\n');
  ///  print(r.runtimeType);
  ///  print(r);
  ///  });
  static Future get test => api.get('/home/banner').then((r) => r.data);
}
