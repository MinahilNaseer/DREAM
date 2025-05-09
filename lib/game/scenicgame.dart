import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:dream/global.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../game/fishinglevel.dart';

class ScenicGame extends FlameGame with TapCallbacks {
  final Map<String, dynamic> childData;
  ScenicGame({required this.childData});

  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  late SpriteComponent molly;

  bool isMoving = false;
  final double speed = 100;
  bool hasPondPassed = false;
  bool isSceneSwitched = false;
  late Timer pondTimer;
  bool pondAdded = false;

  late FlutterTts _flutterTts;
  String dialogueText = "";
  bool isDialogueVisible = true;
  Rect? dialogueBoxRect;

  late AudioPlayer _bicycleSoundPlayer;
  bool isBicycleSoundPlaying = false;

  @override
  Future<void> onLoad() async {
    _initializeTTS();
    _initializeBicycleSound();

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

    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position = Vector2(10, size.y - size.y * 0.18 - 100);
    add(kidOnCycle);

    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(-5, size.y - size.y * 0.35 - 480)
      ..priority = 10;
    add(molly);

    pondTimer = Timer(2, onTick: () {
      if (!pondAdded) {
        addPond();
      }
    });

    _speakDialogue(
        "Hi there! I'm Molly! Are you ready for an amazing adventure? Just tap anywhere, and let's start exploring!");
    dialogueText =
        "Hi there! I'm Molly! Just tap anywhere, and let's start exploring!";
  }

  Future<void> addPond() async {
    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(220, 220)
      ..position = Vector2(size.x + 100, size.y - size.y * 0.28 + 20);
    add(pond);
    pondAdded = true;
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
      playBicycleSound();
      pondTimer.update(dt);

      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      if (pondAdded && !hasPondPassed) {
        pond.position.x -= speed * dt;

        if (pond.position.x < size.x - 300 && molly.sprite != null) {
          molly.sprite = await loadSprite('animated-shocked-girl.png');
          add(molly);
          _speakDialogue(
              "Watch out! There’s a pond ahead! Do you think we’ll see some fish?");
          dialogueText =
              "Watch out! There’s a pond ahead! Do you think we’ll see some fish?";
          molly.priority = 10;
        }

        if ((pond.position.x - kidOnCycle.position.x).abs() < 130) {
          isMoving = false;
          stopBicycleSound();
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();

          showMollyWithDialogue(
              "Let's stop and see! Maybe there's something interesting!");
        }

        if (pond.position.x + pond.size.x <= 0) {
          hasPondPassed = true;
          remove(pond);
        }
      }
    }else{
      stopBicycleSound();
    }
  }

  void showMollyWithDialogue(String text) async {
    molly = SpriteComponent()
      ..sprite = await loadSprite('girl-idea.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(-10, size.y - size.y * 0.35 - 480)
      ..priority = 10;

    add(molly);

    dialogueText = text;
    isDialogueVisible = true;

    await _flutterTts.speak(text);

    await Future.delayed(Duration(seconds: text.length ~/ 10));

    switchToNewScene(buildContext!);
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

  void switchToNewScene(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameWidget(game: Fishinglevel(context,childData)),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isDialogueVisible) {
      isDialogueVisible = false;
      _speakDialogue("Great! Now let's go! Watch out for the pond ahead.");
      dialogueText = "Great! Now let's go! Watch out for the pond ahead.";

      remove(molly);

      isMoving = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isDialogueVisible) {
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontFamily: 'Arial',
      );

      final textSpan = TextSpan(
        text: dialogueText,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: size.x * 0.6,
      );

      final boxPadding = 15.0;
      final boxWidth = textPainter.width + boxPadding * 2;
      final boxHeight = textPainter.height + boxPadding * 2;
      final boxX = size.x * 0.3;
      final boxY = size.y * 0.1;

      final paint = Paint()..color = Color(0xFFFAF3DD);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxX, boxY, boxWidth, boxHeight),
        Radius.circular(20),
      );
      canvas.drawRRect(rrect, paint);

      textPainter.paint(
        canvas,
        Offset(boxX + boxPadding, boxY + boxPadding),
      );
    }
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.5);
    _flutterTts.setSpeechRate(0.4);
  }

   void _initializeBicycleSound() {
    _bicycleSoundPlayer = AudioPlayer();
    _bicycleSoundPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void playBicycleSound() async {
    if (!isBicycleSoundPlaying) {
    try {
      await _bicycleSoundPlayer.stop(); 
      await _bicycleSoundPlayer.setSourceAsset('audio/cycling-noise.mp3');
      await _bicycleSoundPlayer.setVolume(1.0);
      await _bicycleSoundPlayer.resume();
      isBicycleSoundPlaying = true;
    } catch (e) {
      print("🚨 Error playing bicycle sound: $e");
    }
  }
}

  void stopBicycleSound() async {
    if (isBicycleSoundPlaying) {
      await _bicycleSoundPlayer.stop();
      isBicycleSoundPlaying = false;
    }
  }

  Future<void> _speakDialogue(String text) async {
    await _flutterTts.speak(text);
  }
}
