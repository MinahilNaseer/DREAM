import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/events.dart';
import 'package:flame/timer.dart'; // Import Flame Timer

class Afterfishlevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  late SpriteComponent forestScene; // Forest scene to slide in from the right

  bool isMoving = false; // Control for movement
  bool forestSceneVisible = false; // Flag to show forest scene
  bool hasPondPassed = false; // Flag to track if pond has passed the screen
  bool forestSceneMoving = false; // Flag to indicate forest scene is moving
  final double speed = 100; // Speed of movement
  final double cycleSpeed = 150; // Speed of kid on cycle
  final double forestSceneSpeed = 200; // Speed of forest scene sliding in
  final double stopOffset = 50; // Distance between kid and forest scene
  late Timer forestSceneTimer; // Flame Timer to trigger forest scene

  @override
  Color backgroundColor() => Colors.blueGrey;

  @override
  Future<void> onLoad() async {
    // Load the parallax background
    parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('landscape.jpg'),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
    add(parallaxComponent);

    // Set up road components with overlapping width
    double roadOverlapWidth = size.x + 50; // Slightly increase width for seamless transition
    road1 = SpriteComponent()
      ..sprite = await loadSprite('horizontal-road.png')
      ..size = Vector2(roadOverlapWidth, size.y * 0.18)
      ..position = Vector2(-20, size.y - size.y * 0.18);

    road2 = SpriteComponent()
      ..sprite = await loadSprite('horizontal-road.png')
      ..size = Vector2(roadOverlapWidth, size.y * 0.18)
      ..position = Vector2(road1.size.x - 40, size.y - size.y * 0.18); // Offset slightly for overlap

    add(road1);
    add(road2);

    // Load pond component
    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(250, 250)
      ..position = Vector2(size.x - 460, size.y - size.y * 0.28 - 10);
    add(pond);

    // Load and add grass components
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

    // Load and add kid on cycle component
    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position = Vector2(150, size.y - size.y * 0.18 - 100);
    add(kidOnCycle);

    // Load forest scene (positioned off-screen to the right)
    forestScene = SpriteComponent()
      ..sprite = await loadSprite('trees-scene.png')
      ..size = Vector2(300, 300)
      ..position = Vector2(size.x + 50, size.y - size.y * 0.28 - 50) // Start off-screen
      ..opacity = 1.0; // Fully visible
    add(forestScene);

    // Initialize forestSceneTimer to start the forest scene after 3 seconds
    forestSceneTimer = Timer(3.0, onTick: () {
      forestSceneVisible = true;  // Update the flag
      forestSceneMoving = true;   // Start moving the forest scene
    });
  }

      @override
  void update(double dt) {
    super.update(dt);

    // Update the forest scene timer
    forestSceneTimer.update(dt);

    if (isMoving && !forestSceneVisible) {
      // Move road and grass components
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      // Move pond only if it hasn't passed
      if (!hasPondPassed) {
        pond.position.x -= speed * dt;
        if (pond.position.x + pond.size.x <= 0) {
          remove(pond); // Remove pond once it leaves the screen
          hasPondPassed = true; // Mark pond as passed
        }
      }

      // Update parallax background
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);
    }

    if (forestSceneVisible) {
      if (forestSceneMoving) {
        // Move forest scene from right to its target position
        double targetX = size.x - forestScene.size.x;
        forestScene.position.x -= forestSceneSpeed * dt;
        
        // Stop the forest scene at the target position
        if (forestScene.position.x <= targetX) {
          forestScene.position.x = targetX;
          forestSceneMoving = false; // Stop moving the forest scene
        }
      }

      // Stop all components except for the kid on cycle
      parallaxComponent.parallax!.baseVelocity = Vector2.zero();
      isMoving = false;

      // Move the kid on cycle towards the start of the forest scene
      double stopPosition = forestScene.position.x - kidOnCycle.size.x - stopOffset;
      if (kidOnCycle.position.x < stopPosition) {
        kidOnCycle.position.x += cycleSpeed * dt;
        if (kidOnCycle.position.x > stopPosition) {
          kidOnCycle.position.x = stopPosition;
        }
      }
    }
  }



  void moveComponent(SpriteComponent component1, SpriteComponent component2, double movementSpeed) {
    component1.position.x -= movementSpeed;
    component2.position.x -= movementSpeed;

    // Ensure seamless transition without gaps
    if (component1.position.x + component1.size.x <= 0) {
      component1.position.x = component2.position.x + component2.size.x - 5;
    }

    if (component2.position.x + component2.size.x <= 0) {
      component2.position.x = component1.position.x + component1.size.x - 5;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!forestSceneVisible && !isMoving) {
      isMoving = true; // Start moving when the screen is tapped
      
      // Start the forestSceneTimer
      forestSceneTimer.start();
    }
  }
}
