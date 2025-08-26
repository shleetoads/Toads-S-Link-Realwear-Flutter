import 'package:flutter/material.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    rw();
    super.initState();
  }

  rw() {
    LepsiRwSpeechRecognizer.setCommands(<String>[
      '방만들기',
      '로그아웃',
      '다음',
      '이전',
      '항목 1 선택',
      '항목 2 선택',
      '항목 3 선택',
      '항목 4 선택',
      '항목 5 선택',
      '항목 6 선택',
    ], (command) async {
      logger.i(command);

      //이전 다음 화면체크해야됨

      switch (command) {
        case '방만들기':
          await LepsiRwSpeechRecognizer.restoreCommands();
          context.push('/invite').then((_) {
            rw();
          });
          break;
        case '로그아웃':
          logout();
          break;
        case '다음':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          nextFunc(modelList.length);
          break;
        case '이전':
          prevFunc();
          break;
        case '항목 1 선택':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.isEmpty) {
            break;
          }
          goConference(modelList[nowPage == 0 ? 0 : nowPage * perPage - 1]);
          break;
        case '항목 2 선택':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length < 2) {
            break;
          }
          goConference(modelList[nowPage == 0 ? 1 : nowPage * perPage]);
          break;
        case '항목 3 선택':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length < 3) {
            break;
          }
          goConference(modelList[nowPage == 0 ? 2 : nowPage * perPage + 1]);
          break;
        case '항목 4 선택':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length < 4) {
            break;
          }
          goConference(modelList[nowPage == 0 ? 3 : nowPage * perPage + 2]);
          break;
        case '항목 5 선택':
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length < 5) {
            break;
          }
          goConference(modelList[nowPage == 0 ? 4 : nowPage * perPage + 3]);
          break;
        case '항목 6 선택':
          if (nowPage == 0) {
            break;
          }
          List<ConferenceModel> modelList =
              ref.read(conferenceListViewModelProvider);
          if (modelList.length < 6) {
            break;
          }
          goConference(modelList[nowPage * perPage + 4]);
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
      backgroundColor: Color(0xFFF8FBFE),
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
                  width: 70,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Conference List',
                  style: TextStyle(
                      color: Color(0xFF21385C),
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  authModel != null ? authModel.userName! : '',
                  style: const TextStyle(
                    color: Color(0xFF5F5F5F),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
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
                          '항목 ${nowPage == 0 ? index : index + 1} 선택');
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
                  '로그아웃',
                  style: TextStyle(
                      color: Color(0xFF7D7D7D),
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 180,
                  height: 55,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: const Color(0xFF2A82FF),
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
          '이전',
          style: TextStyle(
              color: Color(0xFF7D7D7D),
              fontSize: 22,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          width: 20,
        ),
        GestureDetector(
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
      ],
    );
  }

  nextFunc(int total) {
    if (total / perPage > nowPage) {
      setState(() {
        nowPage++;
      });
    }
  }

  Widget _rightPageWidget(int total) {
    return Row(
      children: [
        GestureDetector(
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
          '다음',
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
            successFunc: (String token) {
              MyLoading().hideLoading(context);

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

                          context.push('/conference/detail', extra: {
                            'meetId': model.meetId!,
                            'token': token,
                            'accountNo': authModel.accountNo!,
                            'companyNo': authModel.companyNo!,
                          });
                        },
                        failFunc: () {
                          MyToasts().showNormal('This is a closed meeting.');
                          MyLoading().hideLoading(context);
                          context.pop(false);
                        });
                  },
                ),
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
                color: Color(0xFFE4EAF6),
                offset: Offset(5, 5),
                blurRadius: 10,
              )
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              highlightColor: const Color(0xFF4A90DC).withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                goConference(model);
              },
              child: Center(
                child: Text(
                  model.subject ?? '',
                  style: TextStyle(
                    color: const Color(0xFF354056),
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
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
                  color: Color(0xFF7D7D7D),
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
                color: Color(0xFFE4EAF6),
                offset: Offset(5, 5),
                blurRadius: 10,
              )
            ],
          ),
          child: Material(
            color: const Color(0xFFE8F1FF),
            borderRadius: BorderRadius.circular(15),
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
              '방 만들기',
              style: TextStyle(
                  color: Color(0xFF7D7D7D),
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }
}
