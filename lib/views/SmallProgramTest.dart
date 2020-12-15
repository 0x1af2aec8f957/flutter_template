import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../plugins/smallProgram.dart';

class SmallProgramTest extends StatefulWidget{
  final String title;

  const SmallProgramTest({this.title});

  @override
  _Test createState() => _Test();
}

class _Test extends State<SmallProgramTest>{
  bool isLoading = true;
  String fileUrl = 'https://www.baidu.com';
  SmallProgram app = SmallProgram('vue-demo');

  @override
  void initState(){
    super.initState();
    app.run().then((Uri address){
      print('TEST.Component回调 小程序服务运行成功 $address');
      setState(() { isLoading = false;});
    });
  }

  @override
  void dispose() {
    app.close();
    super.dispose();
  }

  void handlePrintDirInfo() async{
    final List<FileSystemEntity> dir = await app.programEntities;
    for (FileSystemEntity file in dir) print('小程序静态资源信息: $file');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('H5小程序测试'),
        actions: [
          GestureDetector(
            child: Icon(Icons.link, size: 20,),
            onTap: handlePrintDirInfo,
          ),
          GestureDetector(
            child: Icon(Icons.delete, size: 20,),
            onTap: app.handleDelete,
          ),
        ],
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.red,
        ),
      ) : WebView(
        initialUrl: 'http://127.0.0.1:8098'/*fileUrl.toString()*/,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}