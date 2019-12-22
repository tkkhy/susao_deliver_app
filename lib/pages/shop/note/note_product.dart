import 'dart:math';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';


class ShopProduct {
  // String shopId;
  String productId;
  String productName;
  String code;
  double price;
  String unit;
  int type; // 0-临时商品 1-商家商品
  List<int> num = [0, 0, 0];

  Map<String, dynamic> toJson() {
    return {
      // 'shopId': shopId,
      'productId': productId,
      // 'shopProductId': shopProductId,
      'productName': productName,
      'code': code,
      'price': price,
      'unit': unit,
      'type': type,
      'deliverNum': num[0],
      'rejectNum': num[1],
      'giftNum': num[2],
    };
  }

  int _cvtNum(n) {
    return n??0;
  }

  ShopProduct.fromJson(Map<String, dynamic> data) {
    // this.shopId = data['shopId'];
    this.productId = data['productId'];
    this.productName = data['productName'];
    this.code = data['code'];
    this.price = data['price'];
    this.unit = data['unit'];
    this.type = data['type'];
    this.num[0] = _cvtNum(data['deliverNum']);
    this.num[1] = _cvtNum(data['rejectNum']);
    this.num[2] = _cvtNum(data['giftNum']);
  }

  ShopProduct.fromJsonOfProduct(Map<String, dynamic> data) {
    // this.shopId = data['shopId'];
    this.productId = data['id'].toString();
    this.productName = data['name'];
    this.code = data['code'];
    this.price = double.parse(data['price']);
    this.unit = data['unit'];
    this.type = 0;
    this.num[0] = 0;
    this.num[1] = 0;
    this.num[2] = 0;
  }

  ShopProduct.fromJsonOfShopProduct(Map<String, dynamic> data) {
    // this.shopId = data['shopId'];
    this.productId = data['product']['id'].toString();
    this.productName = data['product']['name'];
    this.code = ObjectUtil.isEmptyString(data['code'])?data['product']['code']:data['code'];
    this.price = double.parse(data['price']);
    this.unit = data['product']['unit'];
    this.type = 1;
    this.num[0] = 0;
    this.num[1] = 0;
    this.num[2] = 0;
  }

  ShopProduct.fromJsonOfNoteProduct(Map<String, dynamic> data) {
    // this.shopId = data['shopId'];
    this.productId = data['product']['id'].toString();
    this.productName = data['product']['name'];
    this.code = data['code'];
    this.price = double.parse(data['price']);
    this.unit = data['product']['unit'];
    this.type = data['productType'];
    this.num[0] = _cvtNum(data['deliverNum']);
    this.num[1] = _cvtNum(data['rejectNum']);
    this.num[2] = _cvtNum(data['giftNum']);
  }
}

class NoteProdectEditView extends StatefulWidget {
  ShopProduct _shopProduct;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  bool _isEdit;
  NoteProdectEditView(this._shopProduct, this._calcTotalPrice, this._noteProductType, this._isEdit);
  @override
  State<StatefulWidget> createState() => _NoteProductEditState(
    this._shopProduct, this._calcTotalPrice, this._noteProductType, this._isEdit);
}

class _NoteProductEditState extends State<NoteProdectEditView> {
  ShopProduct _shopProduct;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  TextEditingController _numCtl;
  TextEditingController _priceCtl;
  bool _isEdit;

  _NoteProductEditState(this._shopProduct, this._calcTotalPrice, this._noteProductType, this._isEdit) {
    this._numCtl = TextEditingController(text: this._shopProduct.num[_noteProductType.index].toString());
    this._priceCtl = TextEditingController(text: this._shopProduct.price.toString());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.orange[100])
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_shopProduct.productName),
                      // Text('单价: ${_shopProduct.price.toStringAsFixed(2)}'),
                      SizedBox(
                        width: ScreenUtil().getWidth(160),
                        child: TextField(
                          controller: this._priceCtl,
                          decoration: InputDecoration(
                            prefixText: '单价：',
                            suffixIcon:  (this._shopProduct.type == 1)?null:Icon(Icons.edit)
                          ),
                          readOnly: !this._isEdit || (this._shopProduct.type == 1),
                          onChanged: (val) {
                            _shopProduct.price = double.parse(val);
                            _calcTotalPrice();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('￥${NumUtil.getNumByValueDouble(_shopProduct.price * _shopProduct.num[this._noteProductType.index], 2)}'),
                    TextField(
                      enabled: _isEdit,
                      controller: _numCtl,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (txt) {
                        _shopProduct.num[_noteProductType.index] = int.parse(txt);
                        _calcTotalPrice();
                      },
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {                            
                            _numCtl.text = max(0, int.parse(_numCtl.text) - 1).toString();
                            _shopProduct.num[_noteProductType.index] = int.parse(_numCtl.text);
                            _calcTotalPrice();
                          },
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _numCtl.text = max(0, int.parse(_numCtl.text) + 1).toString();
                            _shopProduct.num[_noteProductType.index] = int.parse(_numCtl.text);
                            _calcTotalPrice();
                          },
                        ),
                        border: InputBorder.none
                      ),
                    ),
                  ],
                )
              )
            ],
          )
        ],
      )
    );
  }  
}

class NoteProdecEditListView extends StatefulWidget {
  List<ShopProduct> _shopProductList;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  bool _isEdit;
  NoteProdecEditListView(this._shopProductList, this._calcTotalPrice, this._noteProductType, {bool isEdit: true}) {
    this._isEdit = isEdit;
  }
  @override
  State<StatefulWidget> createState() => _NoteProdectEditListState(
    this._shopProductList, this._calcTotalPrice, this._noteProductType, this._isEdit);
}

class _NoteProdectEditListState extends State<NoteProdecEditListView> {
  List<ShopProduct> _shopProductList;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  bool _isEdit;
  _NoteProdectEditListState(this._shopProductList, this._calcTotalPrice, this._noteProductType, this._isEdit);

  @override
  Widget build(BuildContext context) {
    List<NoteProdectEditView> views = new List();
    for (var item in this._shopProductList) {
      if (!_isEdit && item.num[this._noteProductType.index] <= 0) continue;
      views.add(NoteProdectEditView(item, _calcTotalPrice, 
            this._noteProductType, this._isEdit));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey)
      ),
      child: ListView(
        padding: EdgeInsets.all(10.0),
        children: views,
      ),
    );
  }
  
}