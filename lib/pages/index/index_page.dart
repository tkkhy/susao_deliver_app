import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as screenutil;
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/pages/loading.dart';
import 'package:susao_deliver_app/router.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  ResultJson _data;

  @override
  Widget build(BuildContext context) {
    screenutil.ScreenUtil.instance = screenutil.ScreenUtil(width: 750, height: 1334)..init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
      ),
      drawer: new Drawer(
        child: buildIndexDrawer(),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_data == null) {
      HttpUtil().get(context, '/plan/api/getDriverIndexInfo', null,
        (rj) {
          setState(() {
            _data = rj;
          });
        },
        null,
        null,
        null);
      return loadingBox();
    } else {
      if (_data.result == null) {
        return Center(child: Text(_data.msg));
      } else {
        return _buildDriverIndexBody();
      }
    }
  }

  
  Widget buildIndexDrawer() {
    var children = <Widget>[
      _buildDrawerHeader(),
      ListTile(
        title: Text('首页'),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _data = null;
          });
        },
      ),
      ListTile(
        title: Text('商家列表'),
        onTap: () {
          Navigator.pop(context);
          Routes.router.navigateTo(context, '/shop_list');
        },
      ),
      Divider(thickness: 2,),
    ];

    if (_data != null) {
      if (_data.result == null || _data.result['plans'] == null) {
        children.add(Center(
          child: Text(_data.msg),
        ));
      } else {
        for(var plan in _data.result['plans']) {
          children.add(ListTile(
              title: Text(plan['name']),
              onTap: () {
                Navigator.pop(context);
                Routes.router.navigateTo(context, '/shop_list?planId=${plan['id'].toString()}&planName=${Uri.encodeComponent(plan['name'])}');
              },
            ),
          );
        }
      }

    }
    return new ListView(
      padding: EdgeInsets.only(),
      children: children,
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        'name'
      ),
      accountEmail: Text(
        'name@163.com'
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.green,
      ),
      onDetailsPressed: () {},
      otherAccountsPictures: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.red,
        )
      ],
    );
  }

  Widget _buildDriverIndexBody() {
    var body = <Widget>[
        Center(child: Text('你好,' + _data.result['driver']['name']),),
        Divider(thickness: 2,),
    ];
    for(var plan in _data.result['plans']) {
      body.add(_buildPlanView(plan));
      body.add(Divider(thickness: 2,));
    }
    return Column(
      children: body,
    );
  }

  Widget _buildPlanView(plan) {
    String passengers = '';
    for (var pn in plan['passengers']) {
      passengers += pn['name'] + ',';
    }

    var col = Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[ 
            Text('计划名称：'),
            Text(plan['name'])
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[       
            Text('计划日期：'),
            Text(plan['date'])
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[       
            Text('乘客列表'),
            Text(passengers)
          ],
        ),
      ],
    );
    return ListTile(
      title: col,
      onTap: () {
        Routes.router.navigateTo(context, '/shop_list?planId=${plan['id'].toString()}&planName=${Uri.encodeComponent(plan['name'])}');
      },);
  }
}