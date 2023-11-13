import '../plugins/http.dart';
import '../interface/test.dart' as model;

final api = Http(basePath: '/api')();

abstract class Test {
  /// 使用示例：
  ///  Test.test.then((r){
  ///  print('api--------\n');
  ///  print(r.runtimeType);
  ///  print(r);
  ///  });
  static Future<model.Test> get test => api.get('/home/banner').then((result) => model.Test.fromJson(result.data));
}
