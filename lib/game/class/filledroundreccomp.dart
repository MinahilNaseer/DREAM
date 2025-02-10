import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FilledRoundedRectangleComponent extends PositionComponent {
  final Paint paint;
  final double borderRadius;

  FilledRoundedRectangleComponent({
    required Vector2 position,
    required Vector2 size,
    required Color color,
    this.borderRadius = 0,
  })  : paint = Paint()..color = color,
        super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);
  }
}
