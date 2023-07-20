/// H5小程序
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as router;
import 'package:shelf_static/shelf_static.dart'; // shelf静态文件中间件
import 'package:shelf_proxy/shelf_proxy.dart'; // shelf代理中间件

import '../../utils/dialog.dart';

final _http = Dio()
  ..interceptors.add( // 打印api请求log
    LogInterceptor(responseBody: true, requestHeader: true, responseHeader: false, requestBody: true)
  )
;
class SmallProgram { // isolate 启动参数
  Uri _remoteZipFileAddress; // 远程资源包地址
  final String name; // 小程序名称
  final Uri serverAddress; // 小程序服务器地址（远程服务器提供 api 的地址）
  final int port; // 小程序启动使用的端口
  final bool hasLocalBundle; // 是否有本地资源包
  Future<bool> get isStaticAssetsValid async => File(path.join((await staticAssetsDirectory).path, 'index.html')).existsSync(); // 小程序静态资源是否有效，必须要包含一个入口文件：index.html
  final Future<bool> Function(File localZipFile, void Function(Uri url) updateRemoteZipFileAddress) shouldUpdate; // 是否需要更新, NOTE: 如果需要更新，则必需要调用 updateRemoteZipFileAddress 方法更新远程资源包地址
  Future<Directory> get applicationDirectory => getApplicationDocumentsDirectory(); // 应用程序包目录(沙盒目录，读写无需单独的权限申请)，该文件夹一定存在
  Future<Directory> get downloadsDirectory => applicationDirectory.then((_dir) { // 小程序下载目录
    final dir = Directory(path.join(_dir.path, 'downloads')); // 下载目录
    print('远程ZIP资源包下载目录：${dir.path}');
    if (!dir.existsSync()) dir.createSync(recursive: true); // 如果下载目录不存在，则创建
    return dir;
  });

  Future<File> get localZipFile async { // 小程序压缩包文件(如果本地文件不存在，指定目录文件也不存在，该文件也会不存在)
    final dir = await downloadsDirectory;
    final file = File(path.join(dir.path, '${name}.zip')); // 本地存储的下载文件
    print('小程序ZIP资源包存放路径：${file.path}');
    if (file.existsSync()) return file; // 如果文件存在，则直接返回

    if (hasLocalBundle) { // 如果有本地资源包，则将资源包写入小程序下载目录指定文件
      final _file = await rootBundle.load('assets/${name}.zip'); // 本地资源包
      print('未找到资源包，正在将本地资源包写入到：${file.path}');
      file
        ..create(recursive: true) // 如果文件不存在，则创建
        ..writeAsBytesSync(_file.buffer.asUint8List()); // 将资源包写入文件
    }

    return file;
  }

  Future<Directory> get staticAssetsDirectory => applicationDirectory.then((_dir) { // 小程序静态资源目录
    final dir = Directory(path.join(_dir.path, 'www', name)); // 静态资源目录
    print('小程序资源存放目录：${dir.path}');
    if (!dir.existsSync()) dir.createSync(recursive: true); // 如果静态资源目录不存在，则创建
    return dir;
  });

  SmallProgram(this.name, {
    @required this.serverAddress,
    this.port = 8089,
    @required this.shouldUpdate,
    this.hasLocalBundle = false,
  });

  Future<void> handleDecompression([isRemoveOldDir = true]) async {
    final targetFile = await localZipFile;
    if (!targetFile.existsSync()) return; // 如果文件不存在，停止继续执行

    final targetDir = await staticAssetsDirectory;
    final Archive archive = ZipDecoder().decodeBytes(targetFile.readAsBytesSync());

    if (isRemoveOldDir && targetDir.existsSync()) targetDir.deleteSync(recursive: true); // 如果需要删除原有的目录，则删除

    print('解压资源存放路径: ${targetDir.path}');
    return archive.forEach((ArchiveFile _file) { // 将Zip存档的内容解压到磁盘。
      print('解压文件详细信息: $_file');
      if (_file.isFile) { // 如果是文件
        File(path.join(targetDir.path, '..', _file.name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(_file.content as List<int>);
        return;
      }

      // 如果是目录
      Directory(path.join(targetDir.path, '..', _file.name))
        ..createSync(recursive: true);
    });
  }

  Future<void> updateLocalZipFile([bool isDecompress = true]) async {
    if (_remoteZipFileAddress == null) return; // 如果没有远程资源包地址，则停止继续执行
    void Function(void Function()) updateSnackBar; // 弹框 UI 更新函数
    int _progress = 0; // 下载进度

    final dir = await downloadsDirectory;
    final file = await localZipFile;
    final tmpFile = File(path.join(dir.path, '${name}.tmp.zip')); // 临时文件

    
    final snackToast = ScaffoldMessenger.of(globalContext).showSnackBar(SnackBar(content: StatefulBuilder(builder: (_context, _setState){ // 更新提示信息
      updateSnackBar = _setState;
      return Text('正在下载更新包：${_progress}%');
    },), duration: Duration(days: 1)));

    await _http.downloadUri(_remoteZipFileAddress, tmpFile.path, onReceiveProgress: (int _count, int _total) { // 下载更新资源包
      print('正在下载更新包：$_count/$_total');
      updateSnackBar((){ // 更新 UI
        _progress = _total > 0 ? (_count / _total * 100).toInt() : 0;
      });
    })
    .whenComplete(snackToast.close) // 下载完成后关闭提示信息
    .catchError((error){
      print('下载更新包失败：$error');
      Talk.alert('下载更新包失败');
    });

    print('下载完成，下载资源包保存在：${tmpFile.path}');
    print('正在将 ${tmpFile.path} 的内容 写入到 ${file.path}');
    file.writeAsBytesSync(tmpFile.readAsBytesSync());
    print('正在删除临时下载文件：${tmpFile.path}');
    tmpFile.delete(recursive: true); // 重命名临时文件

    if (isDecompress) await handleDecompression(); // 解压资源包
  }

  Future<HttpServer> runServer() async {
    if (await shouldUpdate(await localZipFile, (Uri url) => _remoteZipFileAddress = url)) await updateLocalZipFile(); // 如果需要更新，则更新资源包
    if (!await isStaticAssetsValid) await handleDecompression(); // 如果静态资源无效（在更新之后仍然无效），则解压资源包

    final staticDirectory = await staticAssetsDirectory;
    final InternetAddress host = InternetAddress.loopbackIPv4/*'127.0.0.1'*/; // 本机IP地址

    final routes = router.Router(notFoundHandler: createStaticHandler(staticDirectory.path, defaultDocument: 'index.html')) // 模拟 connect-history-api-fallback 中间件。
      ..all('/api/<ignored|.*>', proxyHandler(serverAddress)) // 代理 /api 中间件
      ..all('/image/<ignored|.*>', proxyHandler(serverAddress)) // 代理 /image 中间件
    ;

    final handler = const shelf
      .Pipeline()
      .addMiddleware(shelf.logRequests()) // 打印信息
      .addHandler(routes) // 代理访问处理器
    ;

    return await io.serve(handler, host, port).then((HttpServer _server){
      _server.idleTimeout = null; // 服务空闲超时时间：https://api.dart.dev/stable/3.0.6/dart-io/HttpServer/idleTimeout.html
      print('小程序服务运行在：${_server.address.address}:${_server.port}');
      return _server;
    });
  }
}