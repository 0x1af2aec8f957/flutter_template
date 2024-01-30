import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../models/count.dart';
import '../models/global.dart';

final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (context) => GlobalModel()), // 全局的
  ChangeNotifierProvider(create: (context) => CountModel()), // 全局的
/*ChangeNotifierProxyProvider<GlobalModel, CountModel>( // model相互依赖需要使用此处
          create: (context) => CountModel(),
          update: (context, global, count) {
            count.user = global.userInfo;
            return count;
            },
        ),*/
];