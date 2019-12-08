import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


Widget loadingBox() {
  return SpinKitCircle(
    color: Colors.grey[600],
    size: 50.0,
  );
}