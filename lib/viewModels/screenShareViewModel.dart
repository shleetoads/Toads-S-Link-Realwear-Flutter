import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/screenShareModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class ScreenShareViewModel extends StateNotifier<ScreenShareModel?> {
  ScreenShareViewModel() : super(null);

  screenShareOn(
      {required String userName,
      required int accountNo,
      required String meetId}) {
    SocketManager().getSocket().emit("screenShareOn", {
      'senderSocketId': SocketManager().getSocket().id,
      'user_name': userName,
      'account_no': accountNo,
      'meet_id': meetId,
    });
  }

  screenShareOff({required int accountNo, required String meetId}) {
    SocketManager().getSocket().emit(
        "screenShareOff", [meetId, SocketManager().getSocket().id, accountNo]);
  }

  onScreenShare() {
    SocketManager().getSocket().on(
      'screenShareOn',
      (data) {
        init(
            model: ScreenShareModel(
          socketId: data[0].toString(),
          userName: data[1].toString(),
          accountNo: int.parse(data[2].toString()),
          justZoom: false,
        ));
      },
    );

    SocketManager().getSocket().on(
      'screenShareOff',
      (data) {
        init();
      },
    );
  }

  checkScreenShare({required String meetId}) {
    SocketManager().getSocket().emit('CheckScreenShare', meetId);
    SocketManager().getSocket().once(
      'CheckScreenShare',
      (data) {
        logger.i('CheckScreenShare');
        logger.i(data);
        init(
            model: ScreenShareModel(
          socketId: data[0].toString(),
          userName: data[1].toString(),
          accountNo: int.parse(data[2].toString()),
          justZoom: false,
        ));
      },
    );
  }

  init({ScreenShareModel? model}) {
    state = model;
  }
}

final screenShareViewModelProvider =
    StateNotifierProvider<ScreenShareViewModel, ScreenShareModel?>(
        (ref) => ScreenShareViewModel());
