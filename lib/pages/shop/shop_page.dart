import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';
import 'package:susao_deliver_app/pages/shop/note/pay_editor.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/pages/shop/note/note_product.dart';
import 'package:susao_deliver_app/router.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatefulWidget {
  var shopId;
  var shopName;
  ShopPage(this.shopId, this.shopName);

  @override
  State<StatefulWidget> createState() => _ShopPageState(this.shopId, this.shopName);
}


class _ShopPageState extends State<ShopPage> {
  var _shopId;
  var _shopName;
  ResultJson _shopInfo;
  _ShopPageState(this._shopId, this._shopName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this._shopName),
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    List<Widget> notes = [];
    if (_shopInfo != null) {
      for (var _note in _shopInfo.result['notes']) {
        notes.add(_buildNoteView(_note));
      }
    } else {
      HttpUtil().get(context, '/note/api/getShopWithNoteList', {'shopId': this._shopId},
        (rj) {
          _shopInfo = rj;
          setState(() {});
        },
        null,
        null,
        null);
    }
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          flex: 9,
          child: ListView(
            children: notes,
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('导航'),
                onPressed: () {
                  _navigateToShop();
                },
              ),
              RaisedButton(
                child: Text('创建订单'),
                onPressed: () => this.createNote(),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNoteView(note) {
    return ListTile(
      title: Text(note['noteTime']),
      subtitle: Text(deliverNoteStatus[note['status']]),
      trailing: note['status'] == 0?IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => deleteNote(note),
      ):null,
      onTap: () => this.showNoteDetail(note),
    );
  }
  
  void _navigateToShop() async {
    try {
      var shop = _shopInfo.result['shop'];
      if ( shop['latitude'] == null || shop['longitude'] == null ) {
        toastError('商店坐标错误');
        return;
      }
      // Android
      var url = "baidumap://map/direction?origin=我的位置" +
          "&destination=latlng:"+ shop['latitude'].toString() +","+ shop['longitude'].toString() + "|name:"+ shop['name'] +
          "&mode=driving" +
          "&coord_type=bd09ll" +
          "&src=yourCompanyName|yourAppName#Intent;scheme=bdapp;package=com.baidu.BaiduMap;end";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        toastError('无法调用百度地图');
      }
    } catch (ee) {
      LogUtil.e(ee);
      toastError('导航异常');
    }
  }


  void showNoteDetail(note) {
    HttpUtil().get(context, '/note/api/note', {'noteId': "${note['id']}"},
      (rj) {
        var joProducts = rj.result['products'];
        List shopProductList = new List<ShopProduct>();
        for (var _product in joProducts) {
          shopProductList.add(ShopProduct.fromJson({
              'shopId': _shopId,
              'productId': _product['product']['id'].toString(),
              'productName': _product['product']['name'],
              'price': double.parse(_product['price']),
              'type': 1,
              'deliverNum': _product['deliverNum'],
              'rejectNum': _product['rejectNum'],
              'giftNum': _product['giftNum']
            }));
        }

        PayResult payResult = new PayResult();
        var joNote = rj.result['note'];
        payResult.cash = (joNote['cash'] == null || double.parse(joNote['cash']) <= 0)?null:double.parse(joNote['cash']);
        payResult.weixin = (joNote['weixin'] == null || double.parse(joNote['weixin']) <= 0)?null:double.parse(joNote['weixin']);
        payResult.zhifubao = (joNote['zhifubao'] == null || double.parse(joNote['zhifubao']) <= 0)?null:double.parse(joNote['zhifubao']);
        payResult.card = (joNote['card'] == null || double.parse(joNote['card']) <= 0)?null:double.parse(joNote['card']);
        if (note['status'] == 0) {
          Routes.router.navigateTo(context, '/shop/note?'
            + 'shopId=$_shopId'
            + '&shopName=${Uri.encodeComponent(_shopName)}'
            + '&noteId=${note["id"]}'
            + '&products=${Uri.encodeComponent(jsonEncode(shopProductList))}'
            + '&payResult=${Uri.encodeComponent(jsonEncode(payResult))}');
        } else {
          Routes.router.navigateTo(context, '/shop/note/confirm?'
            + 'shopId=$_shopId'
            + '&shopName=${Uri.encodeComponent(_shopName)}'
            + '&noteId=${note["id"]}'
            + '&products=${Uri.encodeComponent(jsonEncode(shopProductList))}'
            + '&payResult=${Uri.encodeComponent(jsonEncode(payResult))}'
            + '&isEdit=false');
        }
      },
      null,
      null,
      null);   
  }

  void createNote() {
      HttpUtil().get(
        context, 
        '/shop/api/getShopProductList', 
        {'shopId': _shopId}, 
        (rj) {
          List _shopProductList = new List<ShopProduct>();
          for (var _product in rj.result['shopProducts']) {
            _shopProductList.add(ShopProduct.fromJson({
              'shopId': _shopId,
              'productId': _product['product']['id'].toString(),
              'productName': _product['product']['name'],
              'price': double.parse(_product['price']),
              'type': 1
            }));
          }
          List _otherProductList = new List<ShopProduct>();
          for (var _product in rj.result['otherProducts']) {
            _otherProductList.add(ShopProduct.fromJson({
              'shopId': _shopId,
              'productId': _product['id'].toString(),
              'productName': _product['name'],
              'price': double.parse(_product['price']),
              'type': 0
            }));
          }

          Routes.router.navigateTo(context, '/shop/note?'
            + 'shopId=$_shopId'
            + '&shopName=${Uri.encodeComponent(_shopName)}'
            + '&products=${Uri.encodeComponent(jsonEncode(_shopProductList))}'
            + '&others=${Uri.encodeComponent(jsonEncode(_otherProductList))}');
        },
        null, 
        null, 
        null);
  }

  void deleteNote(note) {
    HttpUtil().delete(context, '/note/api/note', {'noteId': "${note['id']}"},
      (rj) {
        toastSuccess('已删除');
        setState(() {
          this._shopInfo = null;
        });
      },
      null,
      null,
      null);
  }
}