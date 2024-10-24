import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import './class/rectanglecomponent.dart' as custom_rect;
import 'class/fishrectanglecomponent.dart';
import './class/textcomponent.dart' as custom_text;
import 'dart:math';

class Fishinglevel extends FlameGame {
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  final List<SpriteComponent> fishList = [];
  final Random random = Random(); 
  late custom_rect.RectangleComponent rectangleBox; 
  final List<FishRectangleComponent> fishRectangles = []; 

  final List<String> selectedWords = []; // Track selected words
  late String mostOccurringWord; // Store the most occurring word
  int occurrences = 0; // Track occurrences of most occurring word
  int correctSelections = 0; // Track correct selections of the most occurring word

  final List<String> wordList = [
    "Cat", "Dog", "Sun", "Moon", "Ball", "Tree", "Car", "Boat", "Star", "Bird",
    "Fish", "Cup", "House", "Milk", "Bike", "Book", "Sky", "Toy", "Cloud", "Hat"
  ];

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

    // Randomly select 3 words
    final Set<String> selectedWordsSet = {};
    while (selectedWordsSet.length < 3) {
      selectedWordsSet.add(wordList[random.nextInt(wordList.length)]);
    }
    final List<String> selectedWordList = selectedWordsSet.toList();

    // Fixed appearance pattern: one word 4 times, one word 3 times, and one word 2 times
    final List<String> finalWordList = [
      selectedWordList[0], selectedWordList[0], selectedWordList[0], selectedWordList[0], // 4 occurrences
      selectedWordList[1], selectedWordList[1], selectedWordList[1], // 3 occurrences
      selectedWordList[2], selectedWordList[2]  // 2 occurrences
    ];

    // Shuffle the final list to randomize the position
    finalWordList.shuffle();
    mostOccurringWord = selectedWordList[0]; // The word appearing 4 times
    occurrences = 4; // 4 occurrences of the most occurring word

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
          checkIfUserCompleted(); // Check if user selected all occurrences
        },
      );
      fishRectangles.add(fishRectangle);
      add(fishRectangle);
    }
  }

  // Check if the user selected all occurrences of the most occurring word
  void checkIfUserCompleted() {
    if (correctSelections == occurrences) {
      print("Correct! You've selected all occurrences of the word: $mostOccurringWord");
    } else if (selectedWords.length == 9) {
      print("Not correct! You missed some occurrences of the most frequent word.");
    }
  }
}
