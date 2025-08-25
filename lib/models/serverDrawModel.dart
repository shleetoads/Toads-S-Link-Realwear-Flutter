class ServerDrawModel {
  String? meetId;

  double? posX;
  double? posY;
  double? size;
  String? color;
  String? senderSocketId;
  String? drawingPosition;
  double? sizeX;
  double? sizeY;

  ServerDrawModel(
      {required this.meetId,
      required this.posX,
      required this.posY,
      required this.size,
      required this.color,
      required this.senderSocketId,
      required this.drawingPosition,
      required this.sizeX,
      required this.sizeY});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['meet_id'] = meetId;
    data['posX'] = posX;
    data['posY'] = posY;
    data['size'] = size;
    data['color'] = color;
    data['senderSocketId'] = senderSocketId;
    data['drawingPosition'] = drawingPosition;
    data['sizeX'] = sizeX;
    data['sizeY'] = sizeY;

    return data;
  }
}
