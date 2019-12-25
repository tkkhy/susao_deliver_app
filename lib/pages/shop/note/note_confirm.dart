import 'package:badges/badges.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/beans/note_ticket.dart';
import 'package:susao_deliver_app/const.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/pages/shop/note/pay_editor.dart';
import 'package:susao_deliver_app/router.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';

import 'note_product.dart';

class NoteConfirmPage extends StatefulWidget {
  String _noteId;
  String _shopId;
  String _shopName;
  String _planId;
  List<ShopProduct> _shopProductList;
  bool _isEdit;
  PayResult _payResult;

  NoteConfirmPage(this._noteId, this._shopId, this._shopName, this._shopProductList, this._payResult, this._planId, {isEdit:true}) {
    this._isEdit = isEdit;
  }

  @override
  State<StatefulWidget> createState() => _NoteConfirmState(
    this._noteId, this._shopId, this._shopName, this._shopProductList, this._payResult, this._planId, this._isEdit
  );
  
}

class _NoteConfirmState extends State<NoteConfirmPage> {
  bool _isEdit;
  String _noteId;
  String _shopId;
  String _shopName;
  String _planId;
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

  _NoteConfirmState(this._noteId, this._shopId, this._shopName, this._shopProductList,
    this._payResult, this._planId, this._isEdit);

  @override
  void initState() {
    analyseProducts();
    _bookkeepingCtl.text = '0';
    _tabs = <Tab>[
      Tab(child: Badge(badgeContent: Text('$_deliverNum'), child: Text('送货单'), badgeColor: Colors.orange,),),
      Tab(child: Badge(badgeContent: Text('$_rejectNum'), child: Text('退货单'), badgeColor: Colors.orange,),),
    ];
    
    if (_giftNum> 0) _tabs.add(Tab(child: Badge(badgeContent: Text('$_giftNum'), child: Text('搭赠单'), badgeColor: Colors.orange,),));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<NoteProdecEditListView> _tabPages = <NoteProdecEditListView>[
      NoteProdecEditListView(_shopProductList, analyseProducts, NoteProductType.values[0], isEdit: false,),
      NoteProdecEditListView(_shopProductList, analyseProducts, NoteProductType.values[1], isEdit: false,),
    ];
    if (this._giftNum > 0) {
      _tabPages.add(NoteProdecEditListView(_shopProductList, analyseProducts, NoteProductType.values[2], isEdit: false,));
    }

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text((this._isEdit?'确认订单-':'查看订单-') + this._shopName),
          bottom: TabBar(tabs: _tabs),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: TabBarView(
                children: _tabPages
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
                  PayEditor(this._payResult, this.analyseProducts, this._isEdit),
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
                          readOnly: !this._isEdit,
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
                    readOnly: !this._isEdit,
                    decoration: InputDecoration(
                      labelText: '订单备注'
                    ),
                  ),
                  Center(
                    child: RaisedButton(
                      child: Text('提交订单'),
                      onPressed: this._isEdit?_commitNote:null,
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

    var data = {
        'shopId': _shopId,
        'noteMsg': _msgCtl.text,
        'deliverPrice': _deliverPrice,
        'rejectPrice': _rejectPrice,
        'totalPrice': _totalPrice,
        'cash': this._payResult.cash??0,
        'weixin': this._payResult.weixin??0,
        'zhifubao': this._payResult.zhifubao??0,
        'card': this._payResult.card??0,
        'actualPrice': double.parse(_actualPriceCtl.text),
        'bookkeeping': double.parse(_bookkeepingCtl.text),
        'products': _products,
    };
    if (!ObjectUtil.isEmptyString(this._noteId)) {
      data['noteId'] = this._noteId;
    }
    if (!ObjectUtil.isEmptyString(this._planId)) {
      data['planId'] = this._planId;
    }

    HttpUtil().post(
      context, 
      '/note/api/note',
      data,
      (rj) {
        toastSuccess('订单完成');
        // printNoteTicketRemote(context, rj.result['ticket']);
        printNoteTicketLocal(context, rj.result['noteId'].toString());
        Routes.router.navigateTo(context, '/index?', clearStack: true);
        // Routes.router.navigateTo(context, '/note/print');
      },
      null,
      null,
      null);
  }
}