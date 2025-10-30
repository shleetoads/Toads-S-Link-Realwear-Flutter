import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeNetworkCreateRoomViewModel extends StateNotifier<bool?> {
  ChangeNetworkCreateRoomViewModel() : super(false);

  setValue(bool? value) {
    state = value;
  }
}

final changeNetworkCreateRoomViewModelProvider =
    StateNotifierProvider<ChangeNetworkCreateRoomViewModel, bool?>(
        (ref) => ChangeNetworkCreateRoomViewModel());
