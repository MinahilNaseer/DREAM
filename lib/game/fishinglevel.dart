import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Fishinglevel extends FlameGame {
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  final List<SpriteComponent> fishList = [];
  late RectangleComponent rectangleBox; // Rectangle box for instructions
  final List<RectangleComponent> fishRectangles = [];
  //final String underwaterWord = "Swim";
  //late TextComponent underwaterText ;

  // To hold individual fish rectangles

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

    rectangleBox = RectangleComponent()
      ..size = Vector2(320, 150) // Set the size of the rectangle
      ..position = Vector2(40, 60); // Position the rectangle at the top

    add(rectangleBox);

    // Create text component for the message
    final line1 = TextComponent(
      text: "🐟 Tap the fish to help ",
      position: Vector2(100, 60),
    );
    add(line1);
    final line2 = TextComponent(
      text: "the boy catch them! 🎣",
      position: Vector2(100, 80),
    );
    add(line2);

    // Create fish and rectangles
    for (int i = 0; i < 9; i++) {
      final fish = SpriteComponent()..sprite = await loadSprite('fish2.png');
      fishList.add(fish);
      add(fish);
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

    // Position the fish and their respective rectangles
    for (int i = 0; i < fishList.length; i++) {
      fishList[i]
        ..size = Vector2(canvasSize.x * 0.2, canvasSize.y * 0.1)
        ..position = fishPositions[i];

      final fishRectangle = RectangleComponent()
        ..size = Vector2(55, 35) // Size for the rectangle
        ..position = (fishPositions[i].clone() // Clone the position
          ..x += fishList[i].size.x / 4 // Adjust the x position
          ..y += fishList[i].size.y / 4); // Adjust the y position

      fishRectangles.add(fishRectangle); // Add rectangle to list
      add(fishRectangle);

      final word = TextComponent(
        text: "toy",
        position: Vector2(103, 298),
      );
      add(word);
    }

    // Ensure the text is centered
  }
}

// Custom component to render a rectangle with rounded corners
class RectangleComponent extends PositionComponent {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = const Color.fromARGB(255, 235, 235, 210); // Rectangle color
    final radius = Radius.circular(10); // Corner radius
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y),
        radius); // Create rounded rectangle
    canvas.drawRRect(rrect, paint); // Draw the rectangle with rounded corners
  }
}

// Component to render text
class TextComponent extends PositionComponent {
  final String text;
  final TextPaint textRenderer;

  TextComponent({
    required this.text,
    required Vector2 position,
  })  : textRenderer = TextPaint(
          style: TextStyle(
              color: Color.fromARGB(255, 0, 102, 204),
              fontSize: 27), // Dark blue color for text
        ),
        super() {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textRenderer.style,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(); // Layout the text to calculate size

    // Position the text to be centered in the rectangle
    final x = position.x + (size.x - textPainter.width) / 2;
    final y = position.y + (size.y - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(x, y));
  }
}
