import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lepsi_rw_speech_recognizer/lepsi_rw_speech_recognizer.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/views/conferenceDetailView.dart';
import 'package:realwear_flutter/views/conferenceView.dart';
import 'package:realwear_flutter/views/internal/internalConferenceView.dart';
import 'package:realwear_flutter/views/internal/internalDetailView.dart';
import 'package:realwear_flutter/views/internal/internalIpView.dart';
import 'package:realwear_flutter/views/inviteMemberInView.dart';
import 'package:realwear_flutter/views/inviteMemberView.dart';
import 'package:realwear_flutter/views/selectNetworkView.dart';
import 'package:realwear_flutter/views/signInView.dart';
import 'package:realwear_flutter/views/splashView.dart';
import 'package:realwear_flutter/widgets/internalIpDialog.dart';
import 'package:realwear_flutter/widgets/selectNetworkDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await AppConfig.changeToLandscape();
  await AppConfig.hideStatusNavigationBar();

  WakelockPlus.enable();

  //네트워크 변경 아직 업데이트 안함 밑은 지워야함
  // SocketManager().connect(dotenv.env['BASE_URL']!);

  await AppConfig.requestAllPermissions();

  runApp(ProviderScope(child: MyApp()));
}

final GoRouter goRouter = GoRouter(
  navigatorKey: AppConfig.navigatorKey,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashView()),
    GoRoute(path: '/signin', builder: (context, state) => const SignInView()),
    GoRoute(
        path: '/conference',
        builder: (context, state) => const ConferenceView()),
    GoRoute(
        path: '/invite', builder: (context, state) => const InviteMemberView()),
    GoRoute(
        path: '/invite/in',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return InviteMemberInView(
            meetId: data['meetId'],
            subject: data['subject'],
          );
        }),
    GoRoute(
      path: '/conference/detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ConferenceDetailView(
          token: data['token'],
          meetId: data['meetId'],
          accountNo: data['accountNo'],
          companyNo: data['companyNo'],
        );
      },
    ),
    GoRoute(
        path: '/internal/ip',
        builder: (context, state) {
          return InternalIpView();
        }),
    GoRoute(
        path: '/internal/conference',
        builder: (context, state) {
          return InternalConferenceView();
        }),
    GoRoute(
        path: '/internal/detail',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return InternalDetailView(
            meetId: data['meetId'],
            accountNo: data['accountNo'],
            companyNo: data['companyNo'],
          );
        }),
    GoRoute(
      path: '/network',
      builder: (context, state) {
        return SelectNetworkView();
      },
    ),
    GoRoute(
      path: '/dialog/network',
      builder: (context, state) {
        final isInRoom = state.uri.queryParameters['isInRoom'] == 'true';
        final leaveFunc = state.extra as Future<void> Function()?;

        return SelectNetworkDialog(
          isInRoom: isInRoom,
          leaveFunc: leaveFunc,
        );
      },
    ),
    GoRoute(
      path: '/dialog/internal/ip',
      builder: (context, state) {
        final isInRoom = state.uri.queryParameters['isInRoom'] == 'true';
        final leaveFunc = state.extra as Future<void> Function()?;

        return InternalIpDialog(
          isInRoom: isInRoom,
          leaveFunc: leaveFunc,
        );
      },
    ),
  ],
  //네트워크 변경
  initialLocation: '/network',
  // initialLocation: '/',
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    localeCheck(ref);

    return GlobalLoaderOverlay(
      overlayColor: Colors.grey.withOpacity(0.2),
      overlayWidgetBuilder: (_) {
        return Center(
          child: Image.asset(
            'assets/images/loading.gif',
            width: 200,
            height: 200,
          ),
        );
      },
      child: MaterialApp.router(
        title: 'S-Link-Realwear',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: MyColors.primary),
          useMaterial3: true,
          fontFamily: 'Pretendard',
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: goRouter,
      ),
    );
  }

  localeCheck(WidgetRef ref) async {
    final asyncShared = SharedPreferencesAsync();
    String locale = await asyncShared.getString("locale") ?? "KOR";
    ref.read(localeViewModelProvider.notifier).setLocale(locale);
  }
}
