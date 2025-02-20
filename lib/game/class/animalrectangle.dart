
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:dream/game/class/filledroundreccomp.dart';


class AnimalRectangle extends PositionComponent with TapCallbacks {
  final String text;
  final Function(AnimalRectangle) onTapCallback;
  bool isSelected = false;
  late FilledRoundedRectangleComponent background;
  late TextComponent textComponent;

  AnimalRectangle({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    required this.onTapCallback,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    background = FilledRoundedRectangleComponent(
      position: Vector2.zero(),
      size: size,
      color: const Color(0xFF90EE90).withOpacity(0.8),
      borderRadius: 15,
    );
    add(background);

    textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(
        size.x / 2 - text.length * 4.5,
        size.y / 4,
      ),
    );
    add(textComponent);
  }

  void select() {
    isSelected = true;

    background.paint.color = const Color(0xFF007BFF).withOpacity(0.8);
    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void unselect() {
    isSelected = false;

    background.paint.color = const Color(0xFF90EE90).withOpacity(0.8);
    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapCallback(this);
  }
}