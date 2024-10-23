import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import './rectanglecomponent.dart' as custom_rect; // Use 'as' to prefix the custom component

class FishRectangleComponent extends custom_rect.RectangleComponent { // Using prefixed RectangleComponent
  final String word; 
  final TextPaint textRenderer;

  FishRectangleComponent({
    required this.word,
    required Vector2 position,
    required Vector2 size,
  })  : textRenderer = TextPaint(
          style: TextStyle(
            color: Color.fromARGB(255, 0, 102, 204),
            fontSize: 18,
          ), 
        ),
        super() {
    this.position = position;
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color.fromARGB(255, 235, 235, 210); 
    final radius = Radius.circular(10); 
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), radius); 
    canvas.drawRRect(rrect, paint); 

    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: textRenderer.style,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(); 

    final textX = (size.x - textPainter.width) / 2;
    final textY = (size.y - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY)); 
  }
}
