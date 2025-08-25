import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/utils/myLoading.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/authViewModel.dart';
import 'package:realwear_flutter/viewModels/conferenceListViewModel.dart';
import 'package:realwear_flutter/viewModels/inviteMemberViewModel.dart';
import 'package:realwear_flutter/widgets/normalAlertDialog.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final emailTextCon = TextEditingController();
  final pwTextCon = TextEditingController();

  final emailFocus = FocusNode();
  final pwFocus = FocusNode();

  final RegExp emailReg =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  final RegExp pwReg =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FF),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                color: Color(0xFF314165),
                fontSize: 45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Secure access to your meetings. Log in now.',
              style: TextStyle(
                  color: Color(0xFF7D7D7D),
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 550,
              child: TextField(
                controller: emailTextCon,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                focusNode: emailFocus,
                keyboardType: TextInputType.emailAddress,
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
                    hintText: 'Enter your e-mail',
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
                      borderSide:
                          const BorderSide(color: Color(0xFFCDCDCD), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFF1791F4), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFCDCDCD), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFFF4242), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFFF4242), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 15),
                      child: Image.asset(
                        'assets/icons/ic_mail.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                    suffixIcon: SizedBox(
                      width: 200,
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
                            '아이디 입력',
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
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 550,
              child: TextField(
                controller: pwTextCon,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                focusNode: pwFocus,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.w500),
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                cursorColor: MyColors.primary,
                obscureText: true,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    isDense: false,
                    counterText: '',
                    hintText: 'Enter your password',
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
                      borderSide:
                          const BorderSide(color: Color(0xFFCDCDCD), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFF1791F4), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFCDCDCD), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFFF4242), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFFF4242), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 15),
                      child: Image.asset(
                        'assets/icons/ic_pw.png',
                        width: 25,
                        height: 26,
                      ),
                    ),
                    suffixIcon: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Image.asset(
                            'assets/icons/ic_voice.png',
                            width: 35,
                            height: 35,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '비밀번호 입력',
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
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 550,
              child: PrimaryButton(
                title: 'Login',
                height: 60,
                onTap: () {
                  login();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  login() {
    if (emailTextCon.text.isEmpty) {
      cancelDialog();
      return;
    }

    if (!emailReg.hasMatch(emailTextCon.text)) {
      cancelDialog();
      return;
    }

    if (pwTextCon.text.isEmpty) {
      cancelDialog();
      return;
    }

    if (!pwReg.hasMatch(pwTextCon.text)) {
      cancelDialog();
      return;
    }

    MyLoading().showLoading(context);
    ref.read(authViewModelProvider.notifier).login(
          email: emailTextCon.text,
          pw: pwTextCon.text,
          duplicateFunc: () {
            MyToasts().showNormal('This email is already signed in.');
            MyLoading().hideLoading(context);
          },
          failFunc: (bool isEmail) {
            MyLoading().hideLoading(context);

            cancelDialog();
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

            MyLoading().hideLoading(context);

            context.go('/conference');
          },
        );
  }

  cancelDialog() {
    showDialog(
      context: context,
      builder: (context) => NormalAlertDialog(
        title: 'Please check your Email and Password.',
        btnTitle: 'OK',
        onTap: () {
          context.pop();
        },
      ),
    );
  }
}
