import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_map/flutter_baidu_map.dart';
import 'package:geo/geo.dart';
import 'package:loader_search_bar/loader_search_bar.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/pages/loading.dart';
import 'package:susao_deliver_app/router.dart';
import 'package:susao_deliver_app/utils/location_utils.dart';

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
  String _searchQuery;
  
  ShopListState(this.planId, this.planName);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.title = this.planId == null ? "商家列表" : (this.planName + '-' + '-商家列表');
    return Scaffold(
      appBar: SearchBar(
        searchHint: '搜索客户',
        defaultBar: AppBar(title: Text(this.title)),
        onQueryChanged: (String query) {
          setState(() {
            this._searchQuery = query;
          });
        },
        onQuerySubmitted: (String query) {
          setState(() {
            this._searchQuery = query;
          });
        },
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Routes.router.navigateTo(context, '/shop/create').then((onValue){
            setState(() {
              _data = null;
            });
          });
        },
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
            var _shops = _data.result['shops']??[];
            if (loc != null) {
              for (var _shop in _shops) {
                var _longitude = _shop['longitude'];
                var _latitude = _shop['latitude'];
                if (_longitude != null && _latitude != null) {
                  LogUtil.v('local:(${loc.longitude}, ${loc.latitude}), shop:($_longitude, $_latitude)');
                  _shop['distance'] = computeDistanceBetween(
                    LatLng(loc.longitude, loc.latitude), LatLng(_longitude, _latitude));
                }
              }
            }
            for (var _shop in _shops) {
              try {
                // 字符串拼音首字符
                _shop['ShortPinyin'] = PinyinHelper.getShortPinyin(_shop['name']);
                // 拼音
                _shop['Pinyin'] = PinyinHelper.getPinyinE(_shop['name'], separator: '');
              } catch (e) {
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
      return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: (_data.result['shops']??[]).length, 
        // separatorBuilder: (BuildContext context, int index) {
        //   return Divider(height: 2.0, color: Colors.blue,);
        // },
        itemBuilder: (BuildContext context, int index) {
          var shop = _data.result['shops'][index];
          var url = '/shop?shopId=${shop['id'].toString()}&shopName=${Uri.encodeComponent(shop['name'])}';
          if (!ObjectUtil.isEmptyString(planId)) {
            url += "&planId=$planId";
          }
          bool visible = _matchName(shop);
          return Visibility(
            visible: visible,
            child: ListTile(
              title: Text(shop['name']),
              subtitle: Text(shop['address']),
              trailing: Text(((shop['distance'] / 1000).toStringAsFixed(2)??'-') + ' KM'),
              onTap: () {
                Routes.router.navigateTo(context, url);
              },
            ),
          );
        },
      );

    }
  }

  bool _matchName(Map<String, dynamic> shop) {
    if (ObjectUtil.isEmptyString(_searchQuery)) return true;
    if (shop.containsKey('Pinyin') && shop['Pinyin'].contains(_searchQuery)) return true;
    if (shop.containsKey('ShortPinyin') && shop['ShortPinyin'].contains(_searchQuery)) return true;
    if (shop.containsKey('name') && shop['name'].contains(_searchQuery)) return true;
    return false;
  }
}