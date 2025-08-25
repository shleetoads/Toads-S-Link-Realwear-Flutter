import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/chatModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class AlarmChatModel {
  bool alarm = false;
  bool showChat = true;
  List<ChatModel> chatModel = [];

  AlarmChatModel(
      {required this.alarm, required this.showChat, required this.chatModel});

  AlarmChatModel copyWith({
    bool? alarm,
    bool? showChat,
    List<ChatModel>? chatModel,
  }) {
    return AlarmChatModel(
      alarm: alarm ?? this.alarm, // alarm이 null이면 기존 값 유지
      showChat: showChat ?? this.showChat,
      chatModel: chatModel ?? this.chatModel, // fileModel이 null이면 기존 값 유지
    );
  }
}

class ChatViewModel extends StateNotifier<AlarmChatModel> {
  ChatViewModel()
      : super(AlarmChatModel(alarm: false, showChat: true, chatModel: []));

  chat(
      {required String meetId,
      required int accountNo,
      required String message,
      required String color}) {
    SocketManager().getSocket().emit('new_chatting',
        [meetId, accountNo, message, color, SocketManager().getSocket().id]);
  }

  notice(
      {required String meetId,
      required int accountNo,
      required String message,
      required String color}) {
    SocketManager().getSocket().emit('new_notice',
        [meetId, accountNo, message, color, SocketManager().getSocket().id]);
  }

  onChat() {
    SocketManager().getSocket().on(
      'chatting',
      (data) {
        logger.i(data);

        List<ChatModel> tempList = [
          ...state.chatModel,
          ChatModel(
              sendMessage: data[0],
              color: data[1],
              socketId: data[2],
              sendTime: data[3])
        ];

        if (!state.showChat && state.chatModel.length < tempList.length) {
          state = state.copyWith(alarm: true, chatModel: tempList);
        } else {
          state = state.copyWith(alarm: false, chatModel: tempList);
        }
      },
    );
  }

  addLocalChat(
      {required String sendMessage,
      required String color,
      required String sendTime}) {
    List<ChatModel> tempList = [
      ...state.chatModel,
      ChatModel(
          sendMessage: sendMessage,
          color: color,
          socketId: '',
          sendTime: sendTime)
    ];

    if (!state.showChat && state.chatModel.length < tempList.length) {
      state = state.copyWith(alarm: true, chatModel: tempList);
    } else {
      state = state.copyWith(alarm: false, chatModel: tempList);
    }
  }

  setAlarm(bool alarm) {
    state = state.copyWith(alarm: alarm);
  }

  setShowChat(bool chat) {
    state = state.copyWith(showChat: chat);
  }

  init() {
    state = AlarmChatModel(alarm: false, showChat: true, chatModel: []);
  }
}

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, AlarmChatModel>(
        (ref) => ChatViewModel());
