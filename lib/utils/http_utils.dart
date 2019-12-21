import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/config.dart';
import 'package:susao_deliver_app/router.dart';


class ResultJson {
  bool status;
  dynamic result;
  String msg;

  ResultJson call(data) {
    this.status = data['status'];
    this.result = data['result'];
    this.msg = data['msg'];
    return this;
  }
}

class TokenResultJson {
  String accessToken;
  int expiresIn;
  String tokenType;
  String scope;
  String refreshToken;
  bool status;

  TokenResultJson call(data) {
    this.status = true;
    this.accessToken = data["access_token"];
    this.expiresIn = data["expires_in"];
    this.tokenType = data["token_type"];
    this.scope = data["scope"];
    this.refreshToken = data["refresh_token"];
    return this;
  }
}

TokenResultJson globalToken;

enum HttpContentType {
  json,
  from
}



class HttpUtil {
  static String _get = 'GET';
  static String _post = 'POST';
  static String _delete = 'DELETE';

  var _dio;

  Map<String, String> getToken() {
    return {
      'authorization': _dio.options.headers['authorization']
    };
  }

  factory HttpUtil() => _getInstance();
  static HttpUtil get instance => _getInstance();
  static HttpUtil _instance;
  HttpUtil._internal() {
    // 初始化  
    _dio = Dio(BaseOptions(baseUrl: Config.baseUrl));
    var cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest:(RequestOptions options) async {
        // 在请求被发送之前做一些事情
        return options; //continue
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      },
      onResponse:(Response response) async {
        // 在返回响应数据之前做一些预处理
        return response; // continue
      },
      onError: (DioError e) async {
        // 当请求失败时做一些预处理
        return e;//continue
      }
    ));
  }
  static HttpUtil _getInstance() {
    if (_instance == null) {
      _instance = new HttpUtil._internal();
    }
    return _instance;
  }

  

  void get(
    BuildContext context,
    String uri, Map<String, dynamic> queryParameters,
    Function successCallback,
    Function failedCallback,
    Function exceptCallback,
    Function noLoginCallback,
    {HttpContentType contentType=HttpContentType.json, dynamic beanClass}) async {
      _query(context,
        uri, queryParameters,
        successCallback,
        failedCallback,
        exceptCallback,
        noLoginCallback,
        _get,
        contentType,
        beanClass??new ResultJson());
  }

  void post(
      BuildContext context,
      String uri, Map<String, dynamic> queryParameters,
      Function successCallback,
      Function failedCallback,
      Function exceptCallback,
      Function noLoginCallback,
      {HttpContentType contentType=HttpContentType.json, dynamic beanClass}) async {
    _query(context,
      uri, queryParameters,
      successCallback,
      failedCallback,
      exceptCallback,
      noLoginCallback,
      _post,
      contentType,
      beanClass??new ResultJson());
  }

  
  void delete(
      BuildContext context,
      String uri, Map<String, dynamic> queryParameters,
      Function successCallback,
      Function failedCallback,
      Function exceptCallback,
      Function noLoginCallback,
      {HttpContentType contentType=HttpContentType.json, dynamic beanClass}) async {
    _query(context,
      uri, queryParameters,
      successCallback,
      failedCallback,
      exceptCallback,
      noLoginCallback,
      _delete,
      contentType,
      beanClass??new ResultJson());
  }

  void _query(
      BuildContext context,
      String uri, Map<String, dynamic> queryParameters,
      Function successCallback,
      Function failedCallback,
      Function exceptCallback,
      Function noLoginCallback,
      String type,
      HttpContentType contentType,
      dynamic beanClass) async {
    
    successCallback ??= _successCallback(context);    
    failedCallback ??= _failedCallback(context);
    exceptCallback ??= _exceptCallback(context);
    noLoginCallback ??= _noLoginCallback(context);

    try {
      var request;
      if (type == _get) {
        var _uri = Uri(path: uri, queryParameters: queryParameters);
        request = await _dio.getUri(_uri);
      } else if (type == _post) {
        var options; 
        if (contentType == HttpContentType.from) {
          options = new Options(contentType: "application/x-www-form-urlencoded");
        }
        request = await _dio.post(uri, data: queryParameters, options: options);
      } else {
        request = await _dio.delete(uri, data: queryParameters);
      }

      dynamic rj = beanClass(request.data);
      if (beanClass is TokenResultJson) {
        globalToken = rj;
        // _dio.options.headers['Authorization'] = globalToken.tokenType + ' ' + globalToken.accessToken;
        _dio.options.headers['authorization'] = globalToken.tokenType + ' ' + globalToken.accessToken;
        // _dio.options.headers['token'] = globalToken.accessToken;
      }
      if (rj.status) {
        successCallback(rj);
      } else {
        if (rj.msg == 'no_login') {
          noLoginCallback(rj);
        } else {
          failedCallback(rj);
        }
      }
    } on DioError catch (e) {
      print(e);
    } catch (exception) {
      print(exception);
      exceptCallback(exception);
    }
  }

  _successCallback(context) => (rt) {showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('成功'),
        content: Center(child: Text('成功'),),
      )
    );};
    
  _failedCallback(context) => (rt) {showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('失败'),
        content: Center(child: Text(rt.msg),),
      )
    );};
  _exceptCallback(context) => (exception) {showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('异常'),
        content: Center(child: Text('异常'),),
      )
    );};

  _noLoginCallback(context) => (rt) {Routes.router.navigateTo(context, '/login');};

}