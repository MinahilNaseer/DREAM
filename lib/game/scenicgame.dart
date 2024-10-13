import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ScenicGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    print("Loading parallax background...");

    // Load the parallax component using multiple layers
    final parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('sky-clouds.png'),  // Sky layer
        ParallaxImageData('ground-hill.png'), // Ground layer
        ParallaxImageData('road.png'),        // Road layer
      ],
      baseVelocity: Vector2(20, 0),           // Base velocity for scrolling
      velocityMultiplierDelta: Vector2(1.2, 1.0), // Different speeds for layers
    );

    add(parallaxComponent);
    print("Parallax loaded.");
  }
}
