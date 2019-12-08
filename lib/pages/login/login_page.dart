import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/config.dart';
import 'package:susao_deliver_app/http_utils.dart';
import 'package:susao_deliver_app/router.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // 用户名控制器
  TextEditingController usernameCtl = TextEditingController();
  // 密码控制器
  TextEditingController passwordCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录'),),
      body: Column(
        children: <Widget>[
          TextField(
            controller: usernameCtl,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.person),
              labelText: '请输入账号',
              helperText: '请输入账号'
            ),
            autofocus: false,
          ),
          TextField(
            controller: passwordCtl,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.lock),
              labelText: '请输入密码',
              helperText: '请输入密码',
            ),
            obscureText: true,
          ),
          RaisedButton(
            onPressed: _login,
            child: Text('登录'),
            color: Colors.blue,
          )
        ],
      ),
    );
  }

  void _login() {
    if (usernameCtl.text.length == 0) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('错误'),
          content: Center(child: Text('用户名不能为空'),),
        )
      );
    }
    HttpUtil().post(context, '/o/token/', 
      {
        'username': usernameCtl.text, 
        'password': passwordCtl.text,
        'grant_type': 'password',
        'client_id': Config.tokenClientId,
        'client_secret': Config.tokenClientSecret
      },
      (data) {
        Routes.router.navigateTo(context, '/index');
      },
      (data) {          
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('错误'),
            content: Center(child: Text('登录失败'),),
          )
        );
      },
      (data) {          
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('错误'),
            content: Center(child: Text('登录失败'),),
          )
        );
      },
      null,
      contentType: HttpContentType.from,
      beanClass: TokenResultJson(),
    );
  }
  
}