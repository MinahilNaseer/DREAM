import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:dream/game/class/filledroundreccomp.dart' as recstart;

class ToggleButton extends PositionComponent with TapCallbacks {
  final TextComponent buttonText;
  final VoidCallback onPressed;

  ToggleButton({
    required Vector2 position,
    required this.buttonText,
    required this.onPressed,
  }) : super(position: position, size: Vector2(150, 60));

  @override
  void onLoad() {
    add(recstart.FilledRoundedRectangleComponent(
      position: Vector2.zero(),
      size: size,
      color: Colors.green,
      borderRadius: 15,
    ));
    add(buttonText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}
