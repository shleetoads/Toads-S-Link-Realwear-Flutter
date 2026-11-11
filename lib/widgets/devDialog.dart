import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevDialog extends StatefulWidget {
  final RtcEngine? engine;
  final bool myANC;

  const DevDialog({super.key, this.engine, this.myANC = true});

  @override
  State<DevDialog> createState() => _DevDialogState();
}

class _DevDialogState extends State<DevDialog> {
  int dev_ains = 1;
  bool dev_aec = true;
  bool dev_agc = true;
  bool dev_anc = true;
  bool dev_meeting = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = SharedPreferencesAsync();
    final ains = await prefs.getInt('dev_ains') ?? 1;
    final aec = await prefs.getBool('dev_aec') ?? true;
    final agc = await prefs.getBool('dev_agc') ?? true;
    final anc = await prefs.getBool('dev_anc') ?? true;
    final meeting = await prefs.getBool('dev_meeting') ?? true;
    if (mounted) {
      setState(() {
        dev_ains = ains;
        dev_aec = aec;
        dev_agc = agc;
        dev_anc = anc;
        dev_meeting = meeting;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 400,
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
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dev',
                          style: TextStyle(
                            color: Color(0xFF2A82FF),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.myANC)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                const Text(
                                  "AINS 0 / 1 / 2",
                                  style: TextStyle(
                                    color: Color(0xFF636363),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: dev_ains,
                                    isExpanded: true,
                                    items: [0, 1, 2].map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(
                                          value.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (int? value) async {
                                      if (value == null) return;
                                      final engine = widget.engine;
                                      if (engine != null) {
                                        switch (value) {
                                          case 0:
                                            await engine.setAINSMode(
                                                enabled: widget.myANC,
                                                mode: AudioAinsMode
                                                    .ainsModeBalanced);
                                          case 1:
                                            await engine.setAINSMode(
                                                enabled: widget.myANC,
                                                mode: AudioAinsMode
                                                    .ainsModeAggressive);
                                          case 2:
                                            await engine.setAINSMode(
                                                enabled: widget.myANC,
                                                mode: AudioAinsMode
                                                    .ainsModeUltralowlatency);
                                        }
                                      }
                                      await SharedPreferencesAsync()
                                          .setInt('dev_ains', value);
                                      setState(() {
                                        dev_ains = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _switchRow(
                          label: "F : AEC - OFF / T : AEC - ON",
                          value: dev_aec,
                          onChanged: (value) async {
                            if (widget.engine != null) {
                              await widget.engine!.setParameters(value
                                  ? '{"che.audio.aec.enable":true}'
                                  : '{"che.audio.aec.enable":false}');
                            }
                            await SharedPreferencesAsync()
                                .setBool('dev_aec', value);
                            setState(() {
                              dev_aec = value;
                            });
                          },
                        ),
                        _switchRow(
                          label: "F : AGC - OFF / T : AGC - ON",
                          value: dev_agc,
                          onChanged: (value) async {
                            if (widget.engine != null) {
                              await widget.engine!.setParameters(value
                                  ? '{"che.audio.agc.enable":true}'
                                  : '{"che.audio.agc.enable":false}');
                            }
                            await SharedPreferencesAsync()
                                .setBool('dev_agc', value);
                            setState(() {
                              dev_agc = value;
                            });
                          },
                        ),
                        _switchRow(
                          label: "F : ANC - OFF / T : ANC - ON",
                          value: dev_anc,
                          onChanged: (value) async {
                            if (widget.engine != null) {
                              await widget.engine!.setParameters(value
                                  ? '{"che.audio.anc.enable":true}'
                                  : '{"che.audio.anc.enable":false}');
                            }
                            await SharedPreferencesAsync()
                                .setBool('dev_anc', value);
                            setState(() {
                              dev_anc = value;
                            });
                          },
                        ),
                        _switchRow(
                          label: "F : GameStreaming / T : Meeting",
                          value: dev_meeting,
                          onChanged: (value) async {
                            if (widget.engine != null) {
                              await widget.engine!.setAudioScenario(value
                                  ? AudioScenarioType.audioScenarioMeeting
                                  : AudioScenarioType
                                      .audioScenarioGameStreaming);
                            }
                            await SharedPreferencesAsync()
                                .setBool('dev_meeting', value);
                            setState(() {
                              dev_meeting = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    required String label,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF636363),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 38,
            child: FittedBox(
              fit: BoxFit.fill,
              child: CupertinoSwitch(
                value: value,
                activeColor: const Color(0xFF2A82FF),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
