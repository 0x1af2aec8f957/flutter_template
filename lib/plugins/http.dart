import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../setup/config.dart';
import '../setup/router.dart';
import '../utils/dialog.dart';
import './signer.dart';

// doc: https://github.com/noteScript/dio/blob/master/README-ZH.md

final BaseOptions options = BaseOptions(// 单次请求的配置[Options]，可覆盖这里的基础配置
  baseUrl: 'https://www.example.com', //'"https://www.xx.com", // 请求基地址,可以包含子路径
  connectTimeout: 5000, // 连接服务器超时时间，单位是毫秒
  receiveTimeout: 3000, // 2.x中为接收数据的最长时限
  headers: <String, dynamic>{ // 公用headers，需要异步或者动态获取的值，在拦截器中设置
    'language': AppConfig.local.toString(), // 语言
    'platform': AppConfig.platform, // 平台
  },
  // path: '', // 请求路径，如果 `path` 以 "http(s)"开始, 则 `baseURL` 会被忽略； 否则将会和baseUrl拼接出完整的的url. 已废弃，options有效。
  contentType: Headers.formUrlEncodedContentType, // 请求的Content-Type，默认值是"application/json; charset=utf-8"
  responseType: ResponseType.json, // 期望以那种格式(方式)接受响应数据
  // responseType: ResponseType.plain, // 签名专用
  validateStatus: /*ValidateStatus*/(status) => status == 200,
  extra: <String, dynamic>{
    'signed': false, // 是否签名
    'refresh': true, // 接口是否刷新（缓存需要）
  }, // 自定义字段，可以在 [Interceptor]、[Transformer] 和 [Response] 中取到
  queryParameters: <String, dynamic /*String|Iterable<String>*/ >{ // 共用查询参数(可处理缓存故障！)

  }
);

class MainInterceptors extends InterceptorsWrapper { // 主要的处理拦截器
  final String basePath;

  MainInterceptors({ this.basePath });

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    // print("REQUEST[${options?.method}] => PATH: ${options?.path}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final packageInfo = await AppConfig.packageInfo;

    options.headers.addAll(<String, dynamic>{ // 需要实时更新的headers
      'token': prefs.getString('token'), // 访问凭证
      'version': packageInfo.version, // 版本号
    });

    options.baseUrl += basePath;

    return handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async{
    // print("RESPONSE[${response?.statusCode}] => PATH: ${response?.request?.path}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = response.data;

    switch (data['code']) {
      case 400000: // 去登录
        prefs.remove('token');
        Router.replace('login');
        return handler.reject(DioError(error : data['msg'] ?? '请登录', requestOptions: response.requestOptions), true);
      case 0: // 正常
        response.data = data['data']; // 仅需要业务数据字段
        return handler.next(response);
    /* case '100007': // 账户已经存在
        return super.onError(data['msg'] ?? '账户已经存在'); */
      default:
        return handler.reject(DioError(error: data['msg'] ?? '未知的服务器错误', type: DioErrorType.response, requestOptions: response.requestOptions), true);
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // print("ERROR[${err?.response?.statusCode}] => PATH: ${err?.request?.path}");
    Talk.toast(err.message);
    return handler.reject(err);
  }
}

class CacheInterceptor extends Interceptor { // 接口缓存拦截器
  CacheInterceptor();

  final _cache = Map<Uri, Response>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler){
    bool isCache = true; // 是否缓存

    if (options.data != null) isCache = false; // 请求中包含有数据不可缓存
    // if (options.method == 'POST') isCache = false; // 请求为post不可缓存

    final extra = options.extra;
    final Response response = _cache[options.uri];

    if (extra["refresh"] == true) return handler.next(options); // 接口配置参数为最高优先级

    return isCache ?  /* 提供单独的刷新 */ handler.next(response.requestOptions) : handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler){
    // TODO:必要的缓存才能缓存，非必要需要排除
    _cache[response.requestOptions.uri] = response;
    return handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    print('onError: $err');
    return handler.reject(err);
  }
}

class MainTransformer extends DefaultTransformer { // 主要的转换器,在拦截器之前执行

  @override
  Future<String> transformRequest(RequestOptions options) async { // 请求数据
    if (options.data is Map<String, dynamic>) {
      final extra = options.extra;

      // data只有两种类型：formData或者json
      final data = options.contentType == Headers.formUrlEncodedContentType ? FormData.fromMap(options.data) : json.encode(options.data);

      if (extra['signed'] == true) { // 是否对数据进行签名
        return Crypto(options.uri).encrypt(data: data is String ? data : data.toString());
      }

      return super.transformRequest(options);
    }

    throw DioError(error: "只能处理发送数据为Map类型的数据", requestOptions: options);
  }

  // The [Options] doesn't contain the cookie info. we add the cookie
  // info to [Options.extra], and you can retrieve it in [ResponseInterceptor]
  // and [Response] with `response.request.extra["cookies"]`.
  @override
  Future<dynamic> transformResponse(RequestOptions options, ResponseBody response) async { // 接收数据
    final extra = options.extra;

    if (extra['signed'] == true && options.responseType == ResponseType.plain /* 接口签名必须使用该预期值 */) { // 是否对数据进行解码
      final responseText = super.transformResponse(options, response);
      final responseBody = Crypto(options.uri).decrypt(data: responseText is String ? responseText :responseText.toString());
      return json.decode(responseBody);
    }

    return super.transformResponse(options, response);
  }
}

class Http {
  final Dio _dio = Dio(options);
  String basePath; // 基准路径

  Http({ basePath }){
    this.basePath = basePath;

    _dio.transformer = MainTransformer(); // 数据转换处理
    _dio.interceptors // 拦截器：执行顺序 -> FIFO
      ..add(CacheInterceptor()) // 接口缓存
      ..add(MainInterceptors(basePath: basePath)); // 主要的拦截器
      
    if (!AppConfig.isProduction) _dio.interceptors.add( // debug 模式下运行
        LogInterceptor(responseBody: true, requestHeader: false, responseHeader: false, requestBody: true) // debug模式下打印log
    );
  }

  Dio call() => _dio;
}
