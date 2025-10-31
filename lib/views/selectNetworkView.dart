import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:realwear_flutter/dataSource/socketManager.dart';
import 'package:realwear_flutter/utils/appConfig.dart';
import 'package:realwear_flutter/utils/myToasts.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectNetworkView extends ConsumerStatefulWidget {
  const SelectNetworkView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectNetworkViewState();
}

class _SelectNetworkViewState extends ConsumerState<SelectNetworkView> {
  bool showUi = false;

  @override
  void initState() {
    setTimeoutForNextPage();

    super.initState();
  }

  setTimeoutForNextPage() async {
    await Future.delayed(const Duration(milliseconds: 0), () async {
      SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
      bool? isExternal = await asyncPrefs.getBool('isExternal');

      if (isExternal == null) {
        //가만히
        setState(() {
          showUi = true;
        });
      } else if (isExternal) {
        await SocketManager().connect(dotenv.env['BASE_URL']!);

        setState(() {
          AppConfig.isExternal = true;
        });

        asyncPrefs.setBool('isExternal', AppConfig.isExternal);

        context.go('/');
      } else {
        String? url = await asyncPrefs.getString('internalURL');
        if (url != null) {
          await SocketManager().connect(url);

          setState(() {
            AppConfig.INTERNAL_URL = url;
            AppConfig.isExternal = false;
          });

          SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
          asyncPrefs.setBool('isExternal', AppConfig.isExternal);

          context.go('/');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return showUi
        ? Scaffold(
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
                    border:
                        Border.all(color: const Color(0xFFCDCDCD), width: 1),
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      backgroundColor: const Color(0xFF2A82FF),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () async {
                                      final SharedPreferencesAsync asyncPrefs =
                                          SharedPreferencesAsync();
                                      String? url = await asyncPrefs
                                          .getString('internalURL');
                                      if (url == null) {
                                        context.go('/internal/ip');
                                      } else {
                                        try {
                                          await SocketManager().connect(url);

                                          setState(() {
                                            AppConfig.INTERNAL_URL = url;
                                            AppConfig.isExternal = false;
                                          });

                                          SharedPreferencesAsync asyncPrefs =
                                              SharedPreferencesAsync();
                                          asyncPrefs.setBool('isExternal',
                                              AppConfig.isExternal);
                                        } catch (e) {
                                          SocketManager()
                                              .connect(dotenv.env['BASE_URL']!);
                                          MyToasts().showNormal(
                                              'Internal Network Socket Connect Error');
                                        } finally {
                                          context.go('/');
                                        }
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          'Internal Network',
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      backgroundColor: const Color(0xFF2A82FF),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await SocketManager()
                                            .connect(dotenv.env['BASE_URL']!);

                                        setState(() {
                                          AppConfig.isExternal = true;
                                        });

                                        SharedPreferencesAsync asyncPrefs =
                                            SharedPreferencesAsync();
                                        asyncPrefs.setBool(
                                            'isExternal', AppConfig.isExternal);
                                      } catch (e) {
                                        SocketManager()
                                            .connect(AppConfig.INTERNAL_URL);
                                        MyToasts().showNormal(
                                            'External Network Socket Connect Error');
                                      } finally {
                                        context.go('/');
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          'External Network',
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
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            body: Container(
              color: Colors.white,
            ),
          );
  }
}
