import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/models/authModel.dart';
import 'package:realwear_flutter/utils/createChannel.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/utils/myLoading.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
import 'package:realwear_flutter/viewModels/tokenViewModel.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';

class InviteMemberView extends ConsumerStatefulWidget {
  const InviteMemberView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InviteMemberViewState();
}

class _InviteMemberViewState extends ConsumerState<InviteMemberView> {
  List<AuthModel> selectedList = [];

  int nowPage = 0;
  int perPage = 4;

  void _onRefresh() async {
    AuthModel authModel = ref.read(authViewModelProvider)!;

    ref.read(inviteMemberViewModelProvider.notifier).getMemberList(
        companyNo: authModel.companyNo!, email: authModel.email!);

    setState(() {
      selectedList = [];
    });
  }

  invite() {
    AuthModel authModel = ref.read(authViewModelProvider)!;
    String meetId = CreateChannel().createChannelId();

    ref.read(tokenViewModelProvider.notifier).createToken(
          meetId: meetId,
          accountNo: authModel.accountNo!,
          successFunc: (String token) {
            ref.read(conferenceViewModelProvider.notifier).createConference(
                meetId: meetId,
                accountNo: authModel.accountNo!,
                companyNo: authModel.companyNo!,
                subject: authModel.userName!,
                authList: selectedList);

            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    width: 390,
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        Image.asset(
                          'assets/icons/ic_dialog_check.png',
                          width: 64,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Success!',
                          style: TextStyle(
                            color: Color(0xFF435664),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Your conference room has been successfully created.',
                            style: TextStyle(
                              color: Color(0xFF6F6F6F),
                              fontSize: 23,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        SizedBox(
                          width: 135,
                          child: PrimaryButton(
                            title: 'OK',
                            onTap: () {
                              MyLoading().showLoading(context);

                              ref
                                  .read(conferenceViewModelProvider.notifier)
                                  .joinRoom(
                                      meetId: meetId,
                                      accountNo: authModel.accountNo!,
                                      userName: authModel.userName!,
                                      companyNo: authModel.companyNo!,
                                      successFunc: () async {
                                        // 이 룸정보 넣어줘야될듯

                                        ref
                                            .read(conferenceViewModelProvider
                                                .notifier)
                                            .getConference(meetId: meetId);

                                        context.pop();
                                        context.pop(true);

                                        context
                                            .push('/conference/detail', extra: {
                                          'meetId': meetId,
                                          'token': token,
                                          'accountNo': authModel.accountNo!,
                                          'companyNo': authModel.companyNo!,
                                        });
                                      },
                                      failFunc: () {
                                        MyToasts().showNormal(
                                            'This is a closed meeting.');
                                        MyLoading().hideLoading(context);
                                        context.pop(false);
                                      });
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    List<AuthModel> modelList = ref.watch(inviteMemberViewModelProvider);
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
                        _list(modelList),
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
                                    _selectedItem(selectedList[i], true)
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
                    if (nowPage < (modelList.length / perPage).ceil() - 1) ...[
                      _rightPageWidget(modelList.length),
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
                              invite();
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

  Widget _selectedItem(AuthModel model, bool isClose) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isClose
          ? () {
              setState(() {
                selectedList.remove(model);
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

  Widget _memberItem(AuthModel model, String voiceMent) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          if (!selectedList.contains(model)) {
            selectedList.add(model);
          } else {
            selectedList.remove(model);
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
}
