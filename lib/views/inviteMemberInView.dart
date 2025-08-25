import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/chatViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberInViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
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
    // TODO: implement initState
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
  Widget build(BuildContext context) {
    List<AuthModel> inModelList = ref.watch(inviteMemberInViewModelProvider);
    AuthModel myModel = ref.watch(authViewModelProvider)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        color: Colors.white,
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
                    color: Color(0xFF435664),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Attendee',
                          style: TextStyle(
                              color: Color(0xFF1C3345),
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
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
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Attendee',
                          style: TextStyle(
                              color: Color(0xFF1C3345),
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FBFE),
                              border: Border.all(
                                  color: const Color(0xFFE4F2FF), width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _selectedItem(myModel, false),
                                  for (int i = 0;
                                      i < selectedList.length;
                                      i++) ...[
                                    const SizedBox(
                                      height: 9,
                                    ),
                                    _selectedItem(selectedList[i],
                                        inModelList.contains(selectedList[i]))
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
                        width: 30,
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
                          '취소',
                          style: TextStyle(
                              color: Color(0xFF7D7D7D),
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 120,
                          height: 50,
                          child: PrimaryButton(
                            isWhite: true,
                            title: 'Cancel',
                            onTap: () {
                              context.pop();
                            },
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
                          '초대',
                          style: TextStyle(
                              color: Color(0xFF7D7D7D),
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 120,
                          height: 50,
                          child: PrimaryButton(
                            title: 'Invite',
                            onTap: () {
                              invite(myModel);
                            },
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
            if (nowPage > 0) {
              setState(() {
                nowPage--;
              });
            }
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
      ],
    );
  }

  Widget _rightPageWidget(int total) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (total / perPage > nowPage) {
              setState(() {
                nowPage++;
              });
            }
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
          '다음',
          style: TextStyle(
              color: Color(0xFF7D7D7D),
              fontSize: 22,
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
              child: _memberItem(item, '항목 ${indexInPage + 1} 선택'),
            );
          }),
          // 마지막 페이지 빈 공간 채우기
          ...List.generate(emptySlots, (_) => Expanded(child: SizedBox())),
        ],
      ),
    );
  }

  Widget _memberItem(AuthModel model, String voiceMent) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          if (!selectedList.contains(model)) {
            selectedList.add(model);
            nowSelectedList.add(model);
          } else {
            selectedList.remove(model);
            nowSelectedList.remove(model);
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Container(
          decoration: BoxDecoration(
            border: !selectedList.contains(model)
                ? Border.all(color: Colors.white, width: 0.7)
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: selectedList.contains(model)
                  ? const Color(0xFF4A90DC).withOpacity(0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: selectedList.contains(model)
                  ? Border.all(color: const Color(0xFF4A90DC), width: 1.5)
                  : Border.all(color: const Color(0xFFD0D0D0), width: 0.7),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFD4D4D4).withOpacity(0.25),
                  offset: const Offset(-2, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFD5E4FC),
                    shape: BoxShape.circle,
                  ),
                  width: 30,
                  height: 30,
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
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        model.userName ?? '',
                        style: const TextStyle(
                            color: Color(0xFF4E4E4E),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
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
                          color: Color(0xFF7D7D7D),
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Image.asset(
                  selectedList.contains(model)
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
    );
  }

  Widget _selectedItem(AuthModel model, bool isClose) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isClose
          ? () {
              setState(() {
                selectedList.remove(model);
                nowSelectedList.remove(model);
              });
            }
          : null,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFCDCDCD), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              model.userName ?? '',
              style: const TextStyle(
                  color: Color(0xFF4E4E4E),
                  fontSize: 23,
                  fontWeight: FontWeight.w500),
            ),
            if (isClose)
              Image.asset(
                'assets/icons/ic_invite_close_red.png',
                width: 30,
                height: 30,
              ),
          ],
        ),
      ),
    );
  }
}
