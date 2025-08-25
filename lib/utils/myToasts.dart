import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToasts {
  MyToasts._privateConstructor();
  static final MyToasts _instance = MyToasts._privateConstructor();

  factory MyToasts() {
    return _instance;
  }

  showNormal(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF2B2B2B),
        textColor: Colors.white,
        fontSize: 14.0);
  }
}
