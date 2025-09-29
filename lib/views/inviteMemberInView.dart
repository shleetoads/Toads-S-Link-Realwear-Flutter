import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lepsi_rw_speech_recognizer/lepsi_rw_speech_recognizer.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/chatViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberInViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';

class InviteMemberInView extends ConsumerStatefulWidget {
  final String meetId;
  final String subject;

  const InviteMemberInView(
      {super.key, required this.meetId, required this.subject});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InviteMemberInViewState();
}

class _InviteMemberInViewState extends ConsumerState<InviteMemberInView> {
  List<AuthModel> selectedList = [];
  List<AuthModel> nowSelectedList = [];

  int nowPage = 0;
  int perPage = 4;

  bool localKr = true;

  final scrollController = ScrollController();

  rw() {
    LepsiRwSpeechRecognizer.setCommands(<String>[
      '초대',
      'Invite',
      '취소',
      'Cancel',
      '다음',
      'Next',
      '이전',
      'Previous',
      '항목 1 선택',
      'Select One',
      '항목 2 선택',
      'Select Two',
      '항목 3 선택',
      'Select Three',
      '항목 4 선택',
      'Select Four',
      '항목 1 취소',
      'Cancel One',
      '항목 2 취소',
      'Cancel Two',
      '항목 3 취소',
      'Cancel Three',
      '항목 4 취소',
      'Cancel Four',
      '항목 5 취소',
      'Cancel Five',
      '항목 6 취소',
      'Cancel Six',
      '항목 7 취소',
      'Cancel Seven',
      '항목 8 취소',
      'Cancel Eight',
      '위로',
      'Page Up',
      '아래로',
      'Page Down'
    ], (command) async {
      logger.i(command);

      //이전 다음 화면체크해야됨

      switch (command) {
        case '위로':
        case 'Page Up':
          scrollController.animateTo(
            scrollController.offset - 250,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
          break;
        case '아래로':
        case 'Page Down':
          scrollController.animateTo(
            scrollController.offset + 250,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
          break;
        case '초대':
        case 'Invite':
          AuthModel authModel = ref.read(authViewModelProvider)!;
          invite(authModel);
          break;
        case '취소':
        case 'Cancel':
          context.pop();
          break;
        case '이전':
        case 'Previous':
          prevFunc();
          break;
        case '다음':
        case 'Next':
          List<AuthModel> modelList = ref.read(inviteMemberInViewModelProvider);
          nextFunc(modelList.length);
          break;
        case '항목 1 선택':
        case 'Select One':
          List<AuthModel> modelList = ref.read(inviteMemberInViewModelProvider);
          int index = nowPage * perPage;
          if (index + 1 <= modelList.length) {
            setState(() {
              if (!nowSelectedList.contains(modelList[index])) {
                // selectedList.add(modelList[index]);
                nowSelectedList.add(modelList[index]);
              } else {
                // selectedList.remove(modelList[index]);
                nowSelectedList.remove(modelList[index]);
              }
            });
          }
          break;
        case '항목 2 선택':
        case 'Select Two':
          List<AuthModel> modelList = ref.read(inviteMemberInViewModelProvider);
          int index = nowPage * perPage + 1;
          if (index + 1 <= modelList.length) {
            setState(() {
              if (!nowSelectedList.contains(modelList[index])) {
                // selectedList.add(modelList[index]);
                nowSelectedList.add(modelList[index]);
              } else {
                // selectedList.remove(modelList[index]);
                nowSelectedList.remove(modelList[index]);
              }
            });
          }
          break;
        case '항목 3 선택':
        case 'Select Three':
          List<AuthModel> modelList = ref.read(inviteMemberInViewModelProvider);
          int index = nowPage * perPage + 2;
          if (index + 1 <= modelList.length) {
            setState(() {
              if (!nowSelectedList.contains(modelList[index])) {
                // selectedList.add(modelList[index]);
                nowSelectedList.add(modelList[index]);
              } else {
                // selectedList.remove(modelList[index]);
                nowSelectedList.remove(modelList[index]);
              }
            });
          }
          break;
        case '항목 4 선택':
        case 'Select Four':
          List<AuthModel> modelList = ref.read(inviteMemberInViewModelProvider);
          int index = nowPage * perPage + 3;
          if (index + 1 <= modelList.length) {
            setState(() {
              if (!nowSelectedList.contains(modelList[index])) {
                // selectedList.add(modelList[index]);
                nowSelectedList.add(modelList[index]);
              } else {
                // selectedList.remove(modelList[index]);
                nowSelectedList.remove(modelList[index]);
              }
            });
          }
          break;
        case '항목 1 취소':
        case 'Cancel One':
          if (nowSelectedList.isNotEmpty) {
            setState(() {
              // selectedList.remove(selectedList[0]);
              nowSelectedList.remove(nowSelectedList[0]);
            });
          }
          break;
        case '항목 2 취소':
        case 'Cancel Two':
          if (nowSelectedList.length > 1) {
            setState(() {
              // selectedList.remove(selectedList[1]);
              nowSelectedList.remove(nowSelectedList[1]);
            });
          }
          break;
        case '항목 3 취소':
        case 'Cancel Three':
          if (nowSelectedList.length > 2) {
            setState(() {
              // selectedList.remove(selectedList[2]);
              nowSelectedList.remove(nowSelectedList[2]);
            });
          }
          break;
        case '항목 4 취소':
        case 'Cancel Four':
          if (nowSelectedList.length > 3) {
            setState(() {
              // selectedList.remove(selectedList[3]);
              nowSelectedList.remove(nowSelectedList[3]);
            });
          }
          break;
        case '항목 5 취소':
        case 'Cancel Five':
          if (nowSelectedList.length > 4) {
            setState(() {
              // selectedList.remove(selectedList[4]);
              nowSelectedList.remove(nowSelectedList[4]);
            });
          }
          break;
        case '항목 6 취소':
        case 'Cancel Six':
          if (nowSelectedList.length > 5) {
            setState(() {
              // selectedList.remove(selectedList[5]);
              nowSelectedList.remove(nowSelectedList[5]);
            });
          }
          break;
        case '항목 7 취소':
        case 'Cancel Seven':
          if (nowSelectedList.length > 6) {
            setState(() {
              // selectedList.remove(selectedList[6]);
              nowSelectedList.remove(nowSelectedList[6]);
            });
          }
          break;
        case '항목 8 취소':
        case 'Cancel Eight':
          if (nowSelectedList.length > 7) {
            setState(() {
              // selectedList.remove(selectedList[7]);
              nowSelectedList.remove(nowSelectedList[7]);
            });
          }
          break;
      }
    });
  }

  void _onRefresh() async {
    AuthModel? authModel = ref.read(authViewModelProvider);

    ref.read(inviteMemberInViewModelProvider.notifier).getUninviteMemberList(
        meetId: widget.meetId,
        companyNo: authModel!.companyNo!,
        successFunc: () {
          List<AuthModel> modelList = ref.read(inviteMemberViewModelProvider);
          List<AuthModel> inModelList =
              ref.read(inviteMemberInViewModelProvider);

          print(modelList.length);
          print(inModelList.length);

          setState(() {
            selectedList =
                modelList.where((item) => !inModelList.contains(item)).toList();
            print(selectedList);
          });
        });
  }

  invite(AuthModel myAuthModel) {
    // AuthModel authModel = ref.read(authViewModelProvider)!;
    ref.read(conferenceViewModelProvider.notifier).invite(
          authList: nowSelectedList,
          subject: widget.subject,
          meetId: widget.meetId,
          /*member_id: authModel.accountNo!,
        company_id: authModel.companyNo!*/
        );

    ref.read(chatViewModelProvider.notifier).notice(
        meetId: widget.meetId,
        accountNo: myAuthModel.accountNo!,
        message:
            "${(nowSelectedList.map((e) => e.userName!).toList()).join(' and ')} invited to the room.",
        color: jsonEncode({
          'r': 0,
          'g': 255,
          'b': 30,
          'a': 255,
        }));

    context.pop();
  }

  @override
  void initState() {
    localKr = ref.read(localeViewModelProvider) == 'KOR';

    rw();
    super.initState();

    //전체 멤버에서
    List<AuthModel> modelList = ref.read(inviteMemberViewModelProvider);
    List<AuthModel> inModelList = ref.read(inviteMemberInViewModelProvider);

    print(modelList.length);
    print(inModelList.length);

    setState(() {
      selectedList =
          modelList.where((item) => !inModelList.contains(item)).toList();
      print(selectedList);
    });
  }

  @override
  void dispose() {
    LepsiRwSpeechRecognizer.restoreCommands();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<AuthModel> inModelList = ref.watch(inviteMemberInViewModelProvider);
    AuthModel myModel = ref.watch(authViewModelProvider)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        color: Color(0xFF181820),
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                nowSelectedList.length + selectedList.length > 3
                    ? Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              'assets/icons/ic_voice.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              localKr ? '위로/아래로' : 'Page Up/Down',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : SizedBox()
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Image.asset(
                //       'assets/icons/ic_voice.png',
                //       width: 40,
                //       height: 40,
                //     ),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     Text(
                //       '새로고침',
                //       style: TextStyle(
                //           color: Color(0xFF7D7D7D),
                //           fontSize: 22,
                //           fontWeight: FontWeight.w500),
                //     ),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     GestureDetector(
                //       onTap: () {
                //         _onRefresh();
                //       },
                //       child: CircleAvatar(
                //         radius: 20, // 크기
                //         backgroundColor: MyColors.primary.withOpacity(0.8),
                //         child: Icon(
                //           Icons.refresh_rounded,
                //           color: Colors.white,
                //           size: 20,
                //         ),
                //       ),
                //     ),
                //   ],
                // )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Attendee',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Page ${nowPage + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        _list(inModelList),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Attendee',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  _selectedItem(myModel, false, 0),
                                  for (int i = 0;
                                      i < selectedList.length;
                                      i++) ...[
                                    const SizedBox(
                                      height: 9,
                                    ),
                                    _selectedItem(selectedList[i], false, i),
                                  ],
                                  for (int i = 0;
                                      i < nowSelectedList.length;
                                      i++) ...[
                                    const SizedBox(
                                      height: 9,
                                    ),
                                    _selectedItem(nowSelectedList[i], true, i)
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    if (nowPage != 0) ...[
                      _leftPageWidget(),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                    if (nowPage <
                        (inModelList.length / perPage).ceil() - 1) ...[
                      _rightPageWidget(inModelList.length),
                    ],
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/ic_voice.png',
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          localKr ? '취소' : 'Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: localKr ? 22 : 18,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 120,
                          height: 50,
                          child: Semantics(
                            value: 'hf_no_number',
                            child: PrimaryButton(
                              isWhite: true,
                              title: 'Cancel',
                              onTap: () {
                                context.pop();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/ic_voice.png',
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          localKr ? '초대' : 'Invite',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: localKr ? 22 : 18,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 120,
                          height: 50,
                          child: Semantics(
                            value: 'hf_no_number',
                            child: PrimaryButton(
                              title: 'Invite',
                              onTap: () {
                                invite(myModel);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _leftPageWidget() {
    return Row(
      children: [
        Image.asset(
          'assets/icons/ic_voice.png',
          width: 30,
          height: 30,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          localKr ? '이전' : 'Previous',
          style: TextStyle(
              color: Colors.white,
              fontSize: localKr ? 22 : 18,
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
              radius: 18, // 크기
              backgroundColor: MyColors.primary.withOpacity(0.8),
              child: Icon(
                Icons.arrow_left,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  prevFunc() {
    if (nowPage > 0) {
      setState(() {
        nowPage--;
      });
    }
  }

  nextFunc(int total) {
    final int totalPages = (total / perPage).ceil();
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
              radius: 18, // 크기
              backgroundColor: MyColors.primary.withOpacity(0.8),
              child: Icon(
                Icons.arrow_right,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Image.asset(
          'assets/icons/ic_voice.png',
          width: 30,
          height: 30,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          localKr ? '다음' : 'Next',
          style: TextStyle(
              color: Colors.white,
              fontSize: localKr ? 22 : 18,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _list(List<AuthModel> modelList) {
    int startIndex = nowPage * perPage;
    int endIndex = (startIndex + perPage).clamp(0, modelList.length);
    List<AuthModel> pageItems = modelList.sublist(startIndex, endIndex);

    int itemsInPage = pageItems.length;
    int emptySlots = perPage - itemsInPage;

    return Flexible(
      child: Column(
        children: [
          ...pageItems.asMap().entries.map((entry) {
            int indexInPage = entry.key; // 0~3번째
            AuthModel item = entry.value;
            return Expanded(
              child: _memberItem(
                  item,
                  localKr
                      ? '항목 ${indexInPage + 1} 선택'
                      : 'Select ${indexInPage + 1}'),
            );
          }),
          // 마지막 페이지 빈 공간 채우기
          ...List.generate(emptySlots, (_) => Expanded(child: SizedBox())),
        ],
      ),
    );
  }

  Widget _memberItem(AuthModel model, String voiceMent) {
    return Semantics(
      value: 'hf_no_number',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            if (!nowSelectedList.contains(model)) {
              // selectedList.add(model);
              nowSelectedList.add(model);
            } else {
              // selectedList.remove(model);
              nowSelectedList.remove(model);
            }
          });
        },
        child: Semantics(
          value: 'hf_no_number',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Container(
              decoration: BoxDecoration(
                border: !nowSelectedList.contains(model)
                    ? Border.all(color: Color(0xFF272B37), width: 0.7)
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: nowSelectedList.contains(model)
                      ? const Color(0xFF4A90DC).withOpacity(0.15)
                      : Color(0xFF272B37),
                  borderRadius: BorderRadius.circular(8),
                  border: nowSelectedList.contains(model)
                      ? Border.all(color: const Color(0xFF4A90DC), width: 1.5)
                      : Border.all(color: const Color(0xFF272B37), width: 0.7),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(-2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFD5E4FC),
                        shape: BoxShape.circle,
                      ),
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Text(
                          (model.userName ?? '').substring(0, 1),
                          style: const TextStyle(
                            color: Color(0xFF3769C1),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            model.userName ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            model.companyName ?? '',
                            style: const TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
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
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Image.asset(
                      nowSelectedList.contains(model)
                          ? 'assets/icons/ic_invite_check.png'
                          : 'assets/icons/ic_invite_add.png',
                      width: 30,
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedItem(AuthModel model, bool isClose, int index) {
    return Semantics(
      value: 'hf_no_number',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: isClose
            ? () {
                setState(() {
                  // selectedList.remove(model);
                  nowSelectedList.remove(model);
                });
              }
            : null,
        child: Semantics(
          value: 'hf_no_number',
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFF272B37),
              // border: Border.all(color: const Color(0xFFCDCDCD), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    model.userName ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                if (isClose)
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/icons/ic_voice.png',
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Text(
                            localKr
                                ? '항목 ${index + 1} 취소'
                                : 'Cancel ${index + 1}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Image.asset(
                          'assets/icons/ic_invite_close_red.png',
                          width: 25,
                          height: 25,
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
