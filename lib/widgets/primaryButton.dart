import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final Function()? onTap;
  double? height;
  TextStyle? textStyle;
  bool isWhite;

  PrimaryButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isWhite = false,
    this.textStyle,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: isWhite ? Colors.grey[800] : const Color(0xFF246CFD),
          // side: BorderSide(
          //   color: isWhite ? Colors.grey : const Color(0xFF2A82FF),
          // ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: textStyle ??
              TextStyle(
                  letterSpacing: -0.5,
                  color: isWhite ? Colors.white : Colors.white,
                  fontSize: isWhite ? 23 : 23,
                  fontWeight: isWhite ? FontWeight.w500 : FontWeight.w600),
        ),
      ),
    );
  }
}
