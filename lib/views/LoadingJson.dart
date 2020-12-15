import 'package:flutter/material.dart';

class LoadingJson extends StatelessWidget {
  final String title;

  const LoadingJson({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(title),
          // centerTitle: true,
        ),
        body: ListView(
          physics: new BouncingScrollPhysics(), // 回弹动效
          children: <Widget>[
            Center(
                child: FutureBuilder<String>(
              // StreamBuilder ... 异步UI
              future: DefaultAssetBundle.of(context).loadString('assets/json/country_code.json'),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // 请求已结束
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    // 请求失败，显示错误
                    return Text("Error: \n${snapshot.error}");
                  } else {
                    // 请求成功，显示数据
                    return Text("Contents:\n ${snapshot.data}");
                  }
                } else {
                  // 请求未结束，显示loading
                  return CircularProgressIndicator();
                }
              },
            ))
          ],
        ));
  }
}
