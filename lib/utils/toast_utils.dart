import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toastError(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    backgroundColor: Colors.red,
    textColor: Colors.black);
}

void toastSuccess(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    backgroundColor: Colors.green,
    textColor: Colors.black);
}