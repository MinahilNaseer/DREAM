import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../game/fishinglevel.dart';  // Import the new scene

class ScenicGame extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;

  bool isMoving = false;
  final double speed = 100;
  bool hasPondPassed = false;
  bool isSceneSwitched = false;
  late Timer pondTimer;
  bool pondAdded = false;

  @override
  Future<void> onLoad() async {
    // Load the parallax component for sky and mountains
    parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('landscape.jpg'),
      ],
      baseVelocity: Vector2.zero(),  // No movement initially
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
  }

  Future<void> addPond() async {
    // Position the pond off-screen to the right
    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(220, 220)
      ..position = Vector2(size.x + 50, size.y - size.y * 0.28 - 100);
    add(pond);
    pondAdded = true;
    add(kidOnCycle);  // Add the kid again to ensure it's on top of the pond
    print("Pond added after 2 seconds, sliding onto the screen.");
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move components only if isMoving is true
    if (isMoving) {
      pondTimer.update(dt);  // Continue pond timer updates when moving

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
          isMoving = false;  // Stop all movements
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();  // Stop the parallax background

          switchToNewScene();  // Switch to the new scene
        }

        if (pond.position.x + pond.size.x <= 0) {
          hasPondPassed = true;
          remove(pond);  // Remove the pond from the game
          print("Pond has moved off the screen and is removed.");
        }
      }
    }
  }

  void moveComponent(SpriteComponent component1, SpriteComponent component2, double movementSpeed) {
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
    isMoving = true;  // Start movement when the screen is tapped
    print("Screen tapped, starting movement.");
  }

  // Function to switch to the new scene
  void switchToNewScene() {
    removeAll([road1, road2, grass1, grass2, kidOnCycle, pond, parallaxComponent]);  // Remove all components from ScenicGame
    
    final newScene = Fishinglevel();
    add(newScene);  // Add the new scene directly to the game
    print("Switched to the new scene.");
  }
}
