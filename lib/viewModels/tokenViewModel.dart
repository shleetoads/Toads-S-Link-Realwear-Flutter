import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class TokenViewModel extends StateNotifier<String?> {
  TokenViewModel() : super(null);

  //자기가 처음 입장할때 토큰 및 채널 생성해서 입장
  createToken(
      {required String meetId,
      required int accountNo,
      required Function(String) successFunc}) {
    SocketManager().getSocket().emit('createToken', [meetId, accountNo]);
    SocketManager().getSocket().once(
      'createTokenResult',
      (token) {
        state = token;
        logger.i('agoraToken : $token');
        successFunc(token);
      },
    );
  }
}

final tokenViewModelProvider =
    StateNotifierProvider<TokenViewModel, String?>((ref) => TokenViewModel());
