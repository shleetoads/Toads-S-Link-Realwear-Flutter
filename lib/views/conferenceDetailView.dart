import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:go_router/go_router.dart';
import 'package:lepsi_rw_speech_recognizer/lepsi_rw_speech_recognizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/models/chatModel.dart';
import 'package:realwear_flutter/models/conferenceModel.dart';
import 'package:realwear_flutter/models/drawModel.dart';
import 'package:realwear_flutter/models/screenShareModel.dart';
import 'package:realwear_flutter/models/serverDrawModel.dart';
import 'package:realwear_flutter/models/userModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myLoading.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/utils/signaturePainter.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/chatViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceViewModel.dart';
import 'package:realwear_flutter/viewModels/drawViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberInViewModel.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/viewModels/screenShareViewModel.dart';
import 'package:realwear_flutter/widgets/normalAlertDialog.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class ConferenceDetailView extends ConsumerStatefulWidget {
  final String token;
  final String meetId;
  final int companyNo;
  final int accountNo;

  const ConferenceDetailView(
      {super.key,
      required this.token,
      required this.meetId,
      required this.companyNo,
      required this.accountNo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConferenceDetailViewState();
}

class _ConferenceDetailViewState extends ConsumerState<ConferenceDetailView>
    with WidgetsBindingObserver {
  final int _videoDimensionsWidth = 640;
  final int _videoDimensionsHeight = 480;

  double _scale = 1.0;

  Map<int, bool> videoMap = {};
  final List<int> _remoteUidList = []; // The UID of the remote user
  Map<int, UserModel> usersMap = {};

  final List<DrawModel> _drawPoints = [];

  bool _localUserJoined =
      false; // Indicates whether the local user has joined the channel
  late RtcEngine _engine; // The RtcEngine instances
  late MediaEngine _mediaEngine;
  final bool _myANC = true;
  bool _myAudio = true;
  bool isFlash = false;
  bool isAmp = false;

  bool _showChat = false;

  final GlobalKey _screenSizeKey = GlobalKey();

  bool _isMenuVisible = false;

  bool _recording = false;
  bool _recordLoading = false;
  Timer? _recordTimer;
  int _recordTime = 0;

  final _chatScrollController = ScrollController();
  final _screenshotController = ScreenshotController();

  bool localKr = true;

  final double _scaleSize = 35;

  inputDrawPoint(
      ServerDrawModel next, GlobalKey key, List<DrawModel> drawModelList) {
    if (key.currentContext == null) {
      return;
    }

    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final mySize = renderBox.size;

    Offset offset;

    // 여기서 id 마다 넣어야해

    if (next.posX == null || next.posY == null) {
      offset = Offset.zero;

      setState(() {
        drawModelList.add(DrawModel(
            point: offset,
            color: Colors.white,
            strokeWidth: 0,
            socketId: next.senderSocketId!));
      });
    } else {
      offset = Offset(mySize.width * next.posX! / next.sizeX!,
          mySize.height * next.posY! / next.sizeY!);

      // List<String> rgbValues = next.color!.split(',');
      Map<String, dynamic> colorData = jsonDecode(next.color!);
      // logger.i(next.color!);
      logger.i(offset.dx);
      logger.i(offset.dy);

      setState(() {
        drawModelList.add(DrawModel(
            point: offset,
            color: Color.fromARGB(
              (colorData['a'] * 255).toInt(),
              (colorData['r'] * 255).toInt(),
              (colorData['g'] * 255).toInt(),
              (colorData['b'] * 255).toInt(),
            ),
            strokeWidth: serverToSize(next.size!),
            socketId: next.senderSocketId!));
      });
    }
  }

  double serverToSize(double size) {
    switch (size) {
      case 0.003:
        return 1.0;
      case 0.006:
        return 2.0;
      case 0.009:
        return 3.0;
      case 0.012:
        return 4.0;
      case 0.015:
        return 5.0;
      default:
        return 0.0;
    }
  }

  @override
  void initState() {
    localKr = ref.read(localeViewModelProvider) == 'KOR';

    rw();
    super.initState();

    WidgetsBinding.instance.addObserver(this); // 옵저버 등록

    initAgora();

    ref.read(screenShareViewModelProvider.notifier).onScreenShare();

    ref.read(chatViewModelProvider.notifier).onChat();

    ref.read(drawViewModelProvider.notifier).onDraw(
      drawClearFunction: (socketId) {
        setState(() {
          _drawPoints.removeWhere((model) => model.socketId == socketId);
        });
      },
    );

    //혹시나해서
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await Future.delayed(const Duration(seconds: 2));
    //   // rw();
    // });
  }

  rw() {
    LepsiRwSpeechRecognizer.setCommands(<String>[
      '방 나가기',
      'Leave Room',
      '초대하기',
      'Invite',
      '플래시 켜기',
      'Flash On',
      '플래시 끄기',
      'Flash Off',
      '화면녹화 켜기',
      'Screen Recording On',
      '화면녹화 끄기',
      'Screen Recording Off',
      '메뉴 열기',
      'Show Menu',
      '메뉴 닫기',
      'Hide Menu',
      '화면공유 켜기',
      'Screen Share On',
      '화면공유 끄기',
      'Screen Share Off',
      '마이크 켜기',
      'Mike On',
      '마이크 끄기',
      'Mike Off',
      '사진 저장',
      'Capture',
      '채팅 켜기',
      'Chat On',
      '채팅 끄기',
      'Chat Off',
      '배율 1',
      'Zoom One',
      '배율 2',
      'Zoom Two',
      '배율 3',
      'Zoom Three',
      '배율 4',
      'Zoom Four',
      '배율 5',
      'Zoom Five',
      '뒤로가기',
      'Navigate Back',
      '네트워크 전환',
      'Change Network',
    ], (command) async {
      logger.i(command);
      switch (command) {
        case '방 나가기':
        case '뒤로가기':
        case 'Leave Room':
        case 'Navigate Back':
          _leaveFunc();
          break;
        case '초대하기':
        case 'Invite':
          // await LepsiRwSpeechRecognizer.restoreCommands();
          ConferenceModel? model = ref.read(conferenceViewModelProvider);
          AuthModel authModel = ref.read(authViewModelProvider)!;
          ref
              .read(inviteMemberInViewModelProvider.notifier)
              .getUninviteMemberList(
                meetId: model!.meetId!,
                companyNo: authModel.companyNo!,
                successFunc: () {
                  context.push('/invite/in', extra: {
                    'meetId': model.meetId,
                    'subject': model.subject,
                  }).then(
                    (value) async {
                      if (value == null) {
                        await Future.delayed(const Duration(milliseconds: 500));
                        rw();
                      }
                    },
                  );
                },
              );

          break;
        case '플래시 켜기':
        case 'Flash On':
          if (isFlash) {
            break;
          }
          ScreenShareModel? screenShareModel =
              ref.read(screenShareViewModelProvider);
          flash(screenShareModel);
          await Future.delayed(const Duration(milliseconds: 1500));
          rw();
          break;
        case '플래시 끄기':
        case 'Flash Off':
          if (!isFlash) {
            break;
          }
          ScreenShareModel? screenShareModel =
              ref.read(screenShareViewModelProvider);
          flash(screenShareModel);
          break;
        case '화면녹화 켜기':
        case 'Screen Recording On':
          if (_recording) {
            break;
          }
          _record();
          break;
        case '화면녹화 끄기':
        case 'Screen Recording Off':
          if (!_recording) {
            break;
          }
          _record();
          break;
        case '메뉴 열기':
        case 'Show Menu':
          setState(() {
            _isMenuVisible = true;
          });
          break;
        case '메뉴 닫기':
        case 'Hide Menu':
          setState(() {
            _isMenuVisible = false;
          });
          break;
        case '화면공유 켜기':
        case 'Screen Share On':
          ScreenShareModel? screenShareModel =
              ref.read(screenShareViewModelProvider);
          if (screenShareModel != null) {
            break;
          }
          AuthModel authModel = ref.read(authViewModelProvider)!;
          share(screenShareModel, authModel);
          break;
        case '화면공유 끄기':
        case 'Screen Share Off':
          ScreenShareModel? screenShareModel =
              ref.read(screenShareViewModelProvider);
          AuthModel authModel = ref.read(authViewModelProvider)!;

          if (screenShareModel != null &&
              screenShareModel.accountNo == authModel.accountNo) {
            share(screenShareModel, authModel);
          }
          break;
        case '마이크 켜기':
        case 'Mike On':
          if (_myAudio) break;
          await _engine.muteLocalAudioStream(_myAudio);

          setState(() {
            _myAudio = !_myAudio;
          });
          break;
        case '마이크 끄기':
        case 'Mike Off':
          if (!_myAudio) break;
          await _engine.muteLocalAudioStream(_myAudio);

          setState(() {
            _myAudio = !_myAudio;
          });
          break;
        case '사진 저장':
        case 'Capture':
          capture();
          break;
        case '채팅 켜기':
        case 'Chat On':
          setState(() {
            _showChat = true;
          });
          break;
        case '채팅 끄기':
        case 'Chat Off':
          setState(() {
            _showChat = false;
          });
          break;
        case '배율 1':
        case 'Zoom One':
          setState(() {
            _scale = 1.0;
          });
          await _engine.setCameraZoomFactor(_scale);
          break;
        case '배율 2':
        case 'Zoom Two':
          setState(() {
            _scale = 2.0;
          });
          await _engine.setCameraZoomFactor(_scale);
          break;
        case '배율 3':
        case 'Zoom Three':
          setState(() {
            _scale = 3.0;
          });
          await _engine.setCameraZoomFactor(_scale);
          break;
        case '배율 4':
        case 'Zoom Four':
          setState(() {
            _scale = 4.0;
          });
          await _engine.setCameraZoomFactor(_scale);
          break;
        case '배율 5':
        case 'Zoom Five':
          setState(() {
            _scale = 5.0;
          });
          await _engine.setCameraZoomFactor(_scale);
          break;

        case '네트워크 전환':
        case 'Change Network':
          context.push(
            '/dialog/network?isInRoom=true',
            extra: () async {
              await _leaveFunc();
            },
          ).then(
            (value) {
              rw();
            },
          );
          break;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 💡 앱이 포그라운드로 돌아왔을 때
        // 멈춘 스트림을 재개하는 로직을 실행합니다.
        logger.i('resumed');
        rw();
        break;
      case AppLifecycleState.inactive:
        // 💡 비활성화(iOS/Android 백그라운드 진입 직전) 상태
        // 필요한 경우 일시 정지 로직을 추가할 수 있습니다.
        logger.i('inactive');

        break;
      case AppLifecycleState.paused:
        // 💡 앱이 백그라운드 상태가 되었을 때
        // Android에서는 여기서 포그라운드 서비스 시작 등을 고려합니다.
        logger.i('paused');

        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // 앱이 종료되었거나 숨겨졌을 때 (필요한 리소스 해제)
        break;
    }
  }

  Future<void> _dispose() async {
    if (_recording) {
      String path = await FlutterScreenRecording.stopRecordScreen;
      // MyToasts().showNormal('Stop Record Screen');

      logger.i(path);

      await stopRecording();

      //storage/emulated/0/Android/data/com.toads.toadsslink.flutter/cache/739e716b-c4a4-42b8-93af-d2c946444975.mp4

      Directory directory = await getApplicationDocumentsDirectory();

      File tempFile = File(path);
      File resultFile = File('${directory.path}/${p.basename(path)}');

      //카피해주고 기존꺼 지우고

      resultFile.writeAsBytesSync(tempFile.readAsBytesSync());
      Directory(tempFile.path).deleteSync(recursive: true);

      String? mergeFile = await mergeAudioAndVideo(
          resultFile.path, '${directory.path}/remote_audio.wav');

      if (Platform.isAndroid) {
        const MethodChannel channel = MethodChannel('ToadsSLink');
        await channel.invokeMethod('refreshMedia', {"path": mergeFile});
      }

      logger.i(resultFile.path);

      MyToasts().showNormal("Saved in '${resultFile.path}'");
    }

    SocketManager().getSocket().off('screenShareOn');
    SocketManager().getSocket().off('screenShareOff');

    SocketManager().getSocket().off('chatting');

    SocketManager().getSocket().off('drawStart');
    SocketManager().getSocket().off('draw');
    SocketManager().getSocket().off('drawEnd');
    SocketManager().getSocket().off('drawClear');

    await _engine.setupLocalVideo(const VideoCanvas(uid: 0, view: null));

    // remote 비디오 해제
    // for (final uid in _remoteUidList) {
    //   await _engine.setupRemoteVideo(VideoCanvas(uid: uid, view: null));
    // }
    // Leave the channel
    await _engine.leaveChannel();
    // Release resources
    await _engine.release();
  }

  Future<void> initAgora() async {
    // ref.read(conferenceVadViewModelProvider.notifier).init();

    // Create RtcEngine instance
    _engine = createAgoraRtcEngine();

    // Initialize RtcEngine and set the channel profile to live broadcasting
    await _engine.initialize(RtcEngineContext(
      appId: dotenv.env['AGORA_APP_ID']!,
      channelProfile: ChannelProfileType.channelProfileCommunication,
      areaCode: 4,
    ));

    // Add an event handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onLastmileProbeResult: (result) async {
          logger.f(result.state);

          if (result.state ==
              LastmileProbeResultState.lastmileProbeResultComplete) {
            joinAgora();
          } else if (result.state ==
              LastmileProbeResultState.lastmileProbeResultUnavailable) {
            await _engine.setCloudProxy(CloudProxyType.udpProxy);
            joinAgora();
          }
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          logger.i(reason.index);
          logger.i(reason.name);

          if (reason.index == 5 &&
              reason.name == 'remoteVideoStateReasonRemoteMuted') {
            //상대방 비디오 뮤트함
            setState(() {
              videoMap[remoteUid] = false;
            });

            ScreenShareModel? model = ref.read(screenShareViewModelProvider);
            if (model != null &&
                model.accountNo == remoteUid &&
                model.justZoom == true) {
              ref.read(screenShareViewModelProvider.notifier).init();
            }
          } else if (reason.index == 6 &&
              reason.name == 'remoteVideoStateReasonRemoteUnmuted') {
            //상대방 비디오 뮤트풀었을때
            setState(() {
              videoMap[remoteUid] = true;
            });
          }
        },

        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
          });

          int accountNo = ref.read(authViewModelProvider)!.accountNo!;
          ref.read(conferenceViewModelProvider.notifier).getUser(
                meetId: widget.meetId,
                accountNo: accountNo,
                successFunc: (id, accountNo, userName, device) {
                  usersMap[accountNo] = UserModel(
                    id: id,
                    accountNo: accountNo,
                    userName: userName,
                    device: device,
                  );

                  setState(() {});
                },
              );
        },
        // Occurs when a remote user join the channel
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");

          _remoteUidList.add(remoteUid);
          videoMap[remoteUid] = true;

          ref.read(conferenceViewModelProvider.notifier).getUser(
                meetId: widget.meetId,
                accountNo: remoteUid,
                successFunc: (id, accountNo, userName, device) {
                  usersMap[remoteUid] = UserModel(
                    id: id,
                    accountNo: accountNo,
                    userName: userName,
                    device: device,
                  );

                  logger.e(accountNo);
                  logger.e(id);
                  logger.e(device);

                  setState(() {});

                  DateTime now = DateTime.now().toUtc();

                  ref.read(chatViewModelProvider.notifier).addLocalChat(
                      sendTime:
                          '${(now.hour).toString().padLeft(2, '0')}:${(now.minute).toString().padLeft(2, '0')}',
                      sendMessage: "$userName has join the room.",
                      color: jsonEncode({
                        'r': 0,
                        'g': 255,
                        'b': 30,
                        'a': 255,
                      }));
                },
              );

          setState(() {});
        },
        // Occurs when a remote user leaves the channel
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          logger.e("remote user $remoteUid left channel");

          await _engine
              .setupRemoteVideo(VideoCanvas(uid: remoteUid, view: null));

          _remoteUidList.remove(remoteUid);
          videoMap.remove(remoteUid);

          ScreenShareModel? screenShareModel =
              ref.read(screenShareViewModelProvider);
          if (screenShareModel != null &&
              screenShareModel.accountNo == remoteUid) {
            ref.read(screenShareViewModelProvider.notifier).init();
          }

          DateTime now = DateTime.now().toUtc();

          ref.read(chatViewModelProvider.notifier).addLocalChat(
              sendTime:
                  '${(now.hour).toString().padLeft(2, '0')}:${(now.minute).toString().padLeft(2, '0')}',
              sendMessage:
                  "${usersMap[remoteUid]?.userName} has left the room.",
              color: jsonEncode({
                'r': 0,
                'g': 255,
                'b': 30,
                'a': 255,
              }));

          usersMap.remove(remoteUid);

          setState(() {});

          Future.delayed(const Duration(seconds: 2)).then(
            (value) {
              if (!mounted) return;
              ref
                  .read(conferenceViewModelProvider.notifier)
                  .getConference(meetId: widget.meetId);
            },
          );
        },

        // onCameraFocusAreaChanged: (x, y, width, height) {},
      ),
    );

    const config = LastmileProbeConfig();
    await _engine.startLastmileProbeTest(config);

    // 비디오 설정 구성
  }

  joinAgora() async {
    await _engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
      dimensions: VideoDimensions(
          width: _videoDimensionsWidth, height: _videoDimensionsHeight),
      frameRate: 15,
      codecType: VideoCodecType.videoCodecAv1,
      // bitrate: 500, // 비트레이트
    ));
    // Enable the video module
    await _engine.enableVideo();
    // Enable local video preview
    await _engine.startPreview();
    // Join a channel using a temporary token and channel name
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.meetId,
      options: const ChannelMediaOptions(
          // Automatically subscribe to all video streams
          autoSubscribeVideo: true,
          // Automatically subscribe to all audio streams
          autoSubscribeAudio: true,
          // Publish camera video
          publishCameraTrack: true,
          // Publish microphone audio
          publishMicrophoneTrack: true,
          // Set user role to clientRoleBroadcaster (broadcaster) or clientRoleAudience (audience)
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
      uid: widget
          .accountNo, // When you set uid to 0, a user name is randomly generated by the engine
    );

    await _engine.enableAudioVolumeIndication(
      interval: 200, // 200ms 간격
      smooth: 3, // 볼륨 변화 스무딩
      reportVad: true, // VAD 활성화
    );

    await _engine.setAINSMode(
        enabled: _myANC, mode: AudioAinsMode.ainsModeBalanced);

    _mediaEngine = _engine.getMediaEngine();

    afterAgora();

    MyLoading().hideLoading(context);
  }

  void afterAgora() async {
    await ref
        .read(screenShareViewModelProvider.notifier)
        .checkScreenShare(meetId: widget.meetId);

    rw();
  }

  @override
  Widget build(BuildContext context) {
    ConferenceModel? model = ref.watch(conferenceViewModelProvider);

    ScreenShareModel? screenShareModel =
        ref.watch(screenShareViewModelProvider);

    AuthModel authModel = ref.read(authViewModelProvider)!;

    List<ChatModel> chatModelList = ref.watch(chatViewModelProvider).chatModel;

    ref.listen(
      drawViewModelProvider,
      (previous, next) {
        if (next != null) {
          switch (next.drawingPosition) {
            case 'SHARING':
              inputDrawPoint(next, _screenSizeKey, _drawPoints);
              break;
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  key: _screenSizeKey,
                  child: !_localUserJoined
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4A90DC)),
                          ),
                        )
                      : Screenshot(
                          controller: _screenshotController,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double width = constraints.maxWidth;
                              final double height = constraints.maxHeight;

                              return CustomPaint(
                                foregroundPainter:
                                    SignaturePainter(_drawPoints),
                                size: Size(width, height), // 크기를 제한
                                child: AgoraVideoView(
                                  key: ValueKey(
                                      screenShareModel?.accountNo ?? 'local'),
                                  controller: screenShareModel == null ||
                                          screenShareModel.accountNo ==
                                              widget.accountNo
                                      ? VideoViewController(
                                          rtcEngine: _engine,
                                          canvas: const VideoCanvas(
                                            uid: 0,
                                            view: null,
                                            mirrorMode: VideoMirrorModeType
                                                .videoMirrorModeDisabled,
                                          ),
                                        )
                                      : VideoViewController.remote(
                                          rtcEngine: _engine,
                                          canvas: VideoCanvas(
                                            uid: screenShareModel.accountNo,
                                            view: null,
                                            mirrorMode: usersMap[
                                                            screenShareModel
                                                                .accountNo]
                                                        ?.device ==
                                                    'pc'
                                                ? VideoMirrorModeType
                                                    .videoMirrorModeEnabled
                                                : VideoMirrorModeType
                                                    .videoMirrorModeDisabled,
                                          ),
                                          connection: RtcConnection(
                                              channelId: widget.meetId),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),
            zoomWidget(),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
              curve: Curves.easeInOut, // 애니메이션 효과

              // _isMenuVisible 값에 따라 메뉴의 'bottom' 위치를 변경
              // true면 0(화면 맨 아래), false면 음수(화면 밖)
              bottom: _isMenuVisible ? 0 : -120,
              left: 0,
              right: 0,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    value: 'hf_no_number',
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _isMenuVisible = !_isMenuVisible;
                        });
                      },
                      child: Semantics(
                        value: 'hf_no_number',
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(left: 10, right: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFF141414).withOpacity(0.95),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isMenuVisible
                                    ? Icons.expand_more_rounded
                                    : Icons.expand_less_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                localKr
                                    ? '메뉴 ${_isMenuVisible ? '닫기' : '열기'}'
                                    : '${_isMenuVisible ? 'Hide' : 'Show'} Menu',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: localKr ? 18 : 16,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 120, // 메뉴의 높이
                      decoration: BoxDecoration(
                        color: Color(0xFF141414).withOpacity(0.95),
                      ),
                      child: Row(
                        children: [
                          Semantics(
                            value: 'hf_no_number',
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                share(screenShareModel, authModel);
                              },
                              child: Semantics(
                                value: 'hf_no_number',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/ic_cam.png',
                                        width: 30,
                                        height: 25,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        localKr
                                            ? '화면 공유 ${screenShareModel == null ? '켜기' : screenShareModel.accountNo == widget.accountNo ? '끄기' : '켜기'}'
                                            : 'Screen Share ${screenShareModel == null ? 'On' : screenShareModel.accountNo == widget.accountNo ? 'Off' : 'On'}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: localKr ? 18 : 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            value: 'hf_no_number',
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                await _engine.muteLocalAudioStream(_myAudio);

                                setState(() {
                                  _myAudio = !_myAudio;
                                });
                              },
                              child: Semantics(
                                value: 'hf_no_number',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        _myAudio
                                            ? 'assets/icons/ic_mic_on.png'
                                            : 'assets/icons/ic_mic_off.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        localKr
                                            ? '마이크 ${_myAudio ? '끄기' : '켜기'}'
                                            : 'Mic ${_myAudio ? 'Off' : 'On'}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: localKr ? 18 : 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            value: 'hf_no_number',
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                capture();
                              },
                              child: Semantics(
                                value: 'hf_no_number',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/ic_save.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        localKr ? '사진 저장' : 'Capture',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: localKr ? 18 : 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            value: 'hf_no_number',
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  _showChat = !_showChat;
                                });
                              },
                              child: Semantics(
                                value: 'hf_no_number',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/ic_chat.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        localKr
                                            ? '채팅 ${_showChat ? '끄기' : '켜기'}'
                                            : 'Chat ${_showChat ? 'Off' : 'On'}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: localKr ? 18 : 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            value: 'hf_no_number',
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  isAmp = !isAmp;
                                });
                              },
                              child: Semantics(
                                value: 'hf_no_number',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/ic_megaphone.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        localKr
                                            ? '증폭 ${isAmp ? '끄기' : '켜기'}'
                                            : 'Noise Boost ${isAmp ? 'Off' : 'On'}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: localKr ? 18 : 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: 5,
                          // ),
                          // VerticalDivider(
                          //   thickness: 2,
                          //   indent: 20,
                          //   endIndent: 20,
                          //   color: Color(0xFF666666),
                          // ),
                          // SizedBox(
                          //   width: 15,
                          // ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       localKr ? '배율' : 'Zoom',
                          //       style: TextStyle(
                          //           color: Colors.white,
                          //           fontSize: localKr ? 22 : 20,
                          //           fontWeight: FontWeight.w500),
                          //     ),
                          //     SizedBox(
                          //       width: 10,
                          //     ),
                          //     for (int i = 0; i < 5; i++) ...[
                          //       scaleWidget(i + 1),
                          //       SizedBox(
                          //         width: 10,
                          //       ),
                          //     ]
                          //   ],
                          // )
                        ],
                      )),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Semantics(
                    value: 'hf_no_number',
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(inviteMemberInViewModelProvider.notifier)
                            .getUninviteMemberList(
                              meetId: model!.meetId!,
                              companyNo: authModel.companyNo!,
                              successFunc: () {
                                context.push('/invite/in', extra: {
                                  'meetId': model.meetId,
                                  'subject': model.subject,
                                });
                              },
                            );
                      },
                      child: Semantics(
                        value: 'hf_no_number',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF767676).withOpacity(0.8),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/ic_invite.png',
                                width: 15,
                                height: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                localKr ? '초대하기' : 'Invite',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: localKr ? 18 : 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Semantics(
                    value: 'hf_no_number',
                    child: GestureDetector(
                      onTap: () async {
                        flash(screenShareModel);
                      },
                      child: Semantics(
                        value: 'hf_no_number',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF767676).withOpacity(0.8),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/ic_flash.png',
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                localKr
                                    ? '플래시 ${isFlash ? '끄기' : '켜기'}'
                                    : 'Flash ${isFlash ? 'Off' : 'On'}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: localKr ? 18 : 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Semantics(
                    value: 'hf_no_number',
                    child: GestureDetector(
                      onTap: _record,
                      child: Semantics(
                        value: 'hf_no_number',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF767676).withOpacity(0.8),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/ic_rec.png',
                                width: 18,
                                height: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                localKr
                                    ? '화면녹화 ${_recording ? '끄기' : '켜기'}'
                                    : 'Screen Recording ${_recording ? 'Off' : 'On'}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: localKr ? 18 : 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  if (!_showChat) ...[
                    //네트워크 변경
                    Semantics(
                      value: 'hf_no_number',
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            '/dialog/network?isInRoom=true',
                            extra: () async {
                              await _leaveFunc();
                            },
                          ).then(
                            (value) {
                              rw();
                            },
                          );
                        },
                        child: Semantics(
                          value: 'hf_no_number',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF767676).withOpacity(0.8),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/ic_network.png',
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  localKr ? '네트워크 전환' : 'Change Network',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: localKr ? 18 : 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Semantics(
                      value: 'hf_no_number',
                      child: GestureDetector(
                        onTap: _leaveFunc,
                        child: Semantics(
                          value: 'hf_no_number',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/ic_exit.png',
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  localKr ? '방 나가기' : 'Leave Room',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: localKr ? 18 : 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_showChat)
              Positioned(
                right: 0,
                top: 0,
                bottom: _isMenuVisible ? 120 : 0,
                child: Container(
                  width: 280,
                  color: Color(0xFF111111).withOpacity(0.8),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/ic_chat.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'CHAT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.5),
                      Expanded(
                          child: ListView.builder(
                        controller: _chatScrollController,
                        itemCount: chatModelList.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> colorData =
                              jsonDecode(chatModelList[index].color!);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${chatModelList[index].sendMessage}',
                                style: TextStyle(
                                    color: chatModelList[index].socketId! ==
                                                SocketManager()
                                                    .getSocket()
                                                    .id &&
                                            chatModelList[index].color !=
                                                jsonEncode({
                                                  'r': 0,
                                                  'g': 255,
                                                  'b': 30,
                                                  'a': 255,
                                                })
                                        ? Colors.white
                                        : Color.fromARGB(
                                            colorData['a'],
                                            colorData['r'],
                                            colorData['g'],
                                            colorData['b'],
                                          ),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                '${chatModelList[index].sendTime} (UTC)',
                                style: TextStyle(
                                    color: const Color(0xFFA8A8A8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          );
                        },
                      ))
                    ],
                  ),
                ),
              ),
            if (_recording)
              Positioned(
                left: 10,
                top: 50,
                child: Text(
                  _recordDuration(_recordTime),
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget zoomWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF323232).withOpacity(0.8),
            borderRadius: BorderRadius.circular(50),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i <= 5; i++) ...[
                Semantics(
                  value: 'hf_no_number',
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _scale = i.toDouble();
                      });

                      await _engine.setCameraZoomFactor(_scale);
                    },
                    child: Semantics(
                      value: 'hf_no_number',
                      child: Container(
                        width: _scaleSize,
                        height: _scaleSize,
                        decoration: BoxDecoration(
                            color: _scale == i.toDouble()
                                ? const Color(0xFFF2F2F2).withOpacity(0.42)
                                : Colors.transparent,
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${i}x',
                            style: TextStyle(
                              color: _scale == i.toDouble()
                                  ? Colors.white
                                  : const Color(0xFFA5A5A5),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  share(ScreenShareModel? screenShareModel, AuthModel authModel) async {
    if (screenShareModel == null) {
      await _engine.switchCamera();
      ref.read(screenShareViewModelProvider.notifier).screenShareOn(
          userName: authModel.userName!,
          accountNo: authModel.accountNo!,
          meetId: widget.meetId);
    } else if (screenShareModel.accountNo == widget.accountNo) {
      await _engine.switchCamera();
      ref.read(screenShareViewModelProvider.notifier).screenShareOff(
          accountNo: authModel.accountNo!, meetId: widget.meetId);
    } else {
      showDialog(
        context: context,
        builder: (context) => NormalAlertDialog(
          title: 'Another user is already sharing their screen.',
          btnTitle: 'OK',
          onTap: () {
            context.pop();
          },
        ),
      );
    }
  }

  capture() async {
    await _screenshotController
        .capture(delay: const Duration(milliseconds: 100))
        .then(
      (image) async {
        if (image != null) {
          // const uuid = Uuid();

          Directory directory;

          if (Platform.isAndroid) {
            directory = Directory(dotenv.env['AOS_DCIM_PATH']!);

            if (!directory.existsSync()) {
              await directory.create(recursive: true);
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          final filePath = '${directory.path}/${_getSaveFileName()}.jpg';
          final file = File(filePath);
          await file.writeAsBytes(image);

          MyToasts().showNormal('Cpature was successful.');
        }
      },
    );
  }

  flash(ScreenShareModel? screenShareModel) async {
    bool isSupport = await _engine.isCameraTorchSupported();
    if (isSupport) {
      if (screenShareModel != null &&
          screenShareModel.accountNo != widget.accountNo &&
          !isFlash) {
        showDialog(
          context: context,
          builder: (context) => NormalAlertDialog(
            title:
                "Can't Turn On FlashLight (Can only be used when using the rear camera)",
            btnTitle: 'OK',
            onTap: () {
              context.pop();
            },
          ),
        );
      } else {
        setState(() {
          isFlash = !isFlash;
        });
        await _engine.setCameraTorchOn(isFlash);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => NormalAlertDialog(
          title:
              "Can't Turn On FlashLight (Can only be used when using the rear camera)",
          btnTitle: 'OK',
          onTap: () {
            context.pop();
          },
        ),
      );
    }
  }

  _leaveFunc() async {
    AuthModel authModel = ref.read(authViewModelProvider)!;

    ref.read(conferenceViewModelProvider.notifier).exitRoom(
          accountNo: authModel.accountNo!,
          companyNo: authModel.companyNo!,
        );

    ScreenShareModel? screenShareModel = ref.read(screenShareViewModelProvider);
    if (screenShareModel != null &&
        screenShareModel.accountNo! == authModel.accountNo!) {
      ref.read(screenShareViewModelProvider.notifier).screenShareOff(
          accountNo: authModel.accountNo!, meetId: widget.meetId);
    }

    ref.read(screenShareViewModelProvider.notifier).init();
    ref.read(conferenceViewModelProvider.notifier).init();
    ref.read(chatViewModelProvider.notifier).init();
    ref.read(drawViewModelProvider.notifier).init();

    await _dispose();

    context.pop();
  }

  String _getSaveFileName() {
    final now = DateTime.now();
    final date = "${now.year.toString().padLeft(4, '0')}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}";
    final time = "${now.hour.toString().padLeft(2, '0')}"
        "${now.minute.toString().padLeft(2, '0')}"
        "${now.second.toString().padLeft(2, '0')}";
    return "Toads_S_Link_Realwear_${date}_$time";
  }

  Widget scaleWidget(int index) {
    return Semantics(
      value: 'hf_no_number',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          setState(() {
            _scale = index.toDouble();
          });

          logger.i(_scale);

          await _engine.setCameraZoomFactor(_scale);
        },
        child: Semantics(
          value: 'hf_no_number',
          child: Container(
            decoration: BoxDecoration(
                color: Color(0xFF373737).withOpacity(0.8),
                shape: BoxShape.circle),
            padding: EdgeInsets.all(17),
            child: Text(
              '$index',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  bool sinkRecord = false;

  List<int> collectedPcmData = []; // 모든 PCM 바이트를 저장할 리스트
  int sampleRate = 48000;
  int numberOfChannels = 1;
  int bitsPerSample = 16; // Agora SDK는 보통 16비트를 사용합니다.

  AudioFrameObserver? afo;
  AudioEncodedFrameObserver? aefo;

  Future<void> startRecording() async {
    print('1');
    // 저장 경로 만들기
    Directory dir = await getApplicationDocumentsDirectory();

    print(dir.path);

    // outputFile = File('${dir.path}/remote_audio.aac');
    // _sink = outputFile.openWrite();

    // Agora observer 등록

    afo = AudioFrameObserver(
      onPlaybackAudioFrame: (channelId, audioFrame) {
        collectedPcmData.addAll(audioFrame.buffer!.toList());
      },
    );

    _mediaEngine.registerAudioFrameObserver(afo!);

    aefo = AudioEncodedFrameObserver(
      onPlaybackAudioEncodedFrame:
          (frameBuffer, length, audioEncodedFrameInfo) {
        sampleRate = audioEncodedFrameInfo.sampleRateHz!;
        numberOfChannels = audioEncodedFrameInfo.numberOfChannels!;

        // print(audioEncodedFrameInfo.sampleRateHz!);
        // print(audioEncodedFrameInfo.numberOfChannels!);
      },
      // 다른 콜백은 무시
      onMixedAudioEncodedFrame: (_, __, ___) {},
      onRecordAudioEncodedFrame: (_, __, ___) {},
    );

    _engine.registerAudioEncodedFrameObserver(
      observer: aefo!,
      config: const AudioEncodedFrameObserverConfig(
        postionType: AudioEncodedFrameObserverPosition
            .audioEncodedFrameObserverPositionPlayback, // 상대방 소리
      ),
    );

    // setState(() {
    //   sinkRecord = true;
    // });
  }

  Future<void> stopRecording() async {
    // setState(() {
    //   sinkRecord = false;
    // });

    if (afo != null) _mediaEngine.unregisterAudioFrameObserver(afo!);
    if (aefo != null) _engine.unregisterAudioEncodedFrameObserver(aefo!);

    Directory directory = await getApplicationDocumentsDirectory();

    await saveCollectedPcmToWav('${directory.path}/remote_audio.wav');

    // await convertRawAacToM4a(
    //     '${dir.path}/remote_audio.aac', '${dir.path}/remote_audio.m4a');

    // final params = ShareParams(
    //   text: 'Great picture',
    //   files: [XFile('${directory.path}/remote_audio.wav')],
    // );

    // final result = await SharePlus.instance.share(params);
  }

  Future<void> saveCollectedPcmToWav(String outputPath) async {
    if (collectedPcmData.isEmpty) {
      print('오디오 데이터 또는 메타데이터가 수집되지 않았습니다.');
      return;
    }

    final pcmBytes = Uint8List.fromList(collectedPcmData);
    final pcmLength = pcmBytes.length;

    // WAV 헤더 계산
    final channels = numberOfChannels;
    final rate = sampleRate;
    final bits = bitsPerSample;
    final byteRate = (rate * channels * bits) ~/ 8;
    final blockAlign = (channels * bits) ~/ 8;

    final header = ByteData(44);

    // RIFF 청크
    header.setUint32(0, 0x46464952, Endian.little); // 'RIFF'
    header.setUint32(
        4, pcmLength + 36, Endian.little); // File Size (전체 파일 크기 - 8)
    header.setUint32(8, 0x45564157, Endian.little); // 'WAVE'

    // 'fmt ' 서브 청크
    header.setUint32(12, 0x20746D66, Endian.little); // 'fmt '
    header.setUint32(16, 16, Endian.little); // Subchunk1 Size (PCM의 경우 16)
    header.setUint16(20, 1, Endian.little); // Audio Format (PCM = 1)
    header.setUint16(22, channels, Endian.little); // Num Channels
    header.setUint32(24, rate, Endian.little); // Sample Rate
    header.setUint32(28, byteRate, Endian.little); // Byte Rate
    header.setUint16(32, blockAlign, Endian.little); // Block Align
    header.setUint16(34, bits, Endian.little); // Bits Per Sample

    // 'data' 서브 청크
    header.setUint32(36, 0x61746164, Endian.little); // 'data'
    header.setUint32(40, pcmLength, Endian.little); // Data Size (PCM 데이터 길이)

    // 파일에 헤더와 데이터를 순서대로 작성
    final file = File(outputPath);
    await file.writeAsBytes(header.buffer.asUint8List(), mode: FileMode.write);
    await file.writeAsBytes(pcmBytes, mode: FileMode.append);

    print('✅ WAV 파일 저장 완료: $outputPath');

    // 다음 녹음을 위해 데이터 초기화
    collectedPcmData.clear();
  }

  _record() async {
    if (!_recordLoading) {
      setState(() {
        _recordLoading = true;
      });
      if (!_recording) {
        // const uuid = Uuid();

        _recording = await FlutterScreenRecording.startRecordScreenAndAudio(
            _getSaveFileName());

        logger.i(_recording);

        await startRecording();

        if (_recording) {
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _recordTime++;
            });
          });
        }

        setState(() {});
      } else {
        String path = await FlutterScreenRecording.stopRecordScreen;
        // MyToasts().showNormal('Stop Record Screen');

        logger.i(path);

        await stopRecording();

        setState(() {
          _recordTimer?.cancel();
          _recordTimer = null;
          _recordTime = 0;

          _recording = false;
        });

        //storage/emulated/0/Android/data/com.toads.toadsslink.flutter/cache/739e716b-c4a4-42b8-93af-d2c946444975.mp4

        Directory directory = await getApplicationDocumentsDirectory();

        File tempFile = File(path);
        File resultFile = File('${directory.path}/${p.basename(path)}');

        //카피해주고 기존꺼 지우고

        resultFile.writeAsBytesSync(tempFile.readAsBytesSync());
        Directory(tempFile.path).deleteSync(recursive: true);

        String? mergeFile = await mergeAudioAndVideo(
            resultFile.path, '${directory.path}/remote_audio.wav');

        if (Platform.isAndroid) {
          const MethodChannel channel = MethodChannel('ToadsSLink');
          await channel.invokeMethod('refreshMedia', {"path": mergeFile});
        }

        logger.i(resultFile.path);

        MyToasts().showNormal("Saved in '${resultFile.path}'");
      }

      setState(() {
        _recordLoading = false;
      });
    }
  }

  Future<String?> mergeAudioAndVideo(String videoPath, String audioPath) async {
    // 1. 출력 파일 경로 설정
    Directory directory;

    if (Platform.isAndroid) {
      directory = Directory(dotenv.env['AOS_DCIM_PATH']!);

      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final String outputFilePath =
        '${directory.path}/Toads S-Link_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // 2. FFmpeg 명령어 구성
    // -y 옵션: 파일이 이미 존재하면 덮어쓰기 (자동 확인)
    final String command = '-i "$videoPath" '
        '-i "$audioPath" '
        '-filter_complex "[0:a][1:a]amix=inputs=2:duration=first[a]" '
        '-map 0:v:0 '
        '-map "[a]" '
        '-c:v copy '
        '-c:a aac '
        '-b:a 192k '
        '-y "$outputFilePath"'; // 최종 출력 파일

    print('FFmpeg Command: $command');

    // 3. FFmpeg 실행
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ 비디오/오디오 병합 성공: $outputFilePath');
      return outputFilePath;
    } else if (ReturnCode.isCancel(returnCode)) {
      print('❌ 비디오/오디오 병합 취소');
      return null;
    } else {
      // 에러 로그 확인
      final log = await session.getAllLogsAsString();
      print('❌ 비디오/오디오 병합 실패. 로그:\n$log');
      return null;
    }
  }

  String _recordDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }
}
