import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StrokeRoundedRectangleComponent extends RectangleComponent {
  final double cornerRadius;

  StrokeRoundedRectangleComponent({
    required Vector2 size,
    required Vector2 position,
    required Paint paint,
    this.cornerRadius = 10.0,
  }) : super(size: size, position: position, paint: paint);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0;
    canvas.drawRRect(rrect, paint);
  }
}
