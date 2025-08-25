import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class InviteMemberViewModel extends StateNotifier<List<AuthModel>> {
  InviteMemberViewModel() : super([]);

  getMemberList({required int companyNo, required String email}) {
    SocketManager().getSocket().emit('getContacts', [companyNo, email]);
    SocketManager().getSocket().once(
      'getContacts',
      (data) {
        logger.i(data);

        state = jsonDecode(data)
            .map<AuthModel>((json) => AuthModel.fromJson(json))
            .toList();
      },
    );
  }
}

final inviteMemberViewModelProvider =
    StateNotifierProvider<InviteMemberViewModel, List<AuthModel>>(
        (ref) => InviteMemberViewModel());
