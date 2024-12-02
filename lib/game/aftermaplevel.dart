import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/timer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'forestlevel.dart';
import 'dart:math';

class Aftermaplevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent forest;
  late SpriteComponent mapScrool;
  late SpriteComponent molly;
  late DialogueBoxComponent dialogueBox;
  SpriteComponent? gate;

  late FlutterTts _flutterTts;

  bool isMoving = false;
  final double speed = 100;
  final double cycleSpeed = 70;
  bool isForestRemoved = false;
  late Timer gateTimer;
  
  bool isDialogueBoxDisplayed = false;
  bool isMollyDisplayed = false;

  @override
  Future<void> onLoad() async {
    await _initializeTTS();

    parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('landscape.jpg'),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
    add(parallaxComponent);

    road1 = SpriteComponent()
      ..sprite = await loadSprite('horizontal-road.png')
      ..size = Vector2(size.x, size.y * 0.18)
      ..position = Vector2(-10, size.y - size.y * 0.18);

    road2 = SpriteComponent()
      ..sprite = await loadSprite('horizontal-road.png')
      ..size = Vector2(size.x, size.y * 0.18)
      ..position = Vector2(size.x - 40, size.y - size.y * 0.18);

    add(road1);
    add(road2);

    grass1 = SpriteComponent()
      ..sprite = await loadSprite('grass.png')
      ..size = Vector2(size.x, size.y * 0.09)
      ..position = Vector2(0, size.y - size.y * 0.09);

    grass2 = SpriteComponent()
      ..sprite = await loadSprite('grass.png')
      ..size = Vector2(size.x, size.y * 0.09)
      ..position = Vector2(size.x - 1, size.y - size.y * 0.09);

    add(grass1);
    add(grass2);

    mapScrool = SpriteComponent()
      ..sprite = await loadSprite('map-scroll.png')
      ..size = Vector2(280, 280)
      ..position = Vector2(size.x - 560, size.y - size.y * 0.28 - 30);
    add(mapScrool);

    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position = Vector2(70, size.y - size.y * 0.18 - 100);
    add(kidOnCycle);

    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(10, size.y * 0.1);
    add(molly);

    dialogueBox = DialogueBoxComponent(
      position: Vector2(size.x * 0.35, size.y * 0.1),
      size: Vector2(size.x * 0.6, size.y * 0.15),
      text: "Let's go find the treasure! Tap on the screen to start moving.",
    );
    add(dialogueBox);

    await _flutterTts.speak(
        "Let's go find the treasure! Tap on the screen to start moving.");

    gateTimer = Timer(3.0, onTick: () async {
      if (gate == null) {
        gate = SpriteComponent()
          ..sprite = await loadSprite('sideways-gate.png')
          ..size = Vector2(100, 100)
          ..position = Vector2(size.x + 50, size.y - size.y * 0.28 + 100);
        add(gate!);
      }
    });

    gateTimer.start();
    
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.5);
    await _flutterTts.setSpeechRate(0.4);
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
      if (molly.parent != null) remove(molly);
      if (dialogueBox.parent != null) remove(dialogueBox);
      gateTimer.update(dt);
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);
      if (!isForestRemoved) {
        forest.position.x -= speed * dt;

        if (forest.position.x + forest.size.x < 0) {
          if (forest.parent != null) remove(forest);
          isForestRemoved = true;
        }
      }
    }
  }


  void moveComponent(SpriteComponent component1, SpriteComponent component2,
      double movementSpeed) {
    component1.position.x -= movementSpeed;
    component2.position.x -= movementSpeed;

    if (component1.position.x + component1.size.x <= 0) {
      component1.position.x = component2.position.x + component2.size.x - 30;
    }
    if (component2.position.x + component2.size.x <= 0) {
      component2.position.x = component1.position.x + component1.size.x - 30;
    }
  }

  void switchToAfterMapLevel(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameWidget(game: ForestLevel()),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _flutterTts.stop();

    isMoving = true;
  }
}

class DialogueBoxComponent extends PositionComponent {
  String text;

  DialogueBoxComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
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

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      fontFamily: 'Arial',
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
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
}
