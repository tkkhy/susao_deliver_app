import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_map/flutter_baidu_map.dart';
import 'package:susao_deliver_app/router.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/utils/location_utils.dart';


class NewShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewShopState();
}

class _NewShopState extends State<NewShopPage> {
  TextEditingController _shopNameCtl = new TextEditingController();
  TextEditingController _shopLocationCtl = new TextEditingController();
  TextEditingController _shopPhoneNumberCtl = new TextEditingController();
  double _latitude;
  double _longitude;

  @override
  Widget build(BuildContext context) {
    getShopLocation();
    return Scaffold(
      appBar: AppBar(
        title: Text('新增临时客户'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
            controller: this._shopLocationCtl,
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
            controller: this._shopPhoneNumberCtl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: '联系电话'
            ),
          ),
          RaisedButton(
            child: Text('添加'),
            onPressed: createShop,
          )
        ],
      ),
    );
  }

  Future<BaiduLocation> getShopLocation() {
    return getLocation().then((BaiduLocation onValue){
      this._shopLocationCtl.text = '${onValue.province}${onValue.city}'
        + '${onValue.district}${onValue.street}${onValue.locationDescribe}';
      this._latitude = onValue.latitude;
      this._longitude = onValue.longitude;
      return onValue;
    });
  }

  void createShop() {
    HttpUtil().post(context, '/shop/api/shop', 
      {
        'name': _shopNameCtl.text,
        'longitude': _longitude,
        'latitude': _latitude,
        'address': _shopLocationCtl.text,
        'shopType': '0'
      }, 
      (rj) {
        Routes.router.navigateTo(context, '/shop?shopId=${rj.result['id'].toString()}'
          + '&shopName=${Uri.encodeComponent(rj.result['name'])}');       
      }, null, null, null);
  }
}