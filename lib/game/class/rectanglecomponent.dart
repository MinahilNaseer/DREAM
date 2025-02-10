
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RectangleComponent extends PositionComponent {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = const Color.fromARGB(255, 235, 235, 210); 
    final radius = Radius.circular(10); 
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y),
        radius); 
    canvas.drawRRect(rrect, paint); 
  }
}