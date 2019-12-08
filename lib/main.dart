import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/pages/login/login_page.dart';
import 'package:susao_deliver_app/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    LogUtil.init();
    Routes.configureRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      onGenerateRoute: Routes.router.generator,
    );
  }
}