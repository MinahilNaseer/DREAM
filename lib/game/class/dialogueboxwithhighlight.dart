
import 'dart:ui' as ui;
import 'package:flame/components.dart'; 
import 'package:flutter/material.dart'; 

class DialogueBoxComponent extends PositionComponent {
  String text;
  String? highlightWord;

  DialogueBoxComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    this.highlightWord,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFFFAF3DD);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(20),
    );
    canvas.drawRRect(rrect, paint);

    final defaultTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      fontFamily: 'Arial',
    );

    final highlightedTextStyle = TextStyle(
      color: Color(0xFF008080),
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Arial',
    );

    final spans = <TextSpan>[];
    text.split(' ').forEach((word) {
      spans.add(
        TextSpan(
          text: word + ' ',
          style:
              word == highlightWord ? highlightedTextStyle : defaultTextStyle,
        ),
      );
    });

    final textPainter = TextPainter(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.x * 0.9,
    );

    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void updateText(String newText, {String? newHighlightWord}) {
    text = newText;
    highlightWord = newHighlightWord;
  }
}
