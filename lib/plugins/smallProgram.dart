/// H5小程序
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart'; // shelf静态文件中间件

enum Status { // 状态
  success,
  failed
}

enum Progress { // 进度
  start,
  inProgress,
  finish
}

typedef void DecompressionCallback(Progress state);

abstract class ProgramType{
  final String name; // 小程序名称
  final Uri serverAddress; // 静态服务器地址(远程下载服务器)
  ProgramType(this.name, this.serverAddress); // 小程序名称

  Future<Uri> run(); // 服务运行
  Future<dynamic> close(); // 服务关闭
  Future<void> handleDecompression(); // 资源解压
}

class SmallProgram implements ProgramType{
  HttpServer server;
  final String name;
  final Uri serverAddress = Uri( // 小程序服务器
      scheme: 'http',
      host: '192.168.0.121', // NOTE: 如果测试服务器在本地，注意使用IP，此处为模拟器或真机发出链接服务器的响应地址
      port: 8089
  );
  ProgressCallback onDownload; // 下载时进度回调，(received /* 已传输的大小 */, total /* 总大小 */)
  DecompressionCallback onDecompression; // 解压回调回调
  SmallProgram(this.name, { this.onDownload, this.onDecompression });

  DecompressionCallback get defaultDecompression => onDecompression ?? (Progress state) => null;
  ProgressCallback get defaultDownload => onDownload ?? (int count, int total) => null;

  Future<Directory> get applicationDir => getApplicationDocumentsDirectory(); // 应用程序包目录(沙盒目录，读写无需单独的权限申请)，该文件夹一定存在
  Future<List<FileSystemEntity>> get programEntities => programDir.then((Directory dir) => dir.listSync(recursive:true, followLinks: false)); // 小程序静态资源文件信息
  Future<Directory> get programDir async{ // 小程序资源存放目录
    final Directory _dir = await applicationDir.then((Directory dir) => Directory(path.join(dir.path, name)));

    if (!_dir.existsSync()) await handleDecompression(); // 在获取该文件夹时，检测是否存在文件夹，不存在执行同步创建
    // if (_dir.listSync(recursive: true).toList().isEmpty) await handleDecompression(); // 当文件夹存在，但内容为空时自动解压（解压过程中会自动按需完成下载等操作）
    return _dir;
  }

  Future<Directory> get packageDir async{ // 小程序下载(|存放)目录
    final Directory _dir = await applicationDir.then((Directory dir) => Directory(path.join(dir.path, 'download')));
    if (!_dir.existsSync()) _dir.createSync(recursive: true); // 在获取该文件夹时，检测是否存在文件夹，不存在执行同步创建
    return _dir;
  }

  Future<File> get packageFile async{ // 小程序原始文件
    final String packageFileName = '$name.zip';
    final String downloadPath = 'download';
    final File _file = await packageDir.then((Directory dir) => File(path.join(dir.path, packageFileName)));

    if (!_file.existsSync()) { // 在获取该文件时，不存在自动下载
      final Uri _serverAddress = serverAddress.replace(path: '$downloadPath/$packageFileName');
      await Dio().download(_serverAddress.toString(), _file.path, onReceiveProgress: (int count, int total){
        print('正在下载小程序: 已下载$count, 总大小$total');
        defaultDownload(count, total);
      }); // 下载资源包，重复下载会覆盖原有的压缩包
    }
    return _file;
  }

  Future<void> handleDecompression([String _path]) async{ // 解压小程序压缩包
    defaultDecompression(Progress.start);
    final File _compressFile = _path != null && _path.isNotEmpty ? File(_path) : (await packageFile); // 压缩文件
    final List<int> _bytes = _compressFile.readAsBytesSync();
    final Directory _programDir = await applicationDir;
    defaultDecompression(Progress.inProgress);
    final Archive archive = ZipDecoder().decodeBytes(_bytes);

    print('解压资源存放路径: ${_programDir.path}');
    archive.forEach((ArchiveFile _file){ // 将Zip存档的内容解压到磁盘。
      print('解压文件详细信息: $_file');
      if (_file.isFile) {
        File(path.join(_programDir.path, _file.name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(_file.content as List<int>);
      }
      else {
        Directory(path.join(_programDir.path, _file.name))
          ..createSync(recursive: true);
      }
    });

    defaultDecompression(Progress.finish);
  }

  Future<void> handleDelete() async{
    final _programDir = await programDir;
    final _packageFile = await packageFile;

    _packageFile.deleteSync(recursive: true); // 删除小程序下载的原始文件
    _programDir.deleteSync(recursive: true); // 删除小程序资源存放目录
  }

  Future<Uri> run() async{
    final InternetAddress host = InternetAddress.loopbackIPv4/*'127.0.0.1'*/; // 本机IP地址
    final int port = 8098; // 服务端口号

    final handler = const shelf
        .Pipeline()
        .addMiddleware(shelf.logRequests()) // 打印信息
        .addHandler(createStaticHandler(path.join((await programDir).path), defaultDocument: 'index.html')); // 静态文件中间件

    return io.serve(handler, host, port).then((HttpServer _server){
      server = _server; // 服务对象保存
      final Uri serverAddress = Uri( // 小程序服务运行服务地址
        scheme: 'http',
        host: server.address.host,
        port: server.port,
        // path: name
      );

      print('小程序服务运行在 $serverAddress');
      return serverAddress;
    });
  }

  Future close(){
    return server.close(force: true).then((status){
        print('小程序服务已关闭 $status');
        return status;
    }); // 关闭http服务器
  }
}