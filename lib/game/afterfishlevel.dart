import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/timer.dart';

class Afterfishlevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  SpriteComponent? forestScene; // Forest scene component

  bool isMoving = false;
  final double speed = 100; // Speed for road, grass, and background
  final double cycleSpeed = 70; // Speed for the kid on cycle
  bool isPondRemoved = false; // Flag to check if the pond is removed
  late Timer forestSceneTimer; // Timer to delay the forest scene addition

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
      ..position = Vector2(70, size.y - size.y * 0.18 - 100); // Positioned in the middle
    add(kidOnCycle);

    // Initialize the forest scene timer (5 seconds)
    forestSceneTimer = Timer(3.0, onTick: () async {
      // Add the forest scene (trees.png) if it doesn't exist yet
      if (forestScene == null) {
        forestScene = SpriteComponent()
          ..sprite = await loadSprite('trees-scene.png')
          ..size = Vector2(350, 350)
          ..position = Vector2(size.x + 50, size.y - size.y * 0.28 - 70); // Positioned off-screen on the right
        add(forestScene!);
      }
    });

    // Start the timer immediately
    forestSceneTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);

    

    if (isMoving) {
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
          remove(pond); // Remove the pond when it moves completely off-screen
          isPondRemoved = true;
        }
      }

      // Move the forest scene (trees.png) if it's added
      if (forestScene != null) {
        forestScene!.position.x -= speed * dt;

        // Stop the kid on cycle if the forest scene is close
        if ((forestScene!.position.x - kidOnCycle.position.x).abs() < 100) {
          isMoving = false; // Stop the movement
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();
        }

        // Remove the forest scene if it moves off-screen
        if (forestScene!.position.x + forestScene!.size.x < 0) {
          remove(forestScene!);
          forestScene = null;
        }
      }

      // Move the kid on cycle within the screen horizontally
      //kidOnCycle.position.x += cycleSpeed * dt;

      // Ensure the kid on cycle stays within screen bounds
      if (kidOnCycle.position.x > size.x - kidOnCycle.size.x) {
        kidOnCycle.position.x = size.x - kidOnCycle.size.x;
      }
    }
  }

  void moveComponent(SpriteComponent component1, SpriteComponent component2, double movementSpeed) {
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

  @override
  void onTapDown(TapDownEvent event) {
    // Start movement on tap
    isMoving = true;
  }
}
