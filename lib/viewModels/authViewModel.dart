import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends StateNotifier<AuthModel?> {
  AuthViewModel() : super(null);

  login(
      {required String email,
      required String pw,
      required Function(int, int, String) successFunc,
      required Function(bool) failFunc,
      required Function() duplicateFunc}) {
    SocketManager().getSocket().emit('login', [email, pw]);
    SocketManager().getSocket().once(
      'loginResult',
      (data) async {
        logger.i(data);
        switch (data[0]) {
          case 'Duplicatelogin':
            duplicateFunc();
            final asyncShared = SharedPreferencesAsync();

            asyncShared.remove('email');
            asyncShared.remove('accountNo');
            break;
          case 'noAccount':
            // MyToasts().showNormal('Please check your account.');
            failFunc(true);
            break;
          case 'incorrectPW':
            // MyToasts().showNormal('Please check your password');
            failFunc(false);
            break;
          case 'success':
            // print(data[1]);
            getMember(email: email, successFunc: successFunc);
            break;
        }
      },
    );

    SocketManager().getSocket().once(
      'authResult',
      (data) {
        switch (data[0]) {
          case 'invalidKey':
            MyToasts().showNormal('invalidKey');
            break;
          case 'expired':
            MyToasts().showNormal('expired');
            break;
        }
      },
    );
  }

  autoLogin(
      {required String email,
      required Function(int, int, String) successFunc,
      required Function() duplicateFunc}) {
    SocketManager().getSocket().emit('autoLogin', email);
    SocketManager().getSocket().once(
      'loginResult',
      (data) async {
        logger.i(data);

        switch (data[0]) {
          case 'Duplicatelogin':
            duplicateFunc();
            final asyncShared = SharedPreferencesAsync();

            asyncShared.remove('email');
            asyncShared.remove('accountNo');
            // MyToasts().showNormal('Duplicatelogin');
            // getMember(email: email, successFunc: successFunc);

            break;
          case 'autoLogin':
            // print(data[1]);
            getMember(email: email, successFunc: successFunc);
            break;
        }
      },
    );

    SocketManager().getSocket().once(
      'authResult',
      (data) {
        switch (data[0]) {
          case 'invalidKey':
            MyToasts().showNormal('invalidKey');
            break;
          case 'expired':
            MyToasts().showNormal('expired');
            break;
        }
      },
    );
  }

  logout() {
    if (state == null) {
      print('Not logged in');
      return;
    }

    SocketManager()
        .getSocket()
        .emit('logout', [state!.userName!, state!.email!]);

    state = null;
  }

  getMember(
      {required String email,
      required Function(int, int, String) successFunc}) {
    SocketManager().getSocket().emit('member', email);
    SocketManager().getSocket().once(
      'memberResult',
      (data) {
        // AuthModel temp = AuthModel.fromJson(jsonDecode(data));
        // temp.email = email;
        state = AuthModel.fromJson(jsonDecode(data));
        successFunc(state!.accountNo!, state!.companyNo!, email);

        final SharedPreferencesAsync asyncShare = SharedPreferencesAsync();
        asyncShare.setString('email', email);
        asyncShare.setInt('accountNo', state!.accountNo!);
      },
    );
  }

  // forgotEmail({required String hp, required Function(String) successFunc}) {
  //   SocketManager().getSocket().emit('forgotAccount', hp);
  //   SocketManager().getSocket().once(
  //     'resultForgotAccount',
  //     (data) {
  //       if (data[0] == 'Success') {
  //         successFunc(data[1]);
  //       } else {
  //         MyToasts().showNormal('Confirm to account in members.');
  //       }
  //     },
  //   );
  // }

  // forgotPassword({required String email, required Function() successFunc}) {
  //   SocketManager().getSocket().emit('pwCertificationRequest', email);
  //   SocketManager().getSocket().once(
  //     'pwCertificationRequest',
  //     (data) {
  //       if (data[0] == 'Success') {
  //         successFunc();
  //       } else {
  //         MyToasts().showNormal('Please check E-mail.');
  //       }
  //     },
  //   );
  // }

  // changePassword(
  //     {required String email,
  //     required String pw,
  //     required Function() successFunc}) {
  //   SocketManager().getSocket().emit('changePassword', [pw, email]);
  //   SocketManager().getSocket().once(
  //     'changePasswordRequest',
  //     (data) {
  //       if (data == 'Success') {
  //         successFunc();
  //       } else {
  //         MyToasts().showNormal('Change password fail');
  //       }
  //     },
  //   );
  // }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthModel?>((ref) => AuthViewModel());
