import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:susao_deliver_app/const.dart';
import 'package:susao_deliver_app/pages/shop/new_shop_page.dart';
import 'package:susao_deliver_app/pages/shop/note/note_confirm.dart';
import 'package:susao_deliver_app/pages/shop/note/note_edit.dart';
import 'package:susao_deliver_app/pages/shop/note/note_product.dart';
import 'package:susao_deliver_app/pages/shop/note/pay_editor.dart';
import 'package:susao_deliver_app/pages/shop/shop_page.dart';

import 'pages/404.dart';
import 'pages/index/index_page.dart';
import 'pages/shop/shop_list_page.dart';
import 'pages/login/login_page.dart';

class Routes {
  static Router router = Router();

  static void configureRoutes() {
    router.notFoundHandler = Handler(handlerFunc: (context, params) => Page404());

    router.define('/login', handler: Handler(handlerFunc: (context, params) => LoginPage()));
    router.define('/index', handler: Handler(handlerFunc: (context, params) => IndexPage()));
    router.define('/shop/create', handler: Handler(handlerFunc: (context, params) => NewShopPage()));
    router.define('/shop_list', handler: Handler(handlerFunc: (context, params) {
      var planId = params['planId']?.first;
      var planName = params['planName']?.first;
      return ShopListPage(planId, planName);
    }));
    router.define('/shop', handler: Handler(handlerFunc: (context, params) {
      var shopId = params['shopId']?.first;
      var shopName = params['shopName']?.first;
      return ShopPage(shopId, shopName);
    }));
    router.define('/shop/note', handler: Handler(handlerFunc: (context, params) {
      String noteId = params['noteId']?.first;
      var shopId = params['shopId']?.first;
      var shopName = params['shopName']?.first;
      
      var joProducts = jsonDecode(params['products']?.first);
      List<ShopProduct> products = new List();
      for (var jo in joProducts) {
        products.add(ShopProduct.fromJson(jo));
      }

      var joOtherProducts = jsonDecode(params['others']?.first);
      List<ShopProduct> others = new List();
      for (var jo in joOtherProducts) {
        others.add(ShopProduct.fromJson(jo));
      }

      PayResult payResult = new PayResult();
      String strPayResult = params['payResult']?.first;
      if (strPayResult != null) {
        var joPayResult = jsonDecode(strPayResult);
        payResult.cash = joPayResult['cash'];
        payResult.weixin = joPayResult['weixin'];
        payResult.zhifubao = joPayResult['zhifubao'];
        payResult.card = joPayResult['card'];
      }
      return CommonNotePage(noteId, shopId, shopName, products, others, payResult);
    }));
    router.define('/shop/note/confirm', handler: Handler(handlerFunc: (context, params) {
      String noteId = params['noteId']?.first;
      bool isEdit = (params['isEdit']?.first) == 'false'?false:true;
      var shopId = params['shopId']?.first;
      var shopName = params['shopName']?.first;
      var joProducts = jsonDecode(params['products']?.first);
      List<ShopProduct> products = new List();
      for (var jo in joProducts) {
        products.add(ShopProduct.fromJson(jo));
      }

      PayResult payResult = new PayResult();
      String strPayResult = params['payResult']?.first;
      if (strPayResult != null) {
        var joPayResult = jsonDecode(strPayResult);
        payResult.cash = joPayResult['cash'];
        payResult.weixin = joPayResult['weixin'];
        payResult.zhifubao = joPayResult['zhifubao'];
        payResult.card = joPayResult['card'];
      }
      return NoteConfirmPage(noteId, shopId, shopName, products, payResult, isEdit: isEdit,);
    }));
  }

}