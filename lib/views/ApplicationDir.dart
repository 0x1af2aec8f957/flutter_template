import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

class ApplicationDir extends StatelessWidget {
  final String title;
  //  String temporaryDirectory; // 临时目录(缓存)
  //  String applicationDocumentsDirectory; // 应用程序的文档目录
  //  String externalStorageDirectory; // 外部存储目录

  ApplicationDir({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(title),
          // centerTitle: true,
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('请使用 dart:io API来执行对文件系统的读/写操作------\n', style: TextStyle(fontWeight: FontWeight.w900),),
                Text('临时目录[缓存目录]：', style: TextStyle(fontWeight: FontWeight.w600)),
                FutureBuilder(
                    future: getTemporaryDirectory(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) => Text(snapshot.data?.path ?? '获取失败')
                ),
                Text('应用程序根目录:', style: TextStyle(fontWeight: FontWeight.w600)),
                FutureBuilder(
                    future: getApplicationDocumentsDirectory(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) => Text(snapshot.data?.path ?? '获取失败')
                ),
                Text('外部目录:', style: TextStyle(fontWeight: FontWeight.w600)),
                FutureBuilder(
                    future: getExternalStorageDirectory(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) => Text(snapshot.data?.path ?? '获取失败')
                ),
              ],
            ))
    );
  }
}