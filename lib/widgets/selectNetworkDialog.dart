import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lepsi_rw_speech_recognizer/lepsi_rw_speech_recognizer.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/changeNetworkCreateRoomViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceListViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectNetworkDialog extends ConsumerStatefulWidget {
  final bool isInRoom;
  Future<void> Function()? leaveFunc;

  SelectNetworkDialog({super.key, required this.isInRoom, this.leaveFunc});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectNetworkViewState();
}

class _SelectNetworkViewState extends ConsumerState<SelectNetworkDialog> {
  bool localKr = false;

  @override
  void initState() {
    localKr = ref.read(localeViewModelProvider) == 'KOR';
    rw();
    super.initState();
  }

  rw() {
    LepsiRwSpeechRecognizer.setCommands(<String>[
      'Internal Network',
      '내부 네트워크',
      'External Network',
      '외부 네트워크',
      'Cancel',
      '취소'
    ], (command) async {
      logger.i(command);

      switch (command) {
        case 'Cancel':
        case '취소':
          context.pop();
          break;
        case 'External Network':
        case '외부 네트워크':
          goExternal();
          break;
        case 'Internal Network':
        case '내부 네트워크':
          goInternal();
          break;
      }
    });
  }

  goInternal() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    String? url = await asyncPrefs.getString('internalURL');
    if (url == null) {
      context
          .push('/dialog/internal/ip?isInRoom=${widget.isInRoom}',
              extra: widget.leaveFunc)
          .then(
        (value) {
          rw();
        },
      );
      // showDialog(
      //   context: context,
      //   builder: (context) => InternalIpDialog(
      //     isInRoom: widget.isInRoom,
      //     leaveFunc: widget.leaveFunc,
      //   ),
      // );
    } else {
      if (widget.isInRoom) {
        await widget.leaveFunc!();
      }

      try {
        SocketManager().disconnect(isNetworkChange: true);

        await SocketManager().connect(url);

        setState(() {
          AppConfig.INTERNAL_URL = url;
          AppConfig.isExternal = false;
        });

        SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
        asyncPrefs.setBool('isExternal', AppConfig.isExternal);

        internalNextFunc();
      } catch (e) {
        SocketManager().connect(dotenv.env['BASE_URL']!);
        MyToasts().showNormal('Internal Network Socket Connect Error');
      }
    }
  }

  goExternal() async {
    if (widget.isInRoom) {
      await widget.leaveFunc!();
    }
    try {
      bool prevNetwork = AppConfig.isExternal;

      SocketManager().disconnect(isNetworkChange: true);
      await SocketManager().connect(dotenv.env['BASE_URL']!);

      setState(() {
        AppConfig.isExternal = true;
      });

      SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
      asyncPrefs.setBool('isExternal', AppConfig.isExternal);

      externalNextFunc(prevNetwork);
    } catch (e) {
      SocketManager().connect(AppConfig.INTERNAL_URL);
      MyToasts().showNormal('External Network Socket Connect Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181820),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: const Color(0xFF272B37),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCDCDCD), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Select Network',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Please choose how you would like to connect',
                    style: TextStyle(
                      color: Color(0xFFB7BDC3),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Semantics(
                            value: 'hf_no_number',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                backgroundColor: const Color(0xFF2A82FF),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: goInternal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/ic_internal.png',
                                    width: 26,
                                    height: 24,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    localKr ? '내부 네트워크' : 'Internal Network',
                                    style: TextStyle(
                                        letterSpacing: -0.5,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Semantics(
                            value: 'hf_no_number',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                backgroundColor: const Color(0xFF2A82FF),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: goExternal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/ic_external.png',
                                    width: 26,
                                    height: 24,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    localKr ? '외부 네트워크' : 'External Network',
                                    style: TextStyle(
                                        letterSpacing: -0.5,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: Semantics(
                          value: 'hf_no_number',
                          child: PrimaryButton(
                            isWhite: true,
                            title: localKr ? '취소' : 'Cancel',
                            onTap: () {
                              context.pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  internalNextFunc() async {
    final SharedPreferencesAsync asyncShare = SharedPreferencesAsync();
    String? email = await asyncShare.getString('email');
    if (email == null) {
      print('자동로그인 x');
      context.go('/auth/signin');
    } else {
      //자동로그인
      print('자동로그인 o');

      // context.go('/home');
      ref.read(authViewModelProvider.notifier).autoLogin(
            email: email,
            duplicateFunc: () {
              MyToasts().showNormal('This email is already signed in.');
              context.go('/auth/signin');
            },
            successFunc: (int accountNo, int companyNo, String email) {
              //리프래시 룸 리스트 미리 달아주기
              ref
                  .read(conferenceListViewModelProvider.notifier)
                  .onRepleshConferenceList(accountNo: accountNo);

              ref
                  .read(conferenceListViewModelProvider.notifier)
                  .getConferenceList(accountNo: accountNo);

              ref
                  .read(inviteMemberViewModelProvider.notifier)
                  .getMemberList(companyNo: companyNo, email: email);

              if (!AppConfig.isExternal) {
                context.pop();
              }

              if (widget.isInRoom) {
                ref
                    .read(changeNetworkCreateRoomViewModelProvider.notifier)
                    .setValue(true);
              }

              context.go('/internal/conference');
            },
          );
    }
  }

  externalNextFunc(bool prevNetwork) async {
    final SharedPreferencesAsync asyncShare = SharedPreferencesAsync();
    String? email = await asyncShare.getString('email');
    if (email == null) {
      print('자동로그인 x');
      context.go('/auth/signin');
    } else {
      //자동로그인
      print('자동로그인 o');

      // context.go('/home');
      ref.read(authViewModelProvider.notifier).autoLogin(
            email: email,
            duplicateFunc: () {
              MyToasts().showNormal('This email is already signed in.');
              context.go('/auth/signin');
            },
            successFunc: (int accountNo, int companyNo, String email) {
              //리프래시 룸 리스트 미리 달아주기
              ref
                  .read(conferenceListViewModelProvider.notifier)
                  .onRepleshConferenceList(accountNo: accountNo);

              ref
                  .read(conferenceListViewModelProvider.notifier)
                  .getConferenceList(accountNo: accountNo);

              ref
                  .read(inviteMemberViewModelProvider.notifier)
                  .getMemberList(companyNo: companyNo, email: email);

              if (AppConfig.isExternal == prevNetwork) {
                context.pop();
              }

              if (widget.isInRoom) {
                ref
                    .read(changeNetworkCreateRoomViewModelProvider.notifier)
                    .setValue(true);
              }

              context.go('/conference');
            },
          );
    }
  }
}
