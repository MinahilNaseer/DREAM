import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Fishinglevel extends FlameGame {
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  final List<SpriteComponent> fishList = []; // Store multiple fish components

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the static background, underwater, island, and kid on rock images
    background = SpriteComponent()
      ..sprite = await loadSprite('sc.jpg');

    underwater = SpriteComponent()
      ..sprite = await loadSprite('underground-water.jpg');

    island = SpriteComponent()
      ..sprite = await loadSprite('side-island.png'); // Load island image

    kidOnRock = SpriteComponent()
      ..sprite = await loadSprite('boy-rod.png'); // Load kid on rock image

    // Add components without specifying size and position yet
    add(background);
    add(underwater);
    add(island);
    add(kidOnRock);

    // Create and add multiple fish
    for (int i = 0; i < 9; i++) {
      final fish = SpriteComponent()
        ..sprite = await loadSprite('fish2.png'); // Load fish image
      fishList.add(fish); // Add each fish to the list
      add(fish); // Add fish to the game
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    // Set the size and position of the background
    background
      ..size = Vector2(canvasSize.x, canvasSize.y * 0.5)  // Half the screen height for background
      ..position = Vector2(0, 0);  // Positioned at the top

    // Set the size and position of the underwater image
    underwater
      ..size = Vector2(canvasSize.x, canvasSize.y * 0.5)  // Half the screen height for underwater
      ..position = Vector2(0, canvasSize.y * 0.5);  // Positioned at the bottom half

    // Set the size and position of the island at the boundary between the background and underwater
    island
      ..size = Vector2(canvasSize.x * 0.7, canvasSize.y * 0.3) // Adjust the size of the island
      ..position = Vector2(0, canvasSize.y * 0.44 - island.size.y / 2); // Place it at the left and center

    // Set the size and position of the kid on the rock image to sit on top of the island
    kidOnRock
      ..size = Vector2(canvasSize.x * 0.5, canvasSize.y * 0.18) // Adjust the size of the kid on the rock
      ..position = Vector2(island.size.x * 0.47, island.position.y - kidOnRock.size.y * -0.5); // Place it on top of the island

    // Set specific positions for the fish components within the underwater area
    List<Vector2> fishPositions = [
      Vector2(canvasSize.x * 0.1, underwater.position.y + canvasSize.y * 0.1),
      Vector2(canvasSize.x * 0.3, underwater.position.y + canvasSize.y * 0.15),
      Vector2(canvasSize.x * 0.5, underwater.position.y + canvasSize.y * 0.1),
      Vector2(canvasSize.x * 0.7, underwater.position.y + canvasSize.y * 0.5),
      Vector2(canvasSize.x * 0.2, underwater.position.y + canvasSize.y * 0.35),
      Vector2(canvasSize.x * 0.6, underwater.position.y + canvasSize.y * 0.25),
      Vector2(canvasSize.x * 0.4, underwater.position.y + canvasSize.y * 0.4),
      Vector2(canvasSize.x * 0.1, underwater.position.y + canvasSize.y * 0.25),
      Vector2(canvasSize.x * 0.7, underwater.position.y + canvasSize.y * 0.4),
    ];

    // Apply the positions to the fish
    for (int i = 0; i < fishList.length; i++) {
      fishList[i]
        ..size = Vector2(canvasSize.x * 0.2, canvasSize.y * 0.1) // Adjust the size of the fish
        ..position = fishPositions[i]; // Set the specific position for each fish
    }
  }
}
