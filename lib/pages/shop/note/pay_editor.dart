import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';

class PayResult {
  double cash;
  double weixin;
  double zhifubao;
  double card;

  PayResult() {
    this.cash = null;
    this.weixin = null;
    this.zhifubao = null;
    this.card = null;
  }

}


class PayEditor extends StatefulWidget {
  PayResult _payResult;
  Function _updateCallback;
  PayEditor(this._payResult, this._updateCallback);
  @override
  State<StatefulWidget> createState() => _PayEditorState(this._payResult, this._updateCallback);
}

class _PayEditorState extends State<PayEditor> {
  PayResult _payResult;
  TextEditingController _cashCtl;
  TextEditingController _weixinCtl;
  TextEditingController _zhifubaoCtl;
  TextEditingController _cardCtl;
  Function _updateCallback;

  int _cashFlex;
  int _weixinFlex;
  int _zhifubaoFlex;
  int _cardFlex;

  _PayEditorState(this._payResult, this._updateCallback) {
    this._cashCtl = TextEditingController(text: this._payResult.cash?.toString());
    this._weixinCtl = TextEditingController(text: this._payResult.weixin?.toString());
    this._zhifubaoCtl = TextEditingController(text: this._payResult.zhifubao?.toString());
    this._cardCtl = TextEditingController(text: this._payResult.card?.toString());

    this.updateFlex();
  }

  void updateFlex() {
    this._cashFlex = this._payResult.cash == null?1:2;
    this._weixinFlex = this._payResult.weixin == null?1:2;
    this._zhifubaoFlex = this._payResult.zhifubao == null?1:2;
    this._cardFlex = this._payResult.card == null?1:2;
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          flex: this._cashFlex,
          child: TextField(
            controller: this._cashCtl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: payType2name[PayType.cash.index],
            ),
            onChanged: (val) {
              if (val != null &&  val != '') {
                this._payResult.cash = double.parse(val);
                this._cashFlex = 2;
              } else {
                this._payResult.cash = null;
                this._cashFlex = 1;
              }
              this._updateCallback();
            },
          ),
        ),
        Expanded(
          flex: this._weixinFlex,
          child: TextField(
            controller: this._weixinCtl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: payType2name[PayType.weixin.index],
            ),
            onChanged: (val) {
              if (val != null &&  val != '') {
                this._payResult.weixin = double.parse(val);
                this._weixinFlex = 2;
              } else {
                this._payResult.weixin = null;
                this._weixinFlex = 1;
              }
              this._updateCallback();
            },
          ),
        ),
        Expanded(
          flex: this._zhifubaoFlex,
          child: TextField(
            controller: this._zhifubaoCtl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: payType2name[PayType.zhifubao.index],
            ),
            onChanged: (val) {
              if (val != null &&  val != '') {
                this._payResult.zhifubao = double.parse(val);
                this._zhifubaoFlex = 2;
              } else {
                this._payResult.zhifubao = null;
                this._zhifubaoFlex = 1;
              }
              this._updateCallback();
            },
          ),
        ),
        Expanded(
          flex: this._cardFlex,
          child: TextField(
            controller: this._cardCtl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: payType2name[PayType.card.index],
            ),
            onChanged: (val) {
              if (val != null &&  val != '') {
                this._payResult.card = double.parse(val);
                this._cardFlex = 2;
              } else {
                this._payResult.card = null;
                this._cardFlex = 1;
              }
              this._updateCallback();
            },
          ),
        ),
      ],
    );
  }
}