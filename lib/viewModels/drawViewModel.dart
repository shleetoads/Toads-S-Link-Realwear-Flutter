import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/serverDrawModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';

class DrawViewModel extends StateNotifier<ServerDrawModel?> {
  DrawViewModel() : super(null);

  drawStart({required ServerDrawModel model}) {
    SocketManager().getSocket().emit('drawStart', model.toJson());
  }

  draw({required ServerDrawModel model}) {
    logger.i(model.toJson());
    SocketManager().getSocket().emit('draw', model.toJson());
  }

  drawEnd({required ServerDrawModel model}) {
    SocketManager().getSocket().emit('drawEnd', model.toJson());
  }

  drawClear({required String meetId}) {
    SocketManager().getSocket().emit('drawClear',
        {'senderSocketId': SocketManager().getSocket().id, 'meet_id': meetId});
  }

  onDraw({required Function(String) drawClearFunction}) {
    SocketManager().getSocket().on(
      'drawStart',
      (data) {
        if (data[4] != SocketManager().getSocket().id) {
          state = ServerDrawModel(
            meetId: null,
            posX: data[0] is int ? data[0].toDouble() : data[0],
            posY: data[1] is int ? data[1].toDouble() : data[1],
            size: data[2],
            color: data[3],
            senderSocketId: data[4],
            drawingPosition: data[5],
            sizeX: data[6] is int ? data[6].toDouble() : data[6],
            sizeY: data[7] is int ? data[7].toDouble() : data[7],
          );
        }
      },
    );

    SocketManager().getSocket().on(
      'draw',
      (data) {
        if (data[2] != SocketManager().getSocket().id) {
          logger.i(data);

          state = ServerDrawModel(
            meetId: null,
            posX: data[0] is int ? data[0].toDouble() : data[0],
            posY: data[1] is int ? data[1].toDouble() : data[1],
            size: data[5],
            color: data[6],
            senderSocketId: data[2],
            drawingPosition: data[7],
            sizeX: data[3] is int ? data[3].toDouble() : data[3],
            sizeY: data[4] is int ? data[4].toDouble() : data[4],
          );
        }
      },
    );

    SocketManager().getSocket().on(
      'drawEnd',
      (data) {
        logger.e(data);

        if (data[0] != SocketManager().getSocket().id) {
          state = ServerDrawModel(
            meetId: null,
            posX: null,
            posY: null,
            size: null,
            color: null,
            senderSocketId: data[0],
            drawingPosition: data[1],
            sizeX: null,
            sizeY: null,
          );
        }
      },
    );

    SocketManager().getSocket().on(
      'drawClear',
      (data) {
        if (data != SocketManager().getSocket().id) {
          drawClearFunction(data);
        }
      },
    );
  }

  init() {
    state = null;
  }
}

final drawViewModelProvider =
    StateNotifierProvider<DrawViewModel, ServerDrawModel?>(
        (ref) => DrawViewModel());
