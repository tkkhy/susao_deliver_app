import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_map/flutter_baidu_map.dart';
import 'package:susao_deliver_app/pages/loading.dart';
import 'package:susao_deliver_app/router.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/utils/location_utils.dart';


class ShopEditPage extends StatefulWidget {
  String _shopId;
  ShopEditPage({String shopId}) {
    this._shopId = shopId;
  }
  @override
  State<StatefulWidget> createState() => _ShopEditState(this._shopId);
}

class _ShopEditState extends State<ShopEditPage> {
  String _shopId;
  bool isInit;
  TextEditingController _shopNameCtl = new TextEditingController();
  TextEditingController _shopAddressCtl = new TextEditingController();
  TextEditingController _shopContactCtl = new TextEditingController();
  TextEditingController _shopPhoneNumberCtl = new TextEditingController();
  double _latitude;
  double _longitude;

  _ShopEditState(this._shopId) {
    this.isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (ObjectUtil.isEmptyString(this._shopId)) {
      getShopLocation();
      body = _buildBody();
    } else {
      if (this.isInit) {
        body = _buildBody();
      } else {
        body = loadingBox();
        HttpUtil().get(context, '/shop/api/shop', {'shopId': this._shopId}, 
        (rj) {
          setState(() {
            this.isInit = true;
            _shopNameCtl.text = rj.result['name'];
            _shopAddressCtl.text = rj.result['address'];
            _shopContactCtl.text = rj.result['contact'];
            _shopPhoneNumberCtl.text = rj.result['phoneNumber'];
            _latitude = rj.result['latitude'];
            _longitude = rj.result['longitude'];
          });
        }, null, null, null);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(ObjectUtil.isEmptyString(this._shopId)?'新增临时客户':'修改客户'),
      ),
      body: body
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        TextField(
          controller: this._shopNameCtl,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: '客户名称'
          ),
        ),
        TextField(
          maxLines: 3,
          controller: this._shopAddressCtl,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: '客户地址',
            suffixIcon: IconButton(
              icon: Icon(Icons.location_on),
              onPressed: getShopLocation,
            )
          ),
        ),
        TextField(
          controller: this._shopContactCtl,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: '联系人'
          ),
        ),
        TextField(
          controller: this._shopPhoneNumberCtl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: '联系电话'
          ),
        ),
        RaisedButton(
          child: Text(ObjectUtil.isEmptyString(this._shopId)?'添加':'保存'),
          onPressed: createShop,
        )
      ],
    );
  }

  Future<BaiduLocation> getShopLocation() {
    return getLocation().then((BaiduLocation onValue){
      this._shopAddressCtl.text = '${onValue.province}${onValue.city}'
        + '${onValue.district}${onValue.street}${onValue.locationDescribe}';
      this._latitude = onValue.latitude;
      this._longitude = onValue.longitude;
      return onValue;
    });
  }

  void createShop() {
    var data = {
      'name': _shopNameCtl.text,
      'longitude': _longitude,
      'latitude': _latitude,
      'address': _shopAddressCtl.text,
      'shopType': '0',
      'contact': _shopContactCtl.text,
      'phoneNumber': _shopPhoneNumberCtl.text
    };
    if (!ObjectUtil.isEmptyString(this._shopId)) {
      data['shopId'] = this._shopId;
    }

    HttpUtil().post(context, '/shop/api/shop', 
      data, 
      (rj) {
        Routes.router.navigateTo(context, '/shop?shopId=${rj.result['id'].toString()}'
          + '&shopName=${Uri.encodeComponent(rj.result['name'])}', replace: true);       
      }, null, null, null);
  }
}