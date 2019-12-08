import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/const.dart';
import 'package:susao_deliver_app/http_utils.dart';
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
                onPressed: (){
                  Routes.router.navigateTo(context, '/shop/note?shopId=$_shopId&shopName=${Uri.encodeComponent(_shopName)}');
                },
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
      onTap: (){},
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
}