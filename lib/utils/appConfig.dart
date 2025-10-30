import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

var logger = Logger();

class AppConfig {
  // static const String AGORA_APP_ID = 'fb577829c5924076b1f7cf5427b88b44';

  // static const String BASE_URL = 'https://server.toads.kr';

  // static const String AOS_DCIM_PATH =
  //     '/storage/emulated/0/DCIM/ToadsSLinkRealwear';
  // static const String AOS_DOCS_PATH =
  //     '/storage/emulated/0/Documents/ToadsSLinkRealwear';

  static String INTERNAL_URL = '';

  static bool isExternal = true;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> requestAllPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.ignoreBatteryOptimizations,
      Permission.microphone,
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request(); // 여러 권한을 동시에 요청
  }

  static changeToLandscape() async {
    await SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  static hideStatusNavigationBar() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}
