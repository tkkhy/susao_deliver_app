import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';
import 'package:susao_deliver_app/http_utils.dart';
import 'package:susao_deliver_app/pages/loading.dart';
import 'package:susao_deliver_app/router.dart';

import 'note_product.dart';

class CommonNotePage extends StatefulWidget {
  String _shopId;
  String _shopName;

  CommonNotePage(this._shopId, this._shopName);
  @override
  State<StatefulWidget> createState() => _CommonNoteState(this._shopId, this._shopName);
}

class _CommonNoteState extends State<CommonNotePage> {
  String _shopId;
  String _shopName;
  List<ShopProduct> _shopProductList;
  double _totalPrice;
  double _deliverPrice;
  double _rejectPrice;
  final List<Tab> _tabs = <Tab>[
    new Tab(text: '送货单',),
    new Tab(text: '退货单')
  ];

  _CommonNoteState(this._shopId, this._shopName) {
    this._totalPrice = 0;
    this._deliverPrice = 0;
    this._rejectPrice = 0;
  }

  void calcTotalPrice() {
    double _d = 0;
    double _r = 0;
    for (ShopProduct _shop in _shopProductList) {
      _d += _shop.price * _shop.num[0]??0;
      _r += _shop.price * _shop.num[1]??0;
    }
    _deliverPrice = NumUtil.getNumByValueDouble(_d, 2);
    _rejectPrice = NumUtil.getNumByValueDouble(_r, 2);
    _totalPrice = NumUtil.getNumByValueDouble(_d - _r, 2);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('订单系统-' + _shopName),
          bottom: TabBar(
            tabs: _tabs,
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_shopProductList == null) {
      HttpUtil().get(
        context, 
        '/shop/api/getShopProductList', 
        {'shopId': _shopId}, 
        (rj) {
          _shopProductList = new List();
          for (var _product in rj.result) {
            ShopProduct _sp = new ShopProduct();
            _sp.shopId = _shopId;
            _sp.productId = _product['product']['id'].toString();
            _sp.shopProductId = _product['id'].toString();
            _sp.productName = _product['product']['name'];
            _sp.price = double.parse(_product['price']);
            _shopProductList.add(_sp);
          }
          setState(() {});
        }, 
        null, 
        null, 
        null);

      return loadingBox();
    } else {
      return Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            flex: 9,
            child: TabBarView(
              children: <Widget>[
                NoteProdecEditListView(_shopProductList, calcTotalPrice, NoteProductType.values[0]),
                NoteProdecEditListView(_shopProductList, calcTotalPrice, NoteProductType.values[1]),
              ],
            )
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('合计: '),
                    Text('$_totalPrice'),
                    Text(' '),
                    Text('订单: '),
                    Text('$_deliverPrice'),
                    Text(' '),
                    Text('退货: '),
                    Text('$_rejectPrice')
                  ],
                ),
                RaisedButton(
                  child: Text('下单'),
                  onPressed: () {
                    // _commitNote();
                    Routes.router.navigateTo(context, '/shop/note/confirm?' 
                      + 'shopId=$_shopId&shopName=${Uri.encodeComponent(_shopName)}'
                      + '&products=${Uri.encodeComponent(jsonEncode(_shopProductList))}');
                  },
                )
              ],
            ),
          )
        ],
      );
    }
  }
  
}