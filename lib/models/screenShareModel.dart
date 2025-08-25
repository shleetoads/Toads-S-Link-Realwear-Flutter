class ScreenShareModel {
  String? socketId;
  String? userName;
  int? accountNo;
  bool? justZoom;

  ScreenShareModel(
      {required this.socketId,
      required this.userName,
      required this.accountNo,
      required this.justZoom});
}
