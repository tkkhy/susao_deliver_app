import 'package:flutter_baidu_map/flutter_baidu_map.dart';
import 'package:permission_handler/permission_handler.dart';

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