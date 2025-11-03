import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lepsi_rw_speech_recognizer/lepsi_rw_speech_recognizer.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/changeNetworkCreateRoomViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceListViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternalIpDialog extends ConsumerStatefulWidget {
  final bool isInRoom;
  Future<void> Function()? leaveFunc;
  InternalIpDialog({super.key, required this.isInRoom, this.leaveFunc});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InternalIpDialogState();
}

class _InternalIpDialogState extends ConsumerState<InternalIpDialog> {
  final TextEditingController ipEditingController =
      TextEditingController(text: 'http://192.168.50.7');
  final TextEditingController portEditingController =
      TextEditingController(text: '5000');

  final ipFocus = FocusNode();
  final portFocus = FocusNode();

  bool localKr = false;

  @override
  void initState() {
    localKr = ref.read(localeViewModelProvider) == 'KOR';
    rw();
    super.initState();
  }

  rw() {
    LepsiRwSpeechRecognizer.setCommands(<String>[
      'IP Input',
      '아이피 입력',
      'Port Input',
      '포트 입력',
      'Cancel',
      '취소',
      'Connect',
      '연결',
    ], (command) async {
      logger.i(command);

      switch (command) {
        case 'Cancel':
        case '취소':
          context.pop();
          break;
        case 'IP Input':
        case '아이피 입력':
          FocusScope.of(context).requestFocus(ipFocus);
          break;
        case 'Port Input':
        case '포트 입력':
          FocusScope.of(context).requestFocus(portFocus);
          break;
        case 'Connect':
        case '연결':
          connect();
          break;
      }
    });
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Enter Internal IP Address',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Semantics(
                    value: 'hf_no_number',
                    child: SizedBox(
                      width: 550,
                      child: Semantics(
                        value: 'hf_no_number',
                        child: TextField(
                          controller: ipEditingController,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          focusNode: ipFocus,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.w500),
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 1,
                          cursorColor: MyColors.primary,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              isDense: false,
                              counterText: '',
                              hintText: '',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF7D7D7D),
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFCDCDCD), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF1791F4), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFCDCDCD), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFFF4242), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFFF4242), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 15),
                                child: Image.asset(
                                  'assets/icons/ic_ip.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                              suffixIcon: SizedBox(
                                width: 180,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Image.asset(
                                      'assets/icons/ic_voice.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localKr ? '아이피 입력' : 'IP Input',
                                      style: TextStyle(
                                          color: Color(0xFF7D7D7D),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    )
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Semantics(
                    value: 'hf_no_number',
                    child: SizedBox(
                      width: 550,
                      child: Semantics(
                        value: 'hf_no_number',
                        child: TextField(
                          controller: portEditingController,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          focusNode: portFocus,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                          ],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.w500),
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 1,
                          cursorColor: MyColors.primary,
                          maxLength: 5,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              isDense: false,
                              counterText: '',
                              hintText: '',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF7D7D7D),
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFCDCDCD), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF1791F4), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFCDCDCD), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFFF4242), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFFF4242), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 15),
                                child: Image.asset(
                                  'assets/icons/ic_port.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                              suffixIcon: SizedBox(
                                width: 180,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Image.asset(
                                      'assets/icons/ic_voice.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localKr ? '포트 입력' : 'Port Input',
                                      style: TextStyle(
                                          color: Color(0xFF7D7D7D),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    )
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          value: 'hf_no_number',
                          child: PrimaryButton(
                            title: localKr ? '연결' : 'Connect',
                            onTap: connect,
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
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  connect() async {
    if (ipEditingController.text.isEmpty) {
      MyToasts().showNormal('Please enter the IP.');
      return;
    }

    if (portEditingController.text.isEmpty) {
      MyToasts().showNormal('Please enter the Port.');
      return;
    }

    if (widget.isInRoom) {
      await widget.leaveFunc!();
    }

    try {
      SocketManager().getSocket().disconnect();

      await SocketManager()
          .connect('${ipEditingController.text}:${portEditingController.text}');

      setState(() {
        AppConfig.isExternal = false;

        AppConfig.INTERNAL_URL =
            '${ipEditingController.text}:${portEditingController.text}';
      });

      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

      asyncPrefs.setString('internalURL', AppConfig.INTERNAL_URL);

      asyncPrefs.setBool('isExternal', AppConfig.isExternal);

      nextFunc();
    } catch (e) {
      SocketManager().connect(dotenv.env['BASE_URL']!);

      MyToasts().showNormal('Internal Network Socket Connect Error');

      if (widget.isInRoom) {
        context.go('/conference');
      }
    }
  }

  nextFunc() async {
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
}
