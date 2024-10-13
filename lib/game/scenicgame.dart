import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';  // For handling tap input
import 'package:flutter/material.dart';

class ScenicGame extends FlameGame with TapCallbacks {  // Enable tap handling for the game
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;

  bool isMoving = false;  // Flag to check if the kid and background are moving
  final double speed = 100;  // Speed for the road, grass, and background

  @override
  Future<void> onLoad() async {
    print("Loading parallax background...");

    // Load the parallax component for sky and mountains
    parallaxComponent = await ParallaxComponent.load(
      [           // Sky layer
        ParallaxImageData('landscape.jpg'),            // Mountain layer
      ],
      baseVelocity: Vector2.zero(),            // No movement initially
      velocityMultiplierDelta: Vector2(1.2, 1.0), // Different speed for layers
    );
    add(parallaxComponent);

    // Load two road components to make them continuous
    road1 = SpriteComponent()
      ..sprite = await loadSprite('horizontal-road.png')   // Load road sprite
      ..size = Vector2(size.x, size.y * 0.18)              // Scale the road size to fit horizontally and shrink vertically
      ..position = Vector2(- 10, size.y - size.y * 0.18);     // Position at the bottom of the screen

    road2 = SpriteComponent()
      ..sprite = await loadSprite('horizontal-road.png')   // Duplicate road for continuity
      ..size = Vector2(size.x, size.y * 0.18)
      ..position = Vector2(size.x - 40, size.y - size.y * 0.18);  // Place the second road right after the first one

    add(road1);
    add(road2);

    // Load two grass components to make them continuous
    grass1 = SpriteComponent()
      ..sprite = await loadSprite('grass.png')             // Load grass sprite
      ..size = Vector2(size.x, size.y * 0.09)              // Grass height is 9% of screen height
      ..position = Vector2(0, size.y - size.y * 0.09);     // Place it below the road
    grass2 = SpriteComponent()
      ..sprite = await loadSprite('grass.png')             // Duplicate grass for continuity
      ..size = Vector2(size.x, size.y * 0.09)
      ..position = Vector2(size.x - 1, size.y - size.y * 0.09); // Place second grass next to the first one without gap

    add(grass1);
    add(grass2);

    // Load the kid on cycle sprite component on the road
    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')         // Load kid on cycle sprite
      ..size = Vector2(180, 180)                           // Adjust the size of the kid
      ..position = Vector2(10, size.y - size.y * 0.18 - 100); // Place it slightly above the road
    add(kidOnCycle);  // Add the kid on the road

    print("Parallax, road, grass, and kid on cycle added.");
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the kid and other elements if the flag is true
    if (isMoving) {
      // Move the parallax background
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);  // Adjust speed as needed

      // Move the road and grass components continuously
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      // Keep the kid stationary relative to the road by matching the speed of the road
      kidOnCycle.position.x = 10;  // Fix the kid at a constant position so it appears stationary on the road
    }
  }

  void moveComponent(SpriteComponent component1, SpriteComponent component2, double movementSpeed) {
    component1.position.x -= movementSpeed;
    component2.position.x -= movementSpeed;

    // Check if component1 has moved completely off-screen, then reset its position
    if (component1.position.x + component1.size.x <= 0) {
      component1.position.x = component2.position.x + component2.size.x - 30;  // Adjust to avoid gap
    }

    // Similarly, check if component2 has moved off-screen, then reset its position
    if (component2.position.x + component2.size.x <= 0) {
      component2.position.x = component1.position.x + component1.size.x - 30;  // Adjust to avoid gap
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    isMoving = true;  // Start movement when the screen is tapped
    print("Screen tapped, starting movement.");
  }
}
