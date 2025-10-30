import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myColors.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/viewModels/localeViewModel.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternalIpView extends ConsumerStatefulWidget {
  const InternalIpView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InternalIpViewState();
}

class _InternalIpViewState extends ConsumerState<InternalIpView> {
  final TextEditingController ipEditingController =
      TextEditingController(text: 'http://192.168.50.190');
  final TextEditingController portEditingController =
      TextEditingController(text: '5000');

  final ipFocus = FocusNode();
  final portFocus = FocusNode();

  // bool localKr = true;

  @override
  void initState() {
    // localKr = ref.read(localeViewModelProvider) == 'KOR';
    super.initState();
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
                                      'IP Input',
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
                                      'Port Input',
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
                        child: PrimaryButton(
                          title: 'Connect',
                          onTap: () async {
                            if (ipEditingController.text.isEmpty) {
                              MyToasts().showNormal('Please enter the IP.');
                              return;
                            }

                            if (portEditingController.text.isEmpty) {
                              MyToasts().showNormal('Please enter the Port.');
                              return;
                            }

                            try {
                              await SocketManager().connect(
                                  '${ipEditingController.text}:${portEditingController.text}');

                              setState(() {
                                AppConfig.isExternal = false;

                                print(AppConfig.isExternal);

                                AppConfig.INTERNAL_URL =
                                    '${ipEditingController.text}:${portEditingController.text}';
                              });

                              final SharedPreferencesAsync asyncPrefs =
                                  SharedPreferencesAsync();

                              asyncPrefs.setString(
                                  'internalURL', AppConfig.INTERNAL_URL);

                              asyncPrefs.setBool(
                                  'isExternal', AppConfig.isExternal);

                              context.go('/');
                            } catch (e) {
                              MyToasts().showNormal(
                                  'Internal Network Socket Connect Error');
                              context.go('/network');
                            }
                          },
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
}
