import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/count.dart';

class Count extends StatelessWidget{
  final String title;

  const Count({this.title});

  @override
  Widget build(BuildContext context) {
    // final count = Provider.of<CountModel>(context); // 可以这样使用，回更新整个组件

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text('你点击按钮的次数: ${count.value}'),
              Text('你点击按钮的次数:'),
              Consumer<CountModel>( // 订阅更新
                builder: (context, counter, child) => Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Provider.of<CountModel>(context, listen: false).increment(),
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      );
  }
}