import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Fishinglevel extends FlameGame {
  @override
  Future<void> onLoad() async {
    print("Loading parallax background...");

    // Load the parallax component using multiple layers
    final parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('sc.jpg'),  // Sky layer
        ParallaxImageData('side-island.png'), // Ground layer
        ParallaxImageData('underground-water.jpg'),        // Road layer
      ],
      baseVelocity: Vector2(20, 0),           // Base velocity for scrolling
      velocityMultiplierDelta: Vector2(1.2, 1.0), // Different speeds for layers
    );

    add(parallaxComponent);
    print("Parallax loaded.");
  }
}