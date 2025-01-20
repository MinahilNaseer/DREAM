
import 'dart:ui' as ui;
import 'package:flame/components.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flame/events.dart';

class GiftBoxComponent extends SpriteComponent with TapCallbacks {
  final Function onGiftOpened;

  GiftBoxComponent({
    required this.onGiftOpened,
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position);

  @override
  bool onTapUp(TapUpEvent event) {
    onGiftOpened();
    return true;
  }
}