import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:screenshot/screenshot.dart';

class UserModel {
  String? id;
  String? memberId;
  String? name;
  bool? isWebCamAvailable;

  RTCPeerConnection? peer;
  RTCVideoRenderer? remoteRenderer;

  ScreenshotController screenshotController = ScreenshotController();

  UserModel({required this.id, required this.name, required this.memberId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      memberId: json['member_id'],
    );
  }
}
