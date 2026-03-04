import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/models/chatModel.dart';
import 'package:realwear_flutter/models/conferenceModel.dart';
import 'package:realwear_flutter/models/drawModel.dart';
import 'package:realwear_flutter/models/internal/iceCandidateModel.dart';
import 'package:realwear_flutter/models/internal/userModel.dart';
import 'package:realwear_flutter/models/serverDrawModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myLoading.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/utils/recog.dart';
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

class InternalDetailView extends ConsumerStatefulWidget {
  final String meetId;
  final int companyNo;
  final int accountNo;

  const InternalDetailView(
      {super.key,
      required this.meetId,
      required this.companyNo,
      required this.accountNo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InternalDetailViewState();
}

class _InternalDetailViewState extends ConsumerState<InternalDetailView>
    with WidgetsBindingObserver {
  final _chatScrollController = ScrollController();
  final _screenshotController = ScreenshotController();

  final GlobalKey _screenSizeKey = GlobalKey();

  bool _myAudio = true;
  bool _showChat = false;

  bool isFlash = false;

  bool _recording = false;
  bool _recordLoading = false;
  Timer? _recordTimer;
  int _recordTime = 0;

  final List<DrawModel> _drawPoints = [];

  bool localKr = true;

  bool _isMenuVisible = false;

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

    initWebRtc();

    super.initState();

    WidgetsBinding.instance.addObserver(this); // 옵저버 등록

    ref.read(chatViewModelProvider.notifier).onChat();

    ref.read(drawViewModelProvider.notifier).onDraw(
      drawClearFunction: (socketId) {
        setState(() {
          _drawPoints.removeWhere((model) => model.socketId == socketId);
        });
      },
    );
  }

  rw2() {
    Recog.setHandler(
      (command) {
        logger.i(command);
        switch (command) {
          case '방 나가기':
          case '뒤로가기':
          case 'Leave Room':
          case 'Go Back':
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
                          rw2();
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
            flash();

            break;
          case '플래시 끄기':
          case 'Flash Off':
            if (!isFlash) {
              break;
            }
            flash();
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

          case '마이크 켜기':
          case 'Mike On':
            if (_myAudio) {
              break;
            }
            setState(() {
              _myAudio = !_myAudio;
              // if (!_myAudio) _myVad = false;
              _localStream?.getAudioTracks().forEach((track) {
                track.enabled = _myAudio;
              });
            });
            break;
          case '마이크 끄기':
          case 'Mike Off':
            if (!_myAudio) {
              break;
            }
            setState(() {
              _myAudio = !_myAudio;
              // if (!_myAudio) _myVad = false;
              _localStream?.getAudioTracks().forEach((track) {
                track.enabled = _myAudio;
              });
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

          case '네트워크 전환':
          case 'Change Network':
            context.push(
              '/dialog/network?isInRoom=true',
              extra: () async {
                await _leaveFunc();
              },
            ).then(
              (value) {
                rw2();
              },
            );
            break;
        }
      },
    );
  }

  String? mySocketId = SocketManager().getSocket().id;

  /// 본인 비디오
  MediaStream? _localStream;

  RTCPeerConnection? _peer;

  final List<IceCandidateModel> _candidateList = [];

  /// iceCandidate 연결 여부
  bool _isConnected = false;

  // bool audioOnly = false;

  RTCVideoRenderer? localRenderer = RTCVideoRenderer();
  // List<RTCVideoRenderer> remoteRendererList = [];

  Map<String, UserModel> remoteUsers = {};

  @override
  Widget build(BuildContext context) {
    ConferenceModel? model = ref.watch(conferenceViewModelProvider);

    AuthModel authModel = ref.read(authViewModelProvider)!;

    List<ChatModel> chatModelList = ref.watch(chatViewModelProvider).chatModel;

    ref.listen(
      drawViewModelProvider,
      (previous, next) {
        if (next != null &&
            next.receiverSocketId == SocketManager().getSocket().id) {
          switch (next.drawingPosition) {
            case 'SHARING':
              inputDrawPoint(next, _screenSizeKey, _drawPoints);
              break;
          }
        }
      },
    );

    return Semantics(
      label:
          "hf_add_commands:방 나가기|Leave Room|초대하기|Invite|플래시 켜기|Flash On|플래시 끄기|Flash Off|화면녹화 켜기|Screen Recording On|화면녹화 끄기|Screen Recording Off|메뉴 열기|Show Menu|메뉴 닫기|Hide Menu|마이크 켜기|Mike On|마이크 끄기|Mike Off|사진 저장|Capture|채팅 켜기|Chat On|채팅 끄기|Chat Off|뒤로가기|Go Back|네트워크 전환|Change Network|",
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Center(
                child: Container(
                  key: _screenSizeKey,
                  child: localRenderer == null
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4A90DC)),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Screenshot(
                            controller: _screenshotController,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double width = constraints.maxWidth;
                                final double height = constraints.maxHeight;

                                return RepaintBoundary(
                                  child: CustomPaint(
                                    isComplex: true,
                                    willChange: false,
                                    foregroundPainter:
                                        SignaturePainter(_drawPoints),
                                    size: Size(width, height), // 크기를 제한
                                    child: RTCVideoView(
                                      localRenderer!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ),
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
                                onTap: () async {
                                  setState(() {
                                    _myAudio = !_myAudio;
                                    // if (!_myAudio) _myVad = false;
                                    _localStream
                                        ?.getAudioTracks()
                                        .forEach((track) {
                                      track.enabled = _myAudio;
                                    });
                                  });
                                },
                                child: Semantics(
                                  value: 'hf_no_number',
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            SizedBox(
                              width: 5,
                            ),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
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
                          flash();
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
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
                                rw2();
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
      ),
    );
  }

  flash() async {
    final videoTrack = _localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      final bool isSupported = await videoTrack.hasTorch();
      if (isSupported) {
        setState(() {
          isFlash = !isFlash;
        });
        await videoTrack.setTorch(isFlash);
      } else {
        Recog.setHandler(
          (command) async {
            switch (command) {
              case '뒤로가기':
              case '네':
              case '취소':
              case '닫기':
              case 'Close':
              case 'Cancel':
              case 'Go Back':
              case 'OK':
                context.pop();
                break;
            }
          },
        );

        showDialog(
          context: context,
          builder: (context) => Semantics(
            value: "hf_add_commands:뒤로가기|네|취소|닫기|Close|Cancel|Go Back|OK|",
            child: NormalAlertDialog(
              commands: "hf_add_commands:뒤로가기|네|취소|닫기|Close|Cancel|Go Back|OK|",
              title:
                  "Can't Turn On FlashLight (Can only be used when using the rear camera)",
              btnTitle: 'OK',
              onTap: () {
                context.pop();
              },
            ),
          ),
        );
      }
    }
  }

  /// 서버에서 받은 files 목록의 url을 Dio로 다운로드하여 로컬 경로 목록 반환
  Future<List<String>> _downloadWavFiles(
      List<dynamic> files, Directory directory) async {
    final dio = Dio();
    final List<String> paths = [];
    for (int i = 0; i < files.length; i++) {
      final item = files[i];
      if (item is! Map) continue;
      final url = item['url']?.toString();
      final socketId = item['socketId']?.toString() ?? '$i';
      if (url == null || url.isEmpty) continue;
      final safeId = socketId.replaceAll(RegExp(r'[^\w\-]'), '_');
      final savePath = '${directory.path}/remote_$safeId.wav';
      try {
        await dio.download(url, savePath);
        paths.add(savePath);
      } catch (e) {
        logger.e('wav 다운로드 실패 $url: $e');
      }
    }
    return paths;
  }

  /// wav 여러 개를 ffmpeg amix로 하나로 합침
  Future<String?> _mergeWavFiles(
      List<String> wavPaths, Directory directory) async {
    if (wavPaths.isEmpty) return null;
    if (wavPaths.length == 1) return wavPaths.first;

    final outputPath =
        '${directory.path}/merged_remote_${DateTime.now().millisecondsSinceEpoch}.wav';
    // amix: inputs=N:duration=longest, -threads 0으로 멀티코어 활용
    final inputs =
        wavPaths.asMap().entries.map((e) => '-i "${e.value}"').join(' ');
    final filterInputs =
        wavPaths.asMap().entries.map((e) => '[${e.key}:a]').join('');
    final filter =
        '${filterInputs}amix=inputs=${wavPaths.length}:duration=longest[a]';
    const String threadOpt = '-threads 0';
    final command =
        '$inputs -filter_complex "$filter" -map "[a]" $threadOpt -y "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }
    final log = await session.getAllLogsAsString();
    logger.e('wav 병합 실패: $log');
    return null;
  }

  /// 비디오(로컬 녹화) + 오디오(wav) ffmpeg 병합
  /// 화면 녹화 mp4에 오디오가 없을 수 있음 → 오디오 없으면 wav만 붙이는 폴백 사용
  /// 속도 최적화: 비디오에 오디오 없는 경우가 많아 해당 명령을 먼저 시도해 FFmpeg 1회만 실행
  Future<String?> _mergeAudioAndVideo(
      String videoPath, String audioPath, Directory directory) async {
    final String outputFilePath =
        '${directory.path}/Toads_S-Link_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // 병합 시 인코딩 속도 향상: 멀티스레드 + AAC 빠른 인코더
    const String aacOpts = '-c:a aac -b:a 128k -threads 0';

    // 1) 비디오에 오디오 스트림이 없을 때(화면 녹화 대부분): 비디오 + wav만 매핑 → 먼저 시도해 긴 녹화 시 불필요한 1회 실패 방지
    final commandVideoOnly = '-i "$videoPath" '
        '-i "$audioPath" '
        '-map 0:v:0 '
        '-map 1:a:0 '
        '-c:v copy '
        '$aacOpts '
        '-shortest '
        '-y "$outputFilePath"';

    var session = await FFmpegKit.execute(commandVideoOnly);
    var returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      return outputFilePath;
    }

    // 2) 비디오에 오디오가 있는 경우: [0:a][1:a] amix
    final commandWithMix = '-i "$videoPath" '
        '-i "$audioPath" '
        '-filter_complex "[0:a][1:a]amix=inputs=2:duration=first[a]" '
        '-map 0:v:0 '
        '-map "[a]" '
        '-c:v copy '
        '$aacOpts '
        '-y "$outputFilePath"';

    session = await FFmpegKit.execute(commandWithMix);
    returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      return outputFilePath;
    }

    final log = await session.getAllLogsAsString();
    logger.e('비디오/오디오 병합 실패: $log');
    return null;
  }

  _record() async {
    if (!_recordLoading) {
      setState(() {
        _recordLoading = true;
      });
      if (!_recording) {
        const uuid = Uuid();

        _recording = await FlutterScreenRecording.startRecordScreen(uuid.v4());

        logger.i(_recording);

        if (_recording) {
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _recordTime++;
            });
          });

          SocketManager().getSocket().emitWithAck(
              'recordStart', {'meet_id': widget.meetId}, ack: (data) {
            logger.w('start ack $data');
          });
        }

        setState(() {});
      } else {
        String path = await FlutterScreenRecording.stopRecordScreen;
        // MyToasts().showNormal('Stop Record Screen');

        logger.i(path);

        SocketManager().getSocket().emitWithAck(
            'recordStop', {'meet_id': widget.meetId}, ack: (data) async {
          logger.w('stop ack $data');

          setState(() {
            _recordTimer?.cancel();
            _recordTimer = null;
            _recordTime = 0;

            _recording = false;
          });

          Directory directory = Directory(dotenv.env['AOS_DCIM_PATH']!);

          if (!directory.existsSync()) {
            await directory.create(recursive: true);
          }

          File tempFile = File(path);
          File resultFile = File('${directory.path}/${p.basename(path)}');

          tempFile.copySync(resultFile.path);
          tempFile.deleteSync();

          String finalPath = resultFile.path;

          try {
            try {
              final files = data is Map ? data['files'] : null;
              final fileList = files is List ? files : null;
              if (fileList != null && fileList.isNotEmpty) {
                final tempDir = await getTemporaryDirectory();
                final wavPaths = await _downloadWavFiles(fileList, tempDir);
                if (wavPaths.isNotEmpty) {
                  final mergedWav = await _mergeWavFiles(wavPaths, tempDir);
                  if (mergedWav != null) {
                    final mergeFile = await _mergeAudioAndVideo(
                        resultFile.path, mergedWav, tempDir);
                    if (mergeFile != null) {
                      // 최종 mp4만 DCIM으로 복사 (앱 저장소 → 갤러리)
                      final destFile = File(
                          '${directory.path}/Toads_S-Link_${DateTime.now().millisecondsSinceEpoch}.mp4');
                      try {
                        File(mergeFile).copySync(destFile.path);
                        finalPath = destFile.path;
                      } catch (_) {
                        finalPath = mergeFile;
                      }
                      logger.i('비디오+원격 오디오 병합 완료: $finalPath');
                    }
                  }
                }
              }
            } catch (e, st) {
              logger.e('wav 다운로드/병합 중 오류: $e $st');
            }

            const MethodChannel channel = MethodChannel('ToadsSLink');
            await channel.invokeMethod('refreshMedia', {"path": finalPath});

            logger.i(finalPath);
            MyToasts().showNormal("Saved in '$finalPath'");
          } catch (e) {
            logger.e('녹화 파일 처리 중 오류: $e');
          } finally {
            setState(() {
              _recordLoading = false;
            });
          }
        });
      }

      setState(() {
        _recordLoading = false;
      });
    }
  }

  String _recordDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
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

          MyToasts().showNormal('Cpature was successful.$filePath');
        }
      },
    );
  }

  initWebRtc() async {
    await initSocket();
    await initPeer();

    await localRenderer!.initialize();

    await sendOffer();

    rw2();

    MyLoading().hideLoading(context);

    initUser();
  }

  initSocket() {
    SocketManager().getSocket().on('allUsers', onAllUsers);
    SocketManager().getSocket().on('user_exit', onUserExit);
    SocketManager().getSocket().on('getSenderAnswer', onGetSenderAnswer);
    SocketManager().getSocket().on('getSenderCandidate', onGetSenderCandidate);
    SocketManager().getSocket().on('getReceiverAnswer', onGetReceiverAnswer);
    SocketManager()
        .getSocket()
        .on('getReceiverCandidate', onGetReceiverCandidate);
  }

  initPeer() async {
    _peer = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:3.37.178.14:3478',
            'turn:3.37.178.14:3478',
          ],
          'username': 'admin',
          'credential': 'webkul123',
        }
      ],
    });

    _peer!.onIceCandidate = _iceCandidateEvent;
    _peer!.onConnectionState = _peerStateChange;
  }

  sendOffer() async {
    await turnOnMedia();

    final RTCSessionDescription offer = await _peer!.createOffer({
      'mandatory': {
        'OfferToReceiveAudio': true,
        // 'OfferToReceiveVideo': !audioOnly,
        'OfferToReceiveVideo': true,
      }
    });
    await _peer!.setLocalDescription(offer);

    AuthModel authModel = ref.read(authViewModelProvider)!;

    var data = {
      'type': offer.type.toString().toLowerCase(),
      'sdp': offer.sdp,
      'senderSocketId': mySocketId,
      'meet_id': widget.meetId,
      'user_name': authModel.userName,
      'account_no': authModel.accountNo,
      'company_no': authModel.companyNo,
    };
    logger.f('emit_senderOffer');
    SocketManager().getSocket().emit('senderOffer', data);
  }

  initUser() {
    SocketManager().getSocket().emit('setRoomInfo', widget.meetId);
    AuthModel authModel = ref.read(authViewModelProvider)!;

    var data = {
      'meet_id': widget.meetId,
      'user_name': authModel.userName,
      'account_no': authModel.accountNo,
      'company_no': authModel.companyNo,
      'id': mySocketId,
      'isWebCamAvailable': false,
    };

    logger.f('emit_alluser');
    SocketManager().getSocket().emit('alluser', data);
  }

  void _iceCandidateEvent(RTCIceCandidate? e) {
    if (e == null ||
        e.candidate == null ||
        e.sdpMLineIndex == null ||
        e.sdpMid == null) {
      return;
    }
    IceCandidateModel model = IceCandidateModel();
    model.candidate = e.candidate;
    model.sdpMid = e.sdpMid;
    model.sdpMLineIndex = e.sdpMLineIndex;
    // model.to = to;

    int index = _candidateList
        .indexWhere((element) => element.candidate == model.candidate);

    if (index < 0) {
      _candidateList.add(model);

      var data = {
        'senderSocketId': mySocketId,
        'candidate': e.candidate,
        'sdpMid': e.sdpMid,
        'sdpMLineIndex': e.sdpMLineIndex,
      };
      logger.f('emit_senderCandidate');
      SocketManager().getSocket().emit('senderCandidate', data);
    }
  }

  void _peerStateChange(RTCPeerConnectionState state) {
    debugPrint(
        '[webRTC] peer connection state : ${state.name}, ${_peer?.connectionState}');

    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
        !_isConnected) {
      _isConnected = true;
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      _peer?.restartIce();
    }
  }

  Future<void> turnOnMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        // 'video': {'facingMode': 'user'},
        'audio': {
          'autoGainControl': false,
          'channelCount': 1,
          'echoCancellation': true,
          'latency': 0,
          'noiseSuppression': true,
          'sampleRate': 48000,
          'sampleSize': 16,
          'volume': 1.0
        }
      });

      setState(() {
        localRenderer!.srcObject = _localStream;
      });
      // localVideoNotifier.value = true;

      // localRenderer?.muted = true;

      for (MediaStreamTrack track in _localStream!.getTracks()) {
        debugPrint('track : $track, stream : $_localStream');

        if (track.kind == 'audio') {
          Helper.setMicrophoneMute(false, track);
        }
        _peer!.addTrack(track, _localStream!);
      }

      if (_peer!.connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        List<RTCRtpSender> list = await _peer!.getSenders();
        debugPrint('[media] list : ${list.length}');
        for (RTCRtpSender sender in list) {
          debugPrint('[media] sender : $sender');
          List<MediaStreamTrack> trackList = _localStream!.getTracks();
          debugPrint('[media] trackList : ${trackList.length}');

          int index = trackList
              .indexWhere((element) => element.kind == sender.track?.kind);

          debugPrint('[media] index : $index');

          if (index >= 0) {
            MediaStreamTrack track = trackList[index];
            debugPrint('[media] track : $track');

            await sender.replaceTrack(track);
            debugPrint('[media] replace track');
          }
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint('[webRTC] media error : $e');
    }
  }

  onAllUsers(dynamic data) {
    logger.i('onAllUser');
    String userList = data[0];
    String id = data[1];

    final decoded = jsonDecode(userList) as List<dynamic>;
    final otherUsers = decoded.map((e) => UserModel.fromJson(e)).toList();

    for (var element in otherUsers) {
      if (element.id == null ||
          element.id!.isEmpty ||
          remoteUsers.containsKey(element.id) ||
          element.id == mySocketId ||
          remoteUsers.length == 2) {
        continue;
      }

      remoteUsers[element.id!] = element;

      var data = {
        'senderSocketId': element.id,
        'receiverSocketId': mySocketId,
        'meet_id': widget.meetId
      };

      logger.f('emit_receiverOffer');
      SocketManager().getSocket().emit('receiverOffer', data);
    }
  }

  onUserExit(dynamic data) {
    logger.i('onUserExit');

    String id = data[1];

    remoteUsers[id]?.peer?.close();
    remoteUsers[id]?.peer?.dispose();
    remoteUsers[id]?.remoteRenderer?.dispose();

    remoteUsers.remove(id);

    setState(() {});
  }

  onGetSenderAnswer(dynamic data) async {
    logger.i('onGetSenderAnswer');

    String type = data[0];
    String sdp = data[1];

    await _peer!.setRemoteDescription(RTCSessionDescription(sdp, type));

    // await turnOnMedia();
  }

  onGetSenderCandidate(dynamic data) async {
    logger.i('onGetSenderCandidate');

    String candidate = data[0];
    String sdpMid = data[1];
    int sdpMLineIndex = data[2];

    RTCIceCandidate e = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);

    await _peer!.addCandidate(e);
  }

  onGetReceiverAnswer(dynamic datas) async {
    logger.i('onGetReceiverAnswer');

    String type = datas[0];
    String sdp = datas[1];
    String senderId = datas[2];

    remoteUsers[senderId]!.peer = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:3.37.178.14:3478',
            'turn:3.37.178.14:3478',
          ],
          'username': 'admin',
          'credential': 'webkul123',
        }
      ],
    });

    remoteUsers[senderId]!.peer!.onIceCandidate = (RTCIceCandidate? e) {
      if (e == null ||
          e.candidate == null ||
          e.sdpMLineIndex == null ||
          e.sdpMid == null) {
        return;
      }
      var data = {
        'senderSocketId': senderId,
        'receiverSocketId': mySocketId,
        'candidate': e.candidate,
        'sdpMid': e.sdpMid,
        'sdpMLineIndex': e.sdpMLineIndex,
      };
      logger.f('emit_recieverCandidate');
      SocketManager().getSocket().emit('recieverCandidate', data);
    };

    remoteUsers[senderId]!.peer!.onTrack = (RTCTrackEvent e) async {
      // if (e.track.kind == 'video') {
      // } else if (e.track.kind == 'audio') {}

      MediaStream stream = e.streams.first;
      RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
      await remoteRenderer.initialize();

      remoteRenderer.srcObject = stream;

      // remoteRendererList.add(remoteRenderer);
      remoteUsers[senderId]!.remoteRenderer = remoteRenderer;

      setState(() {});
    };

    await remoteUsers[senderId]!
        .peer!
        .setRemoteDescription(RTCSessionDescription(sdp, type));

    RTCSessionDescription? answer =
        await remoteUsers[senderId]!.peer!.createAnswer({
      'mandatory': {
        'OfferToReceiveAudio': true,
        // 'OfferToReceiveVideo': !audioOnly,
        'OfferToReceiveVideo': true,
      }
    });

    remoteUsers[senderId]!.peer!.setLocalDescription(answer);

    var data = {
      'type': answer.type.toString().toLowerCase(),
      'sdp': answer.sdp,
      'senderSocketId': senderId,
      'receiverSocketId': mySocketId,
      'meet_id': widget.meetId,
    };
    logger.f('emit_receiverAnswer');
    SocketManager().getSocket().emit('receiverAnswer', data);
  }

  onGetReceiverCandidate(dynamic data) async {
    logger.i('onGetReceiverCandidate');

    String senderId = data[0];
    String candidate = data[1];
    String sdpMid = data[2];
    int sdpMLineIndex = data[3];

    RTCIceCandidate e = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);

    await remoteUsers[senderId]?.peer?.addCandidate(e);
  }

  _dispose() async {
    SocketManager().getSocket().off('chatting');

    SocketManager().getSocket().off('drawStart');
    SocketManager().getSocket().off('draw');
    SocketManager().getSocket().off('drawEnd');
    SocketManager().getSocket().off('drawClear');

    SocketManager().getSocket().off('allUsers');
    SocketManager().getSocket().off('user_exit');
    SocketManager().getSocket().off('getSenderAnswer');
    SocketManager().getSocket().off('getSenderCandidate');
    SocketManager().getSocket().off('getReceiverAnswer');
    SocketManager().getSocket().off('getReceiverCandidate');
  }

  _leaveFunc() async {
    AuthModel authModel = ref.read(authViewModelProvider)!;

    ref.read(conferenceViewModelProvider.notifier).exitRoom(
          accountNo: authModel.accountNo!,
          companyNo: authModel.companyNo!,
        );

    ref.read(drawViewModelProvider.notifier).init();
    ref.read(conferenceViewModelProvider.notifier).init();
    ref.read(chatViewModelProvider.notifier).init();

    // 소켓 이벤트 리스너 제거 (네트워크 전환 시 중복 등록 방지)
    SocketManager().getSocket().off('allUsers');
    SocketManager().getSocket().off('user_exit');
    SocketManager().getSocket().off('getSenderAnswer');
    SocketManager().getSocket().off('getSenderCandidate');
    SocketManager().getSocket().off('getReceiverAnswer');
    SocketManager().getSocket().off('getReceiverCandidate');

    try {
      await _localStream?.dispose();
      await _peer?.close();
      await _peer?.dispose();
      _peer = null; // null로 설정하여 이후 호출 방지
      await localRenderer?.dispose();
      for (var element in remoteUsers.entries) {
        await element.value.peer?.close();
        await element.value.peer?.dispose();
        await element.value.remoteRenderer?.dispose();
      }
      remoteUsers.clear();
    } catch (e) {
      logger.e(e);
    }

    context.pop();
  }

  @override
  void dispose() {
    _dispose();
    WidgetsBinding.instance.removeObserver(this); // 옵저버 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 💡 앱이 포그라운드로 돌아왔을 때
        // 멈춘 스트림을 재개하는 로직을 실행합니다.
        logger.i('resumed');
        _resumeWebRTCStream();
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

  void _resumeWebRTCStream() {
    // localStream은 getUserMedia()로 얻은 MediaStream 객체여야 합니다.
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        // 트랙의 enabled 속성을 true로 설정하여 비디오 스트림을 재개합니다.
        track.enabled = true;
      });
    }
  }
}
