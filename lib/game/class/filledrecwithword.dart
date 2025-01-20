

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FilledRoundedRectangleWithWordComponent extends PositionComponent {
  final Paint paint;
  final double borderRadius;
  final String word;

  FilledRoundedRectangleWithWordComponent({
    required Vector2 position,
    required Vector2 size,
    required Color color,
    required this.word,
    this.borderRadius = 20,
  })  : paint = Paint()..color = color,
        super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the rounded rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);

    // Draw the word in the center of the rectangle
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: word, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x);
    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }
}