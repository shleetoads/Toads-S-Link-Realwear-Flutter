import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/chatViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceListViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceViewModel.dart';
import 'package:realwear_flutter/viewModels/drawViewModel.dart';
import 'package:realwear_flutter/viewModels/screenShareViewModel.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  late IO.Socket socket;

  factory SocketManager() {
    return _instance;
  }

  bool isLogin = false;
  bool isNetworkChange = false;

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

      BuildContext? context = AppConfig.navigatorKey.currentContext;
      if (context == null) return;

      final ref = ProviderScope.containerOf(context);
      AuthModel? authModel = ref.read(authViewModelProvider);

      if (authModel != null && isLogin) {
        isLogin = false;
        ref.read(authViewModelProvider.notifier).getJoinYn(
              email: authModel.email!,
              successFunc: (joinYn, uuid) async {
                if (joinYn == 'Y') {
                  final shared = SharedPreferencesAsync();
                  String sharedUuid = await shared.getString('uuid') ?? '';
                  if (uuid == sharedUuid) {
                    //서버에서 disconnect가 일어나기 전에 다시 붙은걸로 생각함 요기는
                    ref.read(authViewModelProvider.notifier).getMember(
                          email: authModel.email!,
                          successFunc: (_, __, ___) {
                            ref.read(authViewModelProvider.notifier).setJoinYn(
                                email: authModel.email!, yn: 'Y', prevYn: 'Y');

                            ref
                                .read(conferenceListViewModelProvider.notifier)
                                .getConferenceList(
                                    accountNo: authModel.accountNo!);
                          },
                        );
                  } else {
                    ref.read(authViewModelProvider.notifier).init();

                    final router =
                        GoRouter.of(AppConfig.navigatorKey.currentContext!);

                    MyToasts().showNormal('This email is already signed in.');

                    router.go('/auth/signin');

                    //로그인화면으로 팅궈 + 로그아웃루트로 이미 로그인된 아이디입니다
                  }
                } else {
                  ref.read(authViewModelProvider.notifier).getMember(
                        email: authModel.email!,
                        successFunc: (_, __, ___) {
                          ref.read(authViewModelProvider.notifier).setJoinYn(
                              email: authModel.email!, yn: 'Y', prevYn: 'N');

                          ref
                              .read(conferenceListViewModelProvider.notifier)
                              .getConferenceList(
                                  accountNo: authModel.accountNo!);
                        },
                      );
                }
              },
            );
      }
    });

    socket.onConnectError(
      (error) async {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Connection error: $error'));

          if (url != dotenv.env['BASE_URL']!) {
            //내부망 연결 안됨 외부망 연결시켜

            SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
            await asyncPrefs.setBool('isExternal', true);
            await asyncPrefs.remove('internalURL');

            Restart.restartApp();
          }
        }
      },
    );

    socket.onDisconnect((_) {
      print('Socket disconnected');

      if (isNetworkChange) {
        isNetworkChange = !isNetworkChange;
        return;
      }

      final context = AppConfig.navigatorKey.currentContext!;
      final ref = ProviderScope.containerOf(context);

      final router = GoRouter.of(AppConfig.navigatorKey.currentContext!);
      if (router.state.path == '/conference/detail' ||
          router.state.path == '/internal/detail') {
        ref.read(screenShareViewModelProvider.notifier).init();
        ref.read(conferenceViewModelProvider.notifier).init();
        ref.read(chatViewModelProvider.notifier).init();
        ref.read(drawViewModelProvider.notifier).init();

        ref.read(conferenceListViewModelProvider.notifier).init();
      }

      if (AppConfig.isExternal) {
        router.go('/home');
      } else {
        router.go('/internal/home');
      }

      AuthModel? authModel = ref.read(authViewModelProvider);
      if (authModel != null) {
        isLogin = true;
      }

      // completer = Completer<void>();
      // socket.dispose();
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

  disconnect({required bool isNetworkChange}) {
    this.isNetworkChange = isNetworkChange;
    socket.disconnect();
  }
}
