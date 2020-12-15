import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class About extends StatelessWidget {
  final String title;
  final Map<String, String>? arg;

  const About({Key? key, required this.title, this.arg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(title),
        // centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
            // Text('This is about page, click play animation.'),
            Text('Get home page arguments -> ${arg['info']}.'),
            Text('Get home page router arguments object -> $arg.'),
            /*SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: WebView(
                initialUrl: 'https://www.baidu.com',
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),*/
          ],)
        ),
      ),
    );
  }
}
