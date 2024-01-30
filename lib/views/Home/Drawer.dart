import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      width: MediaQuery.of(context).size.width / 1.6,
      child: Drawer(
        child: MediaQuery.removePadding(
            context: context,
            //移除抽屉菜单顶部默认留白
            removeTop: true,
            child: Padding(
              padding: EdgeInsets.only(top: 90.0),
              child: Column(
                  children: <Widget>[
                    TextButton(
                        child: Text('示例'),
                        style: TextButton.styleFrom(textStyle: const TextStyle(color: Colors.blue)),
                        onPressed: () => context.push('/example')
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.contain, // otherwise the logo will be tiny
                          child: const FlutterLogo(),
                        ),
                        TextButton(
                            child: Text('关于'),
                            style: TextButton.styleFrom(textStyle: const TextStyle(color: Colors.blue)),
                            onPressed: () {
                              //导航到新路由
                              // Navigator.pushNamed(context, "about", arguments: <String, String>{'info': 'about'});
                              context.push("/about");
                            }),
                      ],
                    ),
                  ]),
            ),
        ),
      ),
    );
  }
}