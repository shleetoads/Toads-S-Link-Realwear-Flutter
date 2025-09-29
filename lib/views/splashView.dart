import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/conferenceListViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    setTimeoutForNextPage();

    super.initState();
  }

  setTimeoutForNextPage() async {
    await Future.delayed(const Duration(milliseconds: 0), () async {
      nextFunc();
    });
  }

  nextFunc() async {
    final SharedPreferencesAsync asyncShare = SharedPreferencesAsync();
    String? email = await asyncShare.getString('email');

    if (email == null) {
      print('자동로그인 x');
      context.go('/signin');
    } else {
      //자동로그인
      print('자동로그인 o');

      // context.go('/home');
      ref.read(authViewModelProvider.notifier).autoLogin(
            email: email,
            duplicateFunc: () {
              MyToasts().showNormal('This email is already signed in.');
              context.go('/signin');
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

              context.go('/conference');
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
