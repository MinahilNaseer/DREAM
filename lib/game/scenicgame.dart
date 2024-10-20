import 'dart:ui' as ui; // Import dart:ui for Image
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/input.dart';
//import 'package:flame/images.dart'; // Import Flame image handling
import '../game/fishinglevel.dart'; // Import the new scene

class ScenicGame extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  late ui.Image handIconImage; // Use the correct Image type from dart:ui

  bool isMoving = false;
  bool showPrompt = true; // Show the prompt initially
  final double speed = 100;
  bool hasPondPassed = false;
  bool isSceneSwitched = false;
  late Timer pondTimer;
  bool pondAdded = false;

  // Hand icon movement variables
  double handIconOffset = 0; // Current offset
  double handIconDirection = 1; // 1 for right, -1 for left
  final double handIconMaxOffset = 5; // Maximum offset for oscillation
  final double handIconSpeed = 0.05; // Speed of the oscillation

  @override
  Future<void> onLoad() async {
    // Load the parallax component for sky and mountains
    parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('landscape.jpg'),
      ],
      baseVelocity: Vector2.zero(), // No movement initially
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
    add(parallaxComponent);

    // Load road components
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

    // Load grass components
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

    // Initialize the pond timer to trigger after 2 seconds
    pondTimer = Timer(2, onTick: () {
      if (!pondAdded) {
        addPond();
      }
    });

    // Load the kid on cycle sprite component on the road
    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position = Vector2(10, size.y - size.y * 0.18 - 100);
    add(kidOnCycle);

    print("Parallax, road, grass, and kid on cycle added.");

    // Load the hand icon
    handIconImage = await images.load('hand-icon.png'); // Load the hand image
  }

  Future<void> addPond() async {
    // Position the pond off-screen to the right
    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(220, 220)
      ..position = Vector2(size.x + 50, size.y - size.y * 0.28 - 100);
    add(pond);
    pondAdded = true;
    add(kidOnCycle); // Add the kid again to ensure it's on top of the pond
    print("Pond added after 2 seconds, sliding onto the screen.");
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move components only if isMoving is true
    if (isMoving) {
      pondTimer.update(dt); // Continue pond timer updates when moving

      // Move the road and grass continuously
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      // Move the parallax background
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      if (pondAdded && !hasPondPassed) {
        pond.position.x -= speed * dt;

        // Stop everything and switch to the new scene when the pond and kid are parallel
        if ((pond.position.x - kidOnCycle.position.x).abs() < 10) {
          print("Kid and pond are parallel. Stopping everything.");
          isMoving = false; // Stop all movements
          parallaxComponent.parallax!.baseVelocity =
              Vector2.zero(); // Stop the parallax background

          switchToNewScene(); // Switch to the new scene
        }

        if (pond.position.x + pond.size.x <= 0) {
          hasPondPassed = true;
          remove(pond); // Remove the pond from the game
          print("Pond has moved off the screen and is removed.");
        }
      }
    }

    // Update hand icon position for oscillation
    handIconOffset += handIconDirection * handIconSpeed;
    if (handIconOffset >= handIconMaxOffset || handIconOffset <= -handIconMaxOffset) {
      handIconDirection *= -1; // Reverse direction when max offset is reached
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

  @override
  void onTapDown(TapDownEvent event) {
    if (showPrompt) {
      showPrompt = false; // Hide the prompt after first tap
    } else {
      isMoving = true; // Start movement when the screen is tapped
      print("Screen tapped, starting movement.");
    }
  }

  // Function to switch to the new scene
  void switchToNewScene() {
    removeAll([
      road1,
      road2,
      grass1,
      grass2,
      kidOnCycle,
      pond,
      parallaxComponent
    ]); // Remove all components from ScenicGame

    final newScene = Fishinglevel();
    add(newScene); // Add the new scene directly to the game
    print("Switched to the new scene.");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (showPrompt) {
      // Render the prompt with rounded corners
      final paint = Paint()
        ..color = const Color.fromARGB(255, 175, 116, 6).withOpacity(0.7);
      final rect =
          Rect.fromLTWH(size.x * 0.1, size.y * 0.2, size.x * 0.8, size.y * 0.2);
      final rrect = RRect.fromRectAndRadius(
          rect, Radius.circular(20)); // Create a rounded rectangle
      canvas.drawRRect(rrect, paint); // Draw the rounded rectangle

      // Render the text
      final textStyle = TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);
      final textSpan = TextSpan(
        text: "Tap anywhere to start your adventure!",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.x * 0.7);
      textPainter.paint(canvas, Offset(size.x * 0.15, size.y * 0.3));

      // Render the hand icon above the prompt
      final handIconSize = 70; // Adjust size as needed
      final handIconPosition = Offset(size.x * 0.5 - handIconSize / 2 + handIconOffset, size.y * 0.21); // Center the icon
     
      // Draw the hand icon image with adjusted size
      final paintImage = Paint();
      canvas.drawImageRect(
        handIconImage,
        Rect.fromLTWH(0, 0, handIconImage.width.toDouble(), handIconImage.height.toDouble()), // Source rect
        Rect.fromLTWH(handIconPosition.dx, handIconPosition.dy, handIconSize.toDouble(), handIconSize.toDouble()), // Destination rect
        paintImage,
      );

      // Render the close button (X) with circular background
      final closeButtonSize = 40.0; // Diameter of the circular button
      final closeButtonRect = Rect.fromLTWH(
          size.x * 0.85, size.y * 0.2, closeButtonSize, closeButtonSize);
      final closeButtonPaint = Paint()
        ..color = Colors.white; // Background color
      canvas.drawCircle(
        Offset(closeButtonRect.center.dx, closeButtonRect.center.dy),
        closeButtonSize / 2, // Radius of the circle
        closeButtonPaint,
      );

      // Draw the "X" text
      final closeTextStyle = TextStyle(
          color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold);
      final closeTextSpan = TextSpan(text: "X", style: closeTextStyle);
      final closeTextPainter = TextPainter(
        text: closeTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      closeTextPainter.layout(minWidth: 0, maxWidth: closeButtonSize);

      // Center the "X" in the circular button
      closeTextPainter.paint(
        canvas,
        Offset(
          closeButtonRect.center.dx - closeTextPainter.width / 2,
          closeButtonRect.center.dy - closeTextPainter.height / 2,
        ),
      );
    }
  }
}
