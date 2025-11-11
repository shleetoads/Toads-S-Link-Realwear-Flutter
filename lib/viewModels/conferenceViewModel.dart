import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/models/conferenceModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class ConferenceViewModel extends StateNotifier<ConferenceModel?> {
  ConferenceViewModel() : super(null);

  createConference(
      {required String meetId,
      required int accountNo,
      required int companyNo,
      required String subject,
      required List<AuthModel> authList}) {
    SocketManager()
        .getSocket()
        .emit("CreateRoom", [meetId, accountNo, companyNo, subject]);

    SocketManager().getSocket().once(
      "createRoomSuccess",
      (data) {
        if (data == 'Success') {
          roomActive(
            meetId: meetId, /*accountNo: accountNo, companyNo: companyNo*/
          );

          invite(
            authList: authList,
            subject: subject,
            meetId: meetId,
            /*member_id: member_id,
            company_id: company_id*/
          );
        }
      },
    );
  }

  joinRoom(
      {required String meetId,
      required int accountNo,
      required String userName,
      required int companyNo,
      required Function successFunc,
      required Function failFunc}) {
    SocketManager().getSocket().emit("joinRoom", {
      'id': SocketManager().getSocket().id,
      'meet_id': meetId,
      'account_no': accountNo,
      'user_name': userName,
      'company_no': companyNo,
      'device': 'realwear',
    });
    SocketManager().getSocket().once(
      "CloseRoom",
      (data) {
        failFunc();
        //closeRoom
      },
    );

    SocketManager().getSocket().once(
      "OpenRoom",
      (data) {
        successFunc();
      },
    );
  }

  init({ConferenceModel? model}) {
    state = model;
  }

  getConference({required String meetId, Function(String?)? successFunc}) {
    SocketManager().getSocket().emit('getConference', meetId);
    SocketManager().getSocket().once(
      'getConference',
      (data) {
        logger.e(data);
        state = ConferenceModel.fromJson(jsonDecode(data));
        if (successFunc != null) successFunc(state!.closeYn);
      },
    );
  }

  getUser(
      {required String meetId,
      required int accountNo,
      required Function(String, int, String, String) successFunc}) {
    logger.i('getUser');
    SocketManager().getSocket().emit('getUser', [meetId, accountNo]);
    SocketManager().getSocket().once(
      'getUser_$accountNo',
      (data) {
        logger.i(data);

        successFunc(data[0].toString(), int.parse(data[1].toString()),
            data[2].toString(), data[3]);
      },
    );
  }

  invite({
    required List<AuthModel> authList,
    required String subject,
    required String meetId,
    /*required int member_id,
      required int company_id*/
  }) {
    SocketManager().getSocket().emit("invite", [
      jsonEncode(authList.map((authModel) => authModel.toJson()).toList()),
      subject,
      meetId,
      // member_id,
      // company_id
    ]);
  }

  roomActive({
    required String meetId,
    /*required int accountNo,
      required int companyNo*/
  }) {
    SocketManager().getSocket().emit("roomActive", {
      'meet_id': meetId,
      // 'account_no': accountNo,
      // 'company_no': companyNo,
    });
  }

  exitRoom({required int accountNo, required int companyNo}) {
    SocketManager().getSocket().emit("exitRoom", [
      state?.meetId,
      accountNo,
      // companyNo,
    ]);
  }
}

final conferenceViewModelProvider =
    StateNotifierProvider<ConferenceViewModel, ConferenceModel?>(
        (ref) => ConferenceViewModel());
