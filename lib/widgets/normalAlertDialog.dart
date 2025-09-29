import 'package:flutter/material.dart';
import 'package:realwear_flutter/widgets/primaryButton.dart';

class NormalAlertDialog extends StatefulWidget {
  final String title;
  final String btnTitle;
  final Function() onTap;
  bool isLand;

  NormalAlertDialog(
      {super.key,
      required this.title,
      required this.btnTitle,
      required this.onTap,
      this.isLand = false});

  @override
  State<NormalAlertDialog> createState() => _NormalAlertDialogState();
}

class _NormalAlertDialogState extends State<NormalAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 400,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Color(0xFF272B37),
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
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Semantics(
                      value: 'hf_no_number',
                      child: PrimaryButton(
                          title: widget.btnTitle, onTap: widget.onTap),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
