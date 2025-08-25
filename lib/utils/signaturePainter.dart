import 'package:flutter/cupertino.dart';
import 'package:realwear_flutter/models/drawModel.dart';

class SignaturePainter extends CustomPainter {
  final List<DrawModel> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].point != Offset.zero &&
          points[i + 1].point != Offset.zero) {
        // 두 점 모두 Offset.zero가 아닐 경우에만 선을 그림
        paint.color = points[i].color; // 점의 색상
        paint.strokeWidth = points[i].strokeWidth * 2; // 점의 두께
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return true;
  }
}
