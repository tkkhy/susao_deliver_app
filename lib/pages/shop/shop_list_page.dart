import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_map/flutter_baidu_map.dart';
import 'package:geo/geo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:susao_deliver_app/http_utils.dart';
import 'package:susao_deliver_app/pages/loading.dart';
import 'package:susao_deliver_app/router.dart';

class ShopListPage extends StatefulWidget {
  var planId;
  var planName;
  ShopListPage(this.planId, this.planName);
  @override
  State<StatefulWidget> createState() => ShopListState(this.planId, this.planName);
}

class ShopListState extends State<ShopListPage> {
  var planId;
  var planName;
  String title;
  ResultJson _data;
  
  ShopListState(this.planId, this.planName);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.title = this.planId == null ? "商家列表" : (this.planName + '-' + '-商家列表');
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget _buildBody() {
    if (_data == null) {
      var reqData = (planId == null)?null:{'planId': this.planId};
      HttpUtil().get(context, '/shop/api/getShopList', reqData,
        (rj) {
          getLocation().then((BaiduLocation loc){
            _data = rj;
            if (planId == null) {
              this.title = '商家列表';
            } else {
              this.title = _data.result['planName'].toString() + '-商家列表';
            }
            if (loc != null) {
              var _shops = _data.result['shops']??[];
              for (var _shop in _shops) {
                var _longitude = _shop['longitude'];
                var _latitude = _shop['latitude'];
                if (_longitude != null && _latitude != null) {
                  LogUtil.v('local:(${loc.longitude}, ${loc.latitude}), shop:(${_longitude}, ${_latitude})');
                  _shop['distance'] = computeDistanceBetween(
                    LatLng(loc.longitude, loc.latitude), LatLng(_longitude, _latitude));
                }
              }
            }
          }).catchError((err){
            LogUtil.e(err.toString());
          }).whenComplete((){
            setState(() {});
          });
        },
        null,
        null,
        null);
      return loadingBox();
    } else {
      return ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: (_data.result['shops']??[]).length, 
        separatorBuilder: (BuildContext context, int index) {
          return Divider(height: 2.0, color: Colors.blue,);
        },
        itemBuilder: (BuildContext context, int index) {
          var shop = _data.result['shops'][index];
          return ListTile(
            title: Text(shop['name']),
            subtitle: Text(shop['address']),
            trailing: Text(((shop['distance'] / 1000).toStringAsFixed(2)??'-') + ' KM'),
            onTap: () {
              Routes.router.navigateTo(context, '/shop?shopId=${shop['id'].toString()}&shopName=${Uri.encodeComponent(shop['name'])}');
            },
          );
        },
      );

    }
  }

  Future<BaiduLocation> getLocation() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    bool hasPermission = permission == PermissionStatus.granted;
    if(!hasPermission){
        Map<PermissionGroup, PermissionStatus> map = await PermissionHandler().requestPermissions([
            PermissionGroup.location
        ]);
        if(map.values.toList()[0] != PermissionStatus.granted){
            return null;
        }
    }
    BaiduLocation location = await FlutterBaiduMap.getCurrentLocation();
    return location;
  }
}