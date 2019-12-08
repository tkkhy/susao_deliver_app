import 'package:badges/badges.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';
import 'package:susao_deliver_app/http_utils.dart';
import 'package:susao_deliver_app/pages/shop/note/pay_editor.dart';
import 'package:susao_deliver_app/router.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';

import 'note_product.dart';

class NoteConfirmPage extends StatefulWidget {
  String _shopId;
  String _shopName;
  List<ShopProduct> _shopProductList;

  NoteConfirmPage(this._shopId, this._shopName, this._shopProductList);

  @override
  State<StatefulWidget> createState() => _NoteConfirmState(
    this._shopId, this._shopName, this._shopProductList
  );
  
}

class _NoteConfirmState extends State<NoteConfirmPage> {
  String _shopId;
  String _shopName;
  List<ShopProduct> _shopProductList;
  double _totalPrice;
  double _deliverPrice;
  double _rejectPrice;
  int _deliverNum;
  int _rejectNum;
  int _giftNum;
  TextEditingController _msgCtl = TextEditingController();
  TextEditingController _actualPriceCtl = TextEditingController();
  TextEditingController _bookkeepingCtl = TextEditingController();
  
  List<Tab> _tabs;
  PayResult _payResult;
  static final double _fontSize = ScreenUtil().getWidth(15);

  _NoteConfirmState(this._shopId, this._shopName, this._shopProductList);

  @override
  void initState() {
    this._payResult = PayResult();
    analyseProducts();
    _bookkeepingCtl.text = '0';
    _tabs = <Tab>[
      new Tab(child: Badge(badgeContent: Text('$_deliverNum'), child: Text('送货单'), badgeColor: Colors.orange,),),
      new Tab(child: Badge(badgeContent: Text('$_rejectNum'), child: Text('退货单'), badgeColor: Colors.orange,),),
      new Tab(child: Badge(badgeContent: Text('$_giftNum'), child: Text('搭赠单'), badgeColor: Colors.orange,),),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('确认订单-' + this._shopName),
          bottom: TabBar(tabs: _tabs),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: TabBarView(
                children: <Widget>[
                  NoteProdecEditListView(_shopProductList, analyseProducts, NoteProductType.values[0], isEdit: false,),
                  NoteProdecEditListView(_shopProductList, analyseProducts, NoteProductType.values[1], isEdit: false,),
                  NoteProdecEditListView(_shopProductList, analyseProducts, NoteProductType.values[2], isEdit: false,),
                ],
              )
            ),
            Expanded(
              flex: 5,
              child: ListView(
                children: <Widget>[
                  Row(children: <Widget>[
                    Text('合计: ', style: TextStyle(fontSize: _fontSize),),
                    Text('${_totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: _fontSize),),
                    Text(' '),
                    Text('订单金额：', style: TextStyle(fontSize: _fontSize),),
                    Text('${_deliverPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: _fontSize),),
                    Text(' '),
                    Text('退货金额：', style: TextStyle(fontSize: _fontSize),),
                    Text('${_rejectPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: _fontSize),),
                  ],),
                  PayEditor(this._payResult, this.analyseProducts),
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _actualPriceCtl,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: '实收金额',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _bookkeepingCtl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '记账金额',
                          ),
                        ),
                      )
                    ],
                  ),
                  TextField(
                    controller: _msgCtl,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: '订单备注'
                    ),
                  ),
                  Center(
                    child: RaisedButton(
                      child: Text('提交订单'),
                      onPressed: _commitNote,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }  

  
  void analyseProducts() {
    double _d = 0;
    double _r = 0;
    int _dI = 0;
    int _rI = 0;
    int _gI = 0;
    for (ShopProduct _shop in _shopProductList) {
      if ((_shop.num[0]??0) > 0) {
        _d += _shop.price * _shop.num[0];
        _dI += _shop.num[0];
      }
      if ((_shop.num[1]??0) > 0) {
        _r += _shop.price * _shop.num[1]??0;
        _rI += _shop.num[1];
      }
      if ((_shop.num[2]??0) > 0) {
        _gI += _shop.num[2];
      }
    }

    _actualPriceCtl.text = ((this._payResult.cash??0) + (this._payResult.weixin??0)
      + (this._payResult.zhifubao??0) + (this._payResult.card??0)).toString();
    _deliverPrice = NumUtil.getNumByValueDouble(_d, 2);
    _rejectPrice = NumUtil.getNumByValueDouble(_r, 2);
    _totalPrice = NumUtil.getNumByValueDouble(_d - _r, 2);
    _deliverNum = _dI;
    _rejectNum = _rI;
    _giftNum = _gI;
  }
  
  void _commitNote() {
    var _products = [];
    for (var item in _shopProductList) {
      _products.add(item.toJson());
    }

    HttpUtil().post(
      context, 
      '/note/api/createDeliverNote',
      {
        'shopId': _shopId,
        'noteMsg': _msgCtl.text,
        'totalPrice': _totalPrice,
        'cash': this._payResult.cash??0,
        'weixin': this._payResult.weixin??0,
        'zhifubao': this._payResult.zhifubao??0,
        'card': this._payResult.card??0,
        'actualPrice': double.parse(_actualPriceCtl.text),
        'bookkeeping': double.parse(_bookkeepingCtl.text),
        'products': _products
      },
      (rj) {
        toastSuccess('订单完成');
        Routes.router.navigateTo(context, '/shop_list');
      },
      null,
      null,
      null);
  }
}