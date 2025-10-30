import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  late IO.Socket socket;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  Future<void> connect(String url) async {
    Completer completer = Completer<void>();

    socket = IO.io(
      url, // 서버 URL
      IO.OptionBuilder()
          .setTransports(['websocket']) // WebSocket 사용
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected');
      if (!completer.isCompleted) {
        completer.complete(); // 연결 완료 신호
      }
    });

    socket.onConnectError(
      (error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Connection error: $error'));
        }
      },
    );

    socket.onDisconnect((_) {
      print('Socket disconnected');
      completer = Completer<void>();
      socket.dispose();
    });

    socket.on(
      'message',
      (data) {
        print('Message from server: $data');
      },
    );

    socket.connect(); // 연결

    return completer.future;
  }

  IO.Socket getSocket() {
    return socket;
  }
}
