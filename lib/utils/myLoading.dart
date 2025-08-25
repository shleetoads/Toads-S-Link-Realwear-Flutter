import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';

class MyLoading {
  MyLoading._privateConstructor();
  static final MyLoading _instance = MyLoading._privateConstructor();

  factory MyLoading() {
    return _instance;
  }

  showLoading(BuildContext? context) {
    if (context != null && !context.loaderOverlay.visible) {
      context.loaderOverlay.show();
    }
  }

  hideLoading(BuildContext? context) {
    if (context != null && context.loaderOverlay.visible) {
      context.loaderOverlay.hide();
    }
  }
}
