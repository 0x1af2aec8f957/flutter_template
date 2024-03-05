import 'package:flutter/material.dart';
import '../lang/i18n.dart';

// 无权限访问
class NoPermission extends StatelessWidget {

  static Future<T?> open<T>(BuildContext context) => Navigator.of(context).pushAndRemoveUntil<T>(PageRouteBuilder( // 打开
    pageBuilder: (context, animation, secondaryAnimation) => NoPermission(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0, 1);
      const end = Offset.zero;
      const curve = Curves.ease;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  ), ModalRoute.withName('/'));

  @override
  Widget build(BuildContext context) {

    return FractionallySizedBox(
      alignment: Alignment.center,
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_permission.png',
            width: 152.95,
            height: 119.56,
          ),
          Padding(padding: EdgeInsets.only(top: 15), child: Text(I18n.$t('common', 'noPermission'), textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}