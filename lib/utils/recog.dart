import 'package:flutter/services.dart';

class Recog {
  Recog._privateConstructor();
  static final Recog _instance = Recog._privateConstructor();

  factory Recog() {
    return _instance;
  }

  static Function(String)? _handler;

  MethodChannel channel = MethodChannel('ToadsSLink')
    ..setMethodCallHandler(
      (call) async {
        print(call.method);
        if (call.method == 'onReceive' && _handler != null) {
          _handler!(call.arguments['command']);
        }
      },
    );

  static setHandler(Function(String) handler) {
    _handler = handler;
  }
}
