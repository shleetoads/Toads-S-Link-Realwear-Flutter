import 'package:flutter/material.dart';

class DrawModel {
  final Offset point;
  final Color color;
  final double strokeWidth;
  final String socketId;

  DrawModel({
    required this.point,
    required this.color,
    required this.strokeWidth,
    required this.socketId,
  });
}
