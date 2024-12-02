import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class FishRectangleComponent extends PositionComponent with TapCallbacks {
  final String word;
  final Function(String) onWordSelected; // Callback to notify word selection
  TextPaint textRenderer;
  Paint rectanglePaint; // Paint object for the rectangle color
  bool isSelected = false; // Track if the word has been selected

  FishRectangleComponent({
    required this.word,
    required this.onWordSelected,
    required Vector2 position,
    required Vector2 size,
  })  : textRenderer = TextPaint(
          style: TextStyle(
            color: const Color.fromARGB(255, 0, 102, 204), // Default text color
            fontSize: 18,
          ),
        ),
        rectanglePaint = Paint()
          ..color = const Color.fromARGB(255, 235, 235, 210), // Default rectangle color
        super() {
    this.position = position;
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the rectangle
    final radius = Radius.circular(10);
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), radius);
    canvas.drawRRect(rrect, rectanglePaint); // Draw rectangle with custom paint

    // Draw the word inside the rectangle
    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: textRenderer.style,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position the text to be centered in the rectangle
    final textX = (size.x - textPainter.width) / 2;
    final textY = (size.y - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  // Handle tap event to change the color
  @override
  bool onTapDown(TapDownEvent event) {
    isSelected = true;

    // Change the background to a dyslexic-friendly color (light yellow)
    rectanglePaint.color = const Color.fromARGB(255, 255, 255, 153); // Light yellow

    // Change the text color to distinguish that it's been selected (dark blue)
    textRenderer = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 102), // Dark blue color for selected text
        fontSize: 18,
      ),
    );

    // Notify the game that a word has been selected
    onWordSelected(word);

    return true;
  }

  @override
  void update(double dt) {
    // No additional logic needed, Flame will re-render automatically.
  }
}
