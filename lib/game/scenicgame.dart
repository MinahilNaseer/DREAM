import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../game/fishinglevel.dart';

class ScenicGame extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  late SpriteComponent molly; // Character Molly

  bool isMoving = false;
  final double speed = 100;
  bool hasPondPassed = false;
  bool isSceneSwitched = false;
  late Timer pondTimer;
  bool pondAdded = false;

  late FlutterTts _flutterTts;
  String dialogueText = ""; // Text inside the dialogue box
  bool isDialogueVisible = true;
  Rect? dialogueBoxRect; // Dynamic dialogue box rectangle

  @override
  Future<void> onLoad() async {
    _initializeTTS();

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

    // Add Molly with a higher priority
    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(-5, size.y - size.y * 0.35 - 480)
      ..priority = 10; // Ensure Molly is in front
    add(molly);

    pondTimer = Timer(2, onTick: () {
      if (!pondAdded) {
        addPond();
      }
    });

    // Speak the first dialogue
    // Speak the first dialogue
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
    pondTimer.update(dt);

    // Move background elements
    moveComponent(road1, road2, speed * dt);
    moveComponent(road2, road1, speed * dt);
    moveComponent(grass1, grass2, speed * dt);
    moveComponent(grass2, grass1, speed * dt);

    parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

    // Move the pond
    if (pondAdded && !hasPondPassed) {
      pond.position.x -= speed * dt;

      // Change Molly's sprite and dialogue when the pond is near
      if (pond.position.x < size.x - 300 && molly.sprite != null) {
        molly.sprite = await loadSprite('animated-shocked-girl.png');
        add(molly); // Change to new image of Molly
        _speakDialogue("Watch out! There’s a pond ahead! Do you think we’ll see some fish?");
        dialogueText = "Watch out! There’s a pond ahead! Do you think we’ll see some fish?";
        molly.priority = 10; // Ensure Molly stays in front
      }

      // Check if the kid on the cycle meets the pond
      if ((pond.position.x - kidOnCycle.position.x).abs() < 130) {
        isMoving = false;
        parallaxComponent.parallax!.baseVelocity = Vector2.zero();

        // Stop and show Molly's "idea" expression with dialogue
        showMollyWithDialogue("Let's stop and see! Maybe there's something interesting!");
      }

      // Remove pond if it moves out of the screen
      if (pond.position.x + pond.size.x <= 0) {
        hasPondPassed = true;
        remove(pond);
      }
    }
  }
}

void showMollyWithDialogue(String text) async {
  // Update Molly's sprite to the "idea" PNG
  molly = SpriteComponent()
    ..sprite = await loadSprite('girl-idea.png') // Load provided PNG
    ..size = Vector2(150, 150)
    ..position = Vector2(-10, size.y - size.y * 0.35 - 480) // Adjust position
    ..priority = 10;

  add(molly); // Add Molly to the scene

  // Display the dialogue box
  dialogueText = text;
  isDialogueVisible = true;

  // Speak the text
  await _flutterTts.speak(text);

  // Wait for the TTS to finish
  await Future.delayed(Duration(seconds: text.length ~/ 10));

  // Switch to the new scene after the dialogue
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
        builder: (context) => GameWidget(game: Fishinglevel(context)),
      ),
    );
  }

  @override
void onTapDown(TapDownEvent event) {
  if (isDialogueVisible) {
    isDialogueVisible = false; // Hide the dialogue box
    _speakDialogue("Great! Now let's go! Watch out for the pond ahead.");
    dialogueText = "Great! Now let's go! Watch out for the pond ahead.";

    // Remove Molly sprite component
    remove(molly);

    // Start moving the scene
    isMoving = true;
  }
}


  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isDialogueVisible) {
      // Text Style - Dyslexic Friendly
      final textStyle = TextStyle(
        color: Colors.black, // High contrast against light background
        fontSize: 22, // Larger font size for readability
        fontWeight: FontWeight.w500, // Medium weight
        fontFamily: 'Arial', // Dyslexia-friendly font (e.g., Arial or Verdana)
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
        maxWidth: size.x * 0.6, // Width limited to 60% of the screen
      );

      final boxPadding = 15.0; // Increased padding for comfort
      final boxWidth = textPainter.width + boxPadding * 2;
      final boxHeight = textPainter.height + boxPadding * 2;
      final boxX = size.x * 0.3; // Center-aligned box
      final boxY = size.y * 0.1;

      // Draw the Dialogue Box - Soothing Background Color
      final paint = Paint()
        ..color = Color(0xFFFAF3DD); // Soft cream background color
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxX, boxY, boxWidth, boxHeight),
        Radius.circular(20), // Rounded corners for a friendly look
      );
      canvas.drawRRect(rrect, paint);

      // Draw the Text inside the Dialogue Box
      textPainter.paint(
        canvas,
        Offset(boxX + boxPadding, boxY + boxPadding),
      );
    }
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.5); // Child-like pitch
    _flutterTts.setSpeechRate(0.4); // Slow enough for kids
  }

  Future<void> _speakDialogue(String text) async {
    await _flutterTts.speak(text);
  }
}
