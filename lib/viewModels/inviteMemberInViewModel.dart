import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/authModel.dart';

class InviteMemberInViewModel extends StateNotifier<List<AuthModel>> {
  InviteMemberInViewModel() : super([]);

  getUninviteMemberList(
      {required String meetId,
      required int companyNo,
      required Function successFunc}) {
    SocketManager().getSocket().emit('getUninvitedUsers', [meetId, companyNo]);
    SocketManager().getSocket().once(
      'getUninvitedUsers',
      (data) {
        state = jsonDecode(data)
            .map<AuthModel>((json) => AuthModel.fromJson(json))
            .toList();

        successFunc();
      },
    );

    SocketManager().getSocket().once(
      'Nooneisuninvited',
      (data) {
        state = [];
      },
    );
  }
}

final inviteMemberInViewModelProvider =
    StateNotifierProvider<InviteMemberInViewModel, List<AuthModel>>(
        (ref) => InviteMemberInViewModel());
