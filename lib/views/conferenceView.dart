import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lepsi_rw_speech_recognizer/lepsi_rw_speech_recognizer.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/models/conferenceModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/utils/myLoading.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceListViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceViewModel.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/viewModels/tokenViewModel.dart';
import 'package:realwear_flutter/widgets/normalAlertDialog.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConferenceView extends ConsumerStatefulWidget {
  const ConferenceView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConferenceViewState();
}

class _ConferenceViewState extends ConsumerState<ConferenceView> {
  int perPage = 6;
  int nowPage = 0;

  bool localKr = true;
  switchLocale() {
    setState(() {
      localKr = !localKr;
    });
    ref
        .read(localeViewModelProvider.notifier)
        .setLocale(localKr ? 'KOR' : 'ENG');
    final asyncShared = SharedPreferencesAsync();
    asyncShared.setString('locale', localKr ? 'KOR' : 'ENG');
  }

  @override
  void initState() {
    localKr = ref.read(localeViewModelProvider) == 'KOR';

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LepsiRwSpeechRecognizer.restoreCommands();
      rw();
    });
  }

  rw() {
    LepsiRwSpeechRecognizer.setCommands(<String>[
      '방만들기',
      'Create',
      '로그아웃',
      'Logout',
      '다음',
      'Next',
      '이전',
      'Previous',
      '항목 1 입장',
      'Join One',
      '항목 2 입장',
      'Join Two',
      '항목 3 입장',
      'Join Three',
      '항목 4 입장',
      'Join Four',
      '항목 5 입장',
      'Join Five',
      '항목 6 입장',
      'Join Six',
      'Switch to English',
      'Switch to Korean',
    ], (command) async {
      logger.i(command);

      //이전 다음 화면체크해야됨

      switch (command) {
        case '방만들기':
        case 'Create':
          await LepsiRwSpeechRecognizer.restoreCommands();
          context.push('/invite').then((value) async {
            logger.i('여기');
            logger.i(value);
            if (value == null) {
              await LepsiRwSpeechRecognizer.restoreCommands();
              rw();
            }
          });
          break;
        case '로그아웃':
        case 'Logout':
          logout();
          break;
        case '다음':
        case 'Next':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          nextFunc(modelList.length);
          break;
        case '이전':
        case 'Previous':
          prevFunc();
          break;
        case '항목 1 입장':
        case 'Join One':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);

          if (modelList.isNotEmpty) {
            goConference(modelList[nowPage == 0 ? 0 : nowPage * perPage - 1]);
          }

          break;
        case '항목 2 입장':
        case 'Join Two':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length > 1) {
            goConference(modelList[nowPage == 0 ? 1 : nowPage * perPage]);
          }
          break;
        case '항목 3 입장':
        case 'Join Three':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length > 2) {
            goConference(modelList[nowPage == 0 ? 2 : nowPage * perPage + 1]);
          }
          break;
        case '항목 4 입장':
        case 'Join Four':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length > 3) {
            goConference(modelList[nowPage == 0 ? 3 : nowPage * perPage + 2]);
          }
          break;
        case '항목 5 입장':
        case 'Join Five':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length > 4) {
            goConference(modelList[nowPage == 0 ? 4 : nowPage * perPage + 3]);
          }
          break;
        case '항목 6 입장':
        case 'Join Six':
          if (nowPage == 0) {
            break;
          }
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length > 5) {
            goConference(modelList[nowPage * perPage + 4]);
          }
          break;

        case 'Switch to English':
        case 'Switch to Korean':
          switchLocale();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthModel? authModel = ref.watch(authViewModelProvider);
    List<ConferenceModel> modelList =
        ref.watch(conferenceListViewModelProvider);
    return Scaffold(
      backgroundColor: Color(0xFF181820),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/ic_logo.png',
                  width: 17,
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  'Conference List',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Image.asset(
                      'assets/icons/ic_voice.png',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Switch to ${localKr ? 'English' : "Korean"}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        value: 'hf_no_number',
                        child: GestureDetector(
                          onTap: switchLocale,
                          child: Semantics(
                            value: 'hf_no_number',
                            child: localKr
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFDAE9FF),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 26),
                                    child: const Text(
                                      'KOR',
                                      style: TextStyle(
                                          color: Color(0xFF21385C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.transparent, width: 1),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 6, left: 26, right: 15),
                                    child: const Text(
                                      'KOR',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Semantics(
                        value: 'hf_no_number',
                        child: GestureDetector(
                          onTap: switchLocale,
                          child: Semantics(
                            value: 'hf_no_number',
                            child: !localKr
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFDAE9FF),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 26),
                                    child: const Text(
                                      'ENG',
                                      style: TextStyle(
                                          color: Color(0xFF21385C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.transparent, width: 1),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 6, left: 15, right: 26),
                                    child: const Text(
                                      'ENG',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6E4FA),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    authModel != null
                        ? authModel.userName!.substring(0, 1)
                        : '',
                    style: const TextStyle(
                      color: Color(0xFF6583B2),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    authModel != null ? authModel.userName! : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                shrinkWrap: true, // 내용 크기만큼만 차지
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 80,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4),
                itemBuilder: (context, index) {
                  return index == 0 && nowPage == 0
                      ? _emptyWidget()
                      : _conferenceWidget(
                          modelList[nowPage == 0
                              ? (index - 1)
                              : (nowPage * perPage + index - 1)],
                          localKr
                              ? ('항목 ${nowPage == 0 ? index : index + 1} 입장')
                              : ('Join ${nowPage == 0 ? index : index + 1}'));
                },
                itemCount: itemsInPage(nowPage, modelList.length + 1),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                if (nowPage != 0) ...[
                  _leftPageWidget(),
                  SizedBox(
                    width: 30,
                  ),
                ],
                if (nowPage < ((modelList.length + 1) / perPage).ceil() - 1 &&
                    (modelList.length + 1) >= perPage) ...[
                  _rightPageWidget(modelList.length),
                ],
                Spacer(),
                Image.asset(
                  'assets/icons/ic_voice.png',
                  width: 40,
                  height: 40,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  localKr ? '로그아웃' : 'Logout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 180,
                  height: 55,
                  child: Semantics(
                    value: 'hf_no_number',
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: const Color(0xFF246CFD),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          logout();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/ic_logout.png',
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Logout',
                              style: TextStyle(
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        )),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  logout() {
    context.go('/signin');

    ref.read(authViewModelProvider.notifier).logout();

    final asyncShared = SharedPreferencesAsync();
    asyncShared.remove('email');
  }

  prevFunc() {
    if (nowPage > 0) {
      setState(() {
        nowPage--;
      });
    }
  }

  Widget _leftPageWidget() {
    return Row(
      children: [
        Image.asset(
          'assets/icons/ic_voice.png',
          width: 40,
          height: 40,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          localKr ? '이전' : 'Previous',
          style: TextStyle(
              color: Color(0xFF7D7D7D),
              fontSize: 22,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          width: 20,
        ),
        Semantics(
          value: 'hf_no_number',
          child: GestureDetector(
            onTap: () {
              prevFunc();
            },
            child: CircleAvatar(
              radius: 24, // 크기
              backgroundColor: MyColors.primary.withOpacity(0.8),
              child: Icon(
                Icons.arrow_left,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  nextFunc(int total) {
    int totalPages;
    if (total <= 5) {
      totalPages = 1;
    } else {
      totalPages = 1 + ((total - 5) / perPage).ceil();
    }
    final bool showNext = nowPage < totalPages - 1;

    if (showNext) {
      setState(() {
        nowPage++;
      });
    }
  }

  Widget _rightPageWidget(int total) {
    return Row(
      children: [
        Semantics(
          value: 'hf_no_number',
          child: GestureDetector(
            onTap: () {
              nextFunc(total);
            },
            child: CircleAvatar(
              radius: 24, // 크기
              backgroundColor: MyColors.primary.withOpacity(0.8),
              child: Icon(
                Icons.arrow_right,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
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
          localKr ? '다음' : 'Next',
          style: TextStyle(
              color: Color(0xFF7D7D7D),
              fontSize: 22,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  int itemsInPage(int pageIndex, int totalItems) {
    int start = pageIndex * perPage;
    int remaining = totalItems - start;
    return remaining > perPage ? perPage : remaining;
  }

  goConference(ConferenceModel model) {
    MyLoading().showLoading(context);

    AuthModel? authModel = ref.read(authViewModelProvider);
    if (authModel != null) {
      ref.read(tokenViewModelProvider.notifier).createToken(
            meetId: model.meetId!,
            accountNo: authModel.accountNo!,
            successFunc: (String token) async {
              MyLoading().hideLoading(context);

              await LepsiRwSpeechRecognizer.restoreCommands();

              LepsiRwSpeechRecognizer.setCommands(<String>[
                '네',
                'Okay',
                '취소',
                'Cancel',
              ], (command) async {
                logger.i(command);

                //이전 다음 화면체크해야됨

                switch (command) {
                  case '네':
                  case 'Okay':
                    MyLoading().showLoading(context);

                    ref.read(conferenceViewModelProvider.notifier).joinRoom(
                        meetId: model.meetId!,
                        accountNo: authModel.accountNo!,
                        userName: authModel.userName!,
                        companyNo: authModel.companyNo!,
                        successFunc: () async {
                          // 이 룸정보 넣어줘야될듯

                          ref
                              .read(conferenceViewModelProvider.notifier)
                              .init(model: model);

                          context.pop(true);

                          // await AppConfig.hideStatusNavigationBar();

                          await LepsiRwSpeechRecognizer.restoreCommands();

                          context.push('/conference/detail', extra: {
                            'meetId': model.meetId!,
                            'token': token,
                            'accountNo': authModel.accountNo!,
                            'companyNo': authModel.companyNo!,
                          }).then(
                            (_) {
                              rw();
                            },
                          );
                        },
                        failFunc: () async {
                          MyToasts().showNormal('This is a closed meeting.');
                          MyLoading().hideLoading(context);
                          context.pop();

                          // await LepsiRwSpeechRecognizer.restoreCommands();
                          // rw();
                        });
                    break;

                  case '취소':
                  case 'Cancel':
                    context.pop();
                    break;
                }
              });

              showDialog(
                context: context,
                builder: (context) => NormalAlertDialog(
                  title: 'Wolud you like to join this meeting room?',
                  btnTitle: 'OK',
                  onTap: () {
                    MyLoading().showLoading(context);

                    ref.read(conferenceViewModelProvider.notifier).joinRoom(
                        meetId: model.meetId!,
                        accountNo: authModel.accountNo!,
                        userName: authModel.userName!,
                        companyNo: authModel.companyNo!,
                        successFunc: () async {
                          // 이 룸정보 넣어줘야될듯

                          ref
                              .read(conferenceViewModelProvider.notifier)
                              .init(model: model);

                          context.pop(true);

                          // await AppConfig.hideStatusNavigationBar();

                          await LepsiRwSpeechRecognizer.restoreCommands();

                          context.push('/conference/detail', extra: {
                            'meetId': model.meetId!,
                            'token': token,
                            'accountNo': authModel.accountNo!,
                            'companyNo': authModel.companyNo!,
                          }).then(
                            (_) {
                              rw();
                            },
                          );
                        },
                        failFunc: () {
                          MyToasts().showNormal('This is a closed meeting.');
                          MyLoading().hideLoading(context);
                          context.pop();
                        });
                  },
                ),
              ).then(
                (value) {
                  if (value == null) {
                    rw();
                  }
                },
              );
            },
          );
    }
  }

  Widget _conferenceWidget(ConferenceModel model, String voiceMent) {
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFF333347),
                offset: Offset(5, 5),
                blurRadius: 10,
              )
            ],
          ),
          child: Semantics(
            value: 'hf_no_number',
            child: Material(
              color: const Color(0xFF272B37),
              borderRadius: BorderRadius.circular(15),
              child: Semantics(
                value: 'hf_no_number',
                child: InkWell(
                  highlightColor: const Color(0xFF4A90DC).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    goConference(model);
                  },
                  child: Semantics(
                    value: 'hf_no_number',
                    child: Center(
                      child: Text(
                        model.subject ?? '',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/ic_voice.png',
              width: 40,
              height: 40,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              voiceMent,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }

  Widget _emptyWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFF333347),
                offset: Offset(5, 5),
                blurRadius: 10,
              )
            ],
          ),
          child: Material(
            color: const Color(0xFF272B37),
            borderRadius: BorderRadius.circular(15),
            child: Semantics(
              value: 'hf_no_number',
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () async {
                  context.push('/invite');
                },
                child: Center(
                  child: Image.asset(
                    'assets/icons/ic_add.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/ic_voice.png',
              width: 40,
              height: 40,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              localKr ? '방 만들기' : 'Create',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }
}
