import 'package:dream/game/scenicgame.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import './class/rectanglecomponent.dart' as custom_rect;
import 'class/fishrectanglecomponent.dart';
import './class/textcomponent.dart' as custom_text;
import './class/gamenavigator.dart';
import 'dart:math';

class Fishinglevel extends FlameGame with TapCallbacks {
  final BuildContext context;

  Fishinglevel(this.context); 
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  final List<SpriteComponent> fishList = [];
  final Random random = Random();
  late custom_rect.RectangleComponent rectangleBox;
  final List<FishRectangleComponent> fishRectangles = [];

  final List<String> selectedWords = [];
  late String mostOccurringWord;
  int occurrences = 0;
  int correctSelections = 0;
  bool hasLoaded = false;

  final List<String> wordList = [
    "saw", "was", "god", "dog", "straw", "warts", "live", "evil", "what",
    "who", "why", "where", "there", "how", "one", "do", "has", "two",
    "said", "come", "some", "the", "of", "a", "to", "is", "you", "was",
    "are", "and", "it", "in", "at", "he", "she", "we", "by", "on", "up",
    "no", "yes", "not", "pan", "nap", "bat", "tab", "lap", "pal", "tip",
    "pit", "pot", "top"
  ];

  bool showProceedButton = false; // Flag to control button visibility

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    background = SpriteComponent()..sprite = await loadSprite('sc.jpg');
    underwater = SpriteComponent()..sprite = await loadSprite('underground-water.jpg');
    island = SpriteComponent()..sprite = await loadSprite('side-island.png');
    kidOnRock = SpriteComponent()..sprite = await loadSprite('boy-rod.png');

    add(background);
    add(underwater);
    add(island);
    add(kidOnRock);

    rectangleBox = custom_rect.RectangleComponent()
      ..size = Vector2(320, 150)
      ..position = Vector2(40, 60);

    add(rectangleBox);

    final line1 = custom_text.TextComponent(
      text: "🐟 Tap the fish to help ",
      position: Vector2(100, 60),
    );
    add(line1);
    final line2 = custom_text.TextComponent(
      text: "the boy catch them! 🎣",
      position: Vector2(100, 80),
    );
    add(line2);

    for (int i = 0; i < 9; i++) {
      final fish = SpriteComponent()..sprite = await loadSprite('fish2.png');
      fishList.add(fish);
      add(fish);
    }
    hasLoaded = true;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    if (!hasLoaded) return; // Only proceed if components have loaded

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

    final Set<String> selectedWordsSet = {};
    while (selectedWordsSet.length < 3) {
      selectedWordsSet.add(wordList[random.nextInt(wordList.length)]);
    }
    final List<String> selectedWordList = selectedWordsSet.toList();

    final List<String> finalWordList = [
      selectedWordList[0], selectedWordList[0], selectedWordList[0], selectedWordList[0],
      selectedWordList[1], selectedWordList[1],
      selectedWordList[2], selectedWordList[2],
      selectedWordList[0]
    ];

    finalWordList.shuffle();
    mostOccurringWord = selectedWordList[0];
    occurrences = 4;

    for (int i = 0; i < fishList.length; i++) {
      fishList[i]
        ..size = Vector2(canvasSize.x * 0.2, canvasSize.y * 0.1)
        ..position = fishPositions[i];

      final fishRectangle = FishRectangleComponent(
  word: finalWordList[i],
  position: fishPositions[i].clone(),
  size: Vector2(55, 35),
  onWordSelected: (selectedWord) {
    selectedWords.add(selectedWord);
    if (selectedWord == mostOccurringWord) {
      correctSelections++;
    }
    checkIfUserCompleted(context); // Ensure context is passed here
  },
);
      fishRectangles.add(fishRectangle);
      add(fishRectangle);
    }
  }

  void checkIfUserCompleted(BuildContext context) {
  if (correctSelections == occurrences || selectedWords.length == 9) {
    showProceedButton = true;
    add(BlurOverlayComponent(size: size));
    addProceedButton(context); // Pass the BuildContext here
  }
}


  void addProceedButton(BuildContext context) {
  final proceedButton = ProceedButtonComponent(
    context: context, // Pass context as a parameter
    position: Vector2(size.x * 0.16, size.y * 0.55),
    size: Vector2(280, 50),
    game: this,
  );
  add(proceedButton);
}


}

// Blur overlay component
class BlurOverlayComponent extends PositionComponent {
  BlurOverlayComponent({required Vector2 size}) : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint paint = Paint()..color = Colors.black.withOpacity(0.4); // Dim effect
    canvas.drawRect(size.toRect(), paint);
  }
}

class ProceedButtonComponent extends PositionComponent with TapCallbacks {
  final BuildContext context;
  final FlameGame game;
  final String buttonText = "Proceed to Your Journey";

  ProceedButtonComponent({
    required this.context, // Accept context parameter
    required Vector2 position,
    required Vector2 size,
    required this.game,
  }) : super(position: position, size: size);

  @override
  bool onTapUp(TapUpEvent info) {
    GameNavigator.switchToInitialScene(context, game); // Use context here
    print("Navigating to Afterfishlevel screen...");
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint paint = Paint()..color = Color(0xFF8FB8A8);
    RRect rrect = RRect.fromRectAndRadius(size.toRect(), Radius.circular(15));
    canvas.drawRRect(rrect, paint);

    // Centered text on the button
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: buttonText, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }
}


