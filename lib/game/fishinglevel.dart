import 'dart:math';
import 'dart:ui' as ui; // Import dart:ui for Image
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Fishinglevel extends FlameGame {
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  final List<SpriteComponent> fishList = [];

  // List of words for kids
  final List<String> words = [
    "cat",
    "dog",
    "fish",
    "tree",
    "bird",
    "star",
    "moon",
    "ball",
    "car",
    "book",
    "house",
    "toy",
    "sun",
    "rain",
    "snow"
  ];

  final Random random = Random();
  late List<String> selectedWords;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    background = SpriteComponent()..sprite = await loadSprite('sc.jpg');

    underwater = SpriteComponent()
      ..sprite = await loadSprite('underground-water.jpg');

    island = SpriteComponent()..sprite = await loadSprite('side-island.png');

    kidOnRock = SpriteComponent()..sprite = await loadSprite('boy-rod.png');

    add(background);
    add(underwater);
    add(island);
    add(kidOnRock);

    // Randomly select words
    selectedWords = [];
    while (selectedWords.length < 8) {
      String word = words[random.nextInt(words.length)];
      if (selectedWords.where((w) => w == word).length < 2) {
        selectedWords.add(word); // Add if it's not added twice
      }
    }

    // Select one word to add 4 times
    String repeatedWord = selectedWords[random.nextInt(3)];
    for (int i = 0; i < 4; i++) {
      selectedWords.add(repeatedWord);
    }

    // Create fish and add words
    for (int i = 0; i < 9; i++) {
      final fish = SpriteComponent()..sprite = await loadSprite('fish2.png');
      fishList.add(fish);
      add(fish);

      // Create a text component for the word
      final textComponent = InteractiveTextComponent(
        text: selectedWords[i],
        position: Vector2(fish.position.x + (fish.size.x / 2) - 20,
            fish.position.y - 40), // Centered above fish
        onTap: () =>
            print('Tapped on: ${selectedWords[i]}'), // Handle the tap event
      );

      add(textComponent); // Add the text component to the game
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    background
      ..size = Vector2(canvasSize.x, canvasSize.y * 0.5)
      ..position = Vector2(0, 0);

    underwater
      ..size = Vector2(canvasSize.x, canvasSize.y * 0.5)
      ..position = Vector2(0, canvasSize.y * 0.5);

    island
      ..size = Vector2(canvasSize.x * 0.7, canvasSize.y * 0.3)
      ..position = Vector2(0, canvasSize.y * 0.44 - island.size.y / 2);

    kidOnRock
      ..size = Vector2(canvasSize.x * 0.5, canvasSize.y * 0.18)
      ..position = Vector2(
          island.size.x * 0.47, island.position.y - kidOnRock.size.y * -0.5);

    List<Vector2> fishPositions = [
      Vector2(canvasSize.x * 0.17, underwater.position.y + canvasSize.y * 0.09),
      Vector2(canvasSize.x * 0.4, underwater.position.y + canvasSize.y * 0.15),
      Vector2(canvasSize.x * 0.7, underwater.position.y + canvasSize.y * 0.1),
      Vector2(canvasSize.x * 0.7, underwater.position.y + canvasSize.y * 0.5),
      Vector2(canvasSize.x * 0.15, underwater.position.y + canvasSize.y * 0.30),
      Vector2(canvasSize.x * 0.6, underwater.position.y + canvasSize.y * 0.25),
      Vector2(canvasSize.x * 0.4, underwater.position.y + canvasSize.y * 0.4),
      Vector2(canvasSize.x * 0.09, underwater.position.y + canvasSize.y * 0.20),
      Vector2(canvasSize.x * 0.7, underwater.position.y + canvasSize.y * 0.35),
    ];

    for (int i = 0; i < fishList.length; i++) {
      fishList[i]
        ..size = Vector2(canvasSize.x * 0.2, canvasSize.y * 0.1)
        ..position = fishPositions[i];
    }
  }
}

// Interactive Text Component
class InteractiveTextComponent extends PositionComponent {
  final String text;
  final TextPaint textRenderer;
  final void Function() onTap;

  InteractiveTextComponent({
    required this.text,
    required Vector2 position,
    required this.onTap,
  })  : textRenderer = TextPaint(
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        super() {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render the text directly
    textRenderer.render(canvas, text, position);
    print(
        'Rendered text: $text at position: $position'); // Debug: Log rendered text and position
  }

  @override
  bool onTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition;
    if (toRect().contains(tapPosition)) {
      onTap(); // Call the tap handler
      print('Tapped on text: $text'); // Debug: Log tapped text
      return true; // Indicate that the tap was handled
    }
    return false; // Tap not handled
  }

  Rect toRect() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textRenderer.style,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(); // Layout the text to calculate size
    // Create a rectangle based on text size
    return Rect.fromLTWH(
        position.x, position.y, textPainter.width, textPainter.height);
  }
}
