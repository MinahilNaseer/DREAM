
import 'package:flutter/material.dart';
import 'package:flame/components.dart';


class TextComponent extends PositionComponent {
  final String text;
  final TextPaint textRenderer;

  TextComponent({
    required this.text,
    required Vector2 position,
  })  : textRenderer = TextPaint(
          style: TextStyle(
              color: Color.fromARGB(255, 0, 102, 204),
              fontSize: 27), 
        ),
        super() {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textRenderer.style,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(); 

    
    final x = position.x + (size.x - textPainter.width) / 2;
    final y = position.y + (size.y - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(x, y));
  }
}