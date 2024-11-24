import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/timer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'forestlevel.dart'; // Import ForestLevel class

class Afterfishlevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  SpriteComponent? forestScene;

  late SpriteComponent molly; // Molly sprite
  late DialogueBoxComponent dialogueBox;
  late TextComponent forestTitle;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late FlutterTts _flutterTts; // Forest scene component

  bool isMoving = false;
  final double speed = 100; // Speed for road, grass, and background
  final double cycleSpeed = 70; // Speed for the kid on cycle
  bool isPondRemoved = false; // Flag to check if the pond is removed
  late Timer forestSceneTimer; // Timer to delay the forest scene addition
  bool isAudioPlayed = false;

  @override
  Future<void> onLoad() async {
    // Load the parallax background
    await _initializeTTS();

    parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('landscape.jpg'),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
    add(parallaxComponent);

    // Load the roads
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

    // Load the grass
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

    // Load the pond
    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(220, 220)
      ..position = Vector2(size.x - 500, size.y - size.y * 0.28 + 20);
    add(pond);

    // Load the kid on cycle
    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position =
          Vector2(70, size.y - size.y * 0.18 - 100); // Positioned in the middle
    add(kidOnCycle);
    // Add Molly sprite
    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(10, size.y * 0.1); // Position Molly to the left
    add(molly);

    // Add the dialogue box
    dialogueBox = DialogueBoxComponent(
      position: Vector2(size.x * 0.35, size.y * 0.1),
      size: Vector2(size.x * 0.6, size.y * 0.15),
      text: "Let's continue the journey! Tap on the screen to start moving.",
    );
    add(dialogueBox);

    await _flutterTts.speak(
        "Let's continue the journey! Tap on the screen to start moving.");

    // Initialize the forest scene timer (3 seconds)
    forestSceneTimer = Timer(3.0, onTick: () async {
      // Add the forest scene (trees.png) if it doesn't exist yet
      if (forestScene == null) {
        forestScene = SpriteComponent()
          ..sprite = await loadSprite('trees-scene.png')
          ..size = Vector2(350, 350)
          ..position = Vector2(
              size.x + 50,
              size.y -
                  size.y * 0.28 -
                  70); // Positioned off-screen on the right
        add(forestScene!);
        forestTitle = TextComponent(
          text: "Whispering\nForest",
          position: Vector2(
              forestScene!.position.x + forestScene!.size.x / 3 + 50,
              forestScene!.position.y - 100),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: ui.Color.fromARGB(255, 163, 170, 62),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        add(forestTitle);
        // Play the forest ambiance audio
        if (!isAudioPlayed) {
          //await _audioPlayer.setVolume(10);
          await _audioPlayer
              .play(AssetSource('audio/forest-wind-and-birds.mp3'));
          isAudioPlayed = true;
        }
      }
    });

    // Start the timer immediately
    forestSceneTimer.start();
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.5); // Child-like pitch
    await _flutterTts.setSpeechRate(0.4); // Slow enough for kids
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
      // Remove initial Molly and dialogue box when movement starts
      if (molly.parent != null) remove(molly);
      if (dialogueBox.parent != null) remove(dialogueBox);

      // Update the forest scene timer
      forestSceneTimer.update(dt);

      // Move the roads and grass
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      // Set the background movement speed
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      // Move the pond to the left and remove it if it moves off-screen
      if (!isPondRemoved) {
        pond.position.x -= speed * dt;

        if (pond.position.x + pond.size.x < 0) {
          if (pond.parent != null) remove(pond); // Remove the pond
          isPondRemoved = true;

          molly.sprite = await loadSprite('animated-shocked-girl.png');
          molly.position = Vector2(10, size.y * 0.1); // Reset position
          add(molly);

          // Add updated dialogue box with the warning message
          dialogueBox = DialogueBoxComponent(
            position: Vector2(size.x * 0.35, size.y * 0.1),
            size: Vector2(size.x * 0.6, size.y * 0.15),
            text: "Watch out! There’s a mysterious forest ahead.",
          );
          add(dialogueBox);

          // Speak the dialogue using TTS
          await _flutterTts.speak(
              "Watch out! There’s a mysterious forest ahead. Do you hear the whispers?");
        }
      }

      // Move the forest scene (trees.png) if it's added
      if (forestScene != null) {
        forestScene!.position.x -= speed * dt;

        // Move the title to follow the forest scene
        if (forestTitle != null) {
          forestTitle.position.x =
              forestScene!.position.x + forestScene!.size.x / 2 - 140;
        }

        // Stop the kid on cycle if the forest scene is close
        if ((forestScene!.position.x - kidOnCycle.position.x).abs() < 100) {
          isMoving = false; // Stop the movement
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();

          // Update Molly and dialogue box for the final scene
          molly.sprite = await loadSprite('girl-idea.png');
          molly.position = Vector2(10, size.y * 0.1); // Reset position
          add(molly);

          dialogueBox = DialogueBoxComponent(
            position: Vector2(size.x * 0.35, size.y * 0.1),
            size: Vector2(size.x * 0.6, size.y * 0.15),
            text: "We’ve made it to the Whispering Forest!",
          );
          add(dialogueBox);

          // Speak the final dialogue
          await _flutterTts.speak(
              "We’ve made it to the Whispering Forest! Let's see what's stopping us from crossing the forest");

          Future.delayed(const Duration(seconds: 6), () {
            isAudioPlayed = false;
          switchToNewScene(buildContext!); // Transition to the forest level
        });
        }
      }
    }
  }

  void moveComponent(SpriteComponent component1, SpriteComponent component2,
      double movementSpeed) {
    component1.position.x -= movementSpeed;
    component2.position.x -= movementSpeed;

    // Seamless transition for roads and grass
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
        builder: (context) =>
            GameWidget(game: ForestLevel()), // Switch to ForestLevel
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Stop the audio of "Let's continue the journey"
    _flutterTts.stop();

    // Start movement on tap
    isMoving = true;
  }
}

// Custom Dialogue Box Component
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

    // Draw the rounded rectangle for the dialogue box
    final paint = Paint()
      ..color = const Color(0xFFFAF3DD); // Cream background color
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(20), // Rounded corners
    );
    canvas.drawRRect(rrect, paint);

    // Prepare the text
    final textStyle = TextStyle(
      color: Colors.black, // Text color
      fontSize: 20, // Font size
      fontWeight: FontWeight.w500, // Medium weight
      fontFamily: 'Arial', // Dyslexia-friendly font
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.x * 0.9, // Fit within the box
    );

    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }
}
