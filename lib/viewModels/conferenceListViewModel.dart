import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/conferenceModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class ConferenceListViewModel extends StateNotifier<List<ConferenceModel>> {
  ConferenceListViewModel() : super([]);

  getConferenceList({required int accountNo}) {
    SocketManager().getSocket().emit('getConferences', accountNo.toString());
  }

  onRepleshConferenceList({required int accountNo}) {
    SocketManager().getSocket().on(
      'refreshRoomList',
      (data) {
        print('onRepleshConferenceList');
        getConferenceList(accountNo: accountNo);
      },
    );

    SocketManager().getSocket().on(
      'getConferences',
      (data) {
        logger.e(data);
        List<ConferenceModel> tempList = jsonDecode(data)
            .map<ConferenceModel>((json) => ConferenceModel.fromJson(json))
            .toList();

        state = tempList;
      },
    );
  }
}

final conferenceListViewModelProvider =
    StateNotifierProvider<ConferenceListViewModel, List<ConferenceModel>>(
        (ref) => ConferenceListViewModel());
