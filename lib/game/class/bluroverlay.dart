import 'dart:ui' as ui;
import 'package:flame/components.dart'; 
import 'package:flutter/material.dart'; 

class BlurOverlayComponent extends PositionComponent {
  BlurOverlayComponent({required Vector2 size}) : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint paint = Paint()..color = Colors.black.withOpacity(0.4);
    canvas.drawRect(size.toRect(), paint);
  }
}