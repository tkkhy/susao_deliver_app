import 'dart:math';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';


class ShopProduct {
  String shopId;
  String productId;
  // String shopProductId;
  String productName;
  double price;
  List<int> num = [0, 0, 0];

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'productId': productId,
      // 'shopProductId': shopProductId,
      'productName': productName,
      'price': price,
      'deliverNum': num[0],
      'rejectNum': num[1],
      'giftNum': num[2],
    };
  }
}

class NoteProdectEditView extends StatefulWidget {
  ShopProduct _shopProduct;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  bool _isEdit;
  bool _isPriceEdit;
  NoteProdectEditView(this._shopProduct, this._calcTotalPrice, this._noteProductType, this._isEdit, this._isPriceEdit);
  @override
  State<StatefulWidget> createState() => _NoteProductEditState(
    this._shopProduct, this._calcTotalPrice, this._noteProductType, this._isEdit, this._isPriceEdit);
}

class _NoteProductEditState extends State<NoteProdectEditView> {
  ShopProduct _shopProduct;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  TextEditingController _numCtl;
  TextEditingController _priceCtl;
  bool _isEdit;
  bool _isPriceEdit;

  _NoteProductEditState(this._shopProduct, this._calcTotalPrice, this._noteProductType, this._isEdit, this._isPriceEdit) {
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
                        width: ScreenUtil().getWidth(100),
                        child: TextField(
                          controller: this._priceCtl,
                          decoration: InputDecoration(
                            prefixText: '单价：'
                          ),
                          readOnly: !this._isPriceEdit,
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
  bool _isPriceEdit;
  NoteProdecEditListView(this._shopProductList, this._calcTotalPrice, this._noteProductType, {bool isEdit: true, bool isPriceEdit: false}) {
    this._isEdit = isEdit;
    this._isPriceEdit = isPriceEdit;
  }
  @override
  State<StatefulWidget> createState() => _NoteProdectEditListState(
    this._shopProductList, this._calcTotalPrice, this._noteProductType, this._isEdit, this._isPriceEdit);
}

class _NoteProdectEditListState extends State<NoteProdecEditListView> {
  List<ShopProduct> _shopProductList;
  Function _calcTotalPrice;
  NoteProductType _noteProductType;
  bool _isEdit;
  bool _isPriceEdit;
  _NoteProdectEditListState(this._shopProductList, this._calcTotalPrice, this._noteProductType, this._isEdit, this._isPriceEdit);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey)
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: _shopProductList.length,
        // separatorBuilder: (context, index) => Divider(height: 1,),
        itemBuilder: (context, index)
        {
          if (!_isEdit && _shopProductList[index].num[this._noteProductType.index] <= 0) return null;
          return NoteProdectEditView(_shopProductList[index], _calcTotalPrice, this._noteProductType, this._isEdit, this._isPriceEdit);
        },
      ),
    );
  }
  
}