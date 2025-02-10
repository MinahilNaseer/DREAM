import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class FishRectangleComponent extends PositionComponent with TapCallbacks {
  final String word;
  final Function(String) onWordSelected; 
  TextPaint textRenderer;
  Paint rectanglePaint; 
  bool isSelected = false; 

  FishRectangleComponent({
    required this.word,
    required this.onWordSelected,
    required Vector2 position,
    required Vector2 size,
  })  : textRenderer = TextPaint(
          style: TextStyle(
            color: const Color.fromARGB(255, 0, 102, 204), 
            fontSize: 18,
          ),
        ),
        rectanglePaint = Paint()
          ..color = const Color.fromARGB(255, 235, 235, 210), 
        super() {
    this.position = position;
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    
    final radius = Radius.circular(10);
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), radius);
    canvas.drawRRect(rrect, rectanglePaint); 

    
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

  
  @override
  bool onTapDown(TapDownEvent event) {
    isSelected = true;

    
    rectanglePaint.color = const Color.fromARGB(255, 255, 255, 153); 

    
    textRenderer = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 102), 
        fontSize: 18,
      ),
    );

    
    onWordSelected(word);

    return true;
  }

  @override
  void update(double dt) {
    
  }
}
