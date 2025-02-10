
import 'dart:ui' as ui;
import 'package:flame/components.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';


class CongratsDialogueBoxComponent extends PositionComponent with TapCallbacks {
  String text;
  String? highlightWord;
  String? hyperlinkText;
  VoidCallback? onHyperlinkTap;

  CongratsDialogueBoxComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    this.highlightWord,
    this.hyperlinkText,
    this.onHyperlinkTap,
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

    final hyperlinkTextStyle = TextStyle(
      color: Colors.blue,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFamily: 'Arial',
      decoration: TextDecoration.underline,
    );

    final spans = <TextSpan>[
      TextSpan(text: text + '\n', style: defaultTextStyle),
      if (hyperlinkText != null)
        TextSpan(
          text: hyperlinkText,
          style: hyperlinkTextStyle,
          recognizer: TapGestureRecognizer()..onTap = onHyperlinkTap,
        ),
    ];

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

  @override
  bool onTapUp(TapUpEvent event) {
    if (onHyperlinkTap != null) onHyperlinkTap!();
    return true;
  }

  void updateText({
    String? newText,
    String? newHighlightWord,
    String? newHyperlinkText,
    VoidCallback? newHyperlinkCallback,
  }) {
    if (newText != null) text = newText;
    highlightWord = newHighlightWord;
    hyperlinkText = newHyperlinkText;
    onHyperlinkTap = newHyperlinkCallback;
  }
}
