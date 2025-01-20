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
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dream/game/class/bluroverlay.dart' as blur;
import 'package:dream/game/class/giftboxcomp.dart' as giftboxcomp;
import 'package:dream/game/class/dialogueboxwithhighlight.dart'
    as dialoguehighlight;
import 'package:dream/game/class/congratscomp.dart' as congratsdiacomp;

class Fishinglevel extends FlameGame with TapCallbacks {
  final BuildContext context;

  Fishinglevel(this.context);
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  late SpriteComponent molly;
  late dialoguehighlight.DialogueBoxComponent dialogueBox;
  late SpriteComponent giftBox;
  late SpriteComponent friendshipBadge;

  bool showGift = false;
  bool giftOpened = false;

  late FlutterTts _flutterTts;

  final List<SpriteComponent> fishList = [];
  final Random random = Random();
  late custom_rect.RectangleComponent rectangleBox;
  final List<FishRectangleComponent> fishRectangles = [];
  final List<String> selectedWords = [];
  late String mostOccurringWord;
  int occurrences = 0;
  int correctSelections = 0;
  bool hasLoaded = false;
  final List<String> incorrectSelections = [];
  final List<String> correctSelectionsList = [];

  final List<String> wordList = [
    "saw",
    "was",
    "god",
    "dog",
    "straw",
    "live",
    "evil",
    "what",
    "who",
    "why",
    "where",
    "there",
    "how",
    "one",
    "do",
    "has",
    "two",
    "said",
    "come",
    "some",
    "the",
    "of",
    "a",
    "to",
    "is",
    "you",
    "was",
    "are",
    "and",
    "it",
    "in",
    "at",
    "he",
    "she",
    "we",
    "by",
    "on",
    "up",
    "no",
    "yes",
    "not",
    "pan",
    "nap",
    "bat",
    "tab",
    "lap",
    "pal",
    "tip",
    "pit",
    "pot",
    "top",
    "bear",
    "pear",
    "hire",
    "wire",
    "crown",
    "frown",
    "again",
    "begin",
    "sure",
    "pure",
    "look",
    "took",
    "book",
    "hook",
    "cook",
    "walk",
    "talk",
  ];

  bool showProceedButton = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _initializeTTS();

    background = SpriteComponent()..sprite = await loadSprite('sc.jpg');
    underwater = SpriteComponent()
      ..sprite = await loadSprite('underground-water.jpg');
    island = SpriteComponent()..sprite = await loadSprite('side-island.png');
    kidOnRock = SpriteComponent()..sprite = await loadSprite('boy-rod.png');
    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png');

    add(background);
    add(underwater);
    add(island);
    add(kidOnRock);

    molly
      ..size = Vector2(150, 150)
      ..position = Vector2(10, size.y * 0.1);
    add(molly);

    dialogueBox = dialoguehighlight.DialogueBoxComponent(
      position: Vector2(size.x * 0.35, size.y * 0.1),
      size: Vector2(size.x * 0.6, size.y * 0.15),
      text: "🐟 Tap the fish with the matching word!",
    );
    add(dialogueBox);

    _narrateStory();

    for (int i = 0; i < 9; i++) {
      final fish = SpriteComponent()..sprite = await loadSprite('fish2.png');
      fishList.add(fish);
      add(fish);
    }
    hasLoaded = true;
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.5);
    _flutterTts.setSpeechRate(0.4);
  }

  Future<void> _narrateStory() async {
    final narration = "A friend needs help with fishing. "
        "You can help by tapping on the fish that has the matching word. "
        "Let's get started!";
    await _flutterTts.speak(narration);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    if (!hasLoaded) return;

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
      selectedWordList[0],
      selectedWordList[0],
      selectedWordList[0],
      selectedWordList[0],
      selectedWordList[1],
      selectedWordList[1],
      selectedWordList[2],
      selectedWordList[2],
      selectedWordList[0]
    ];

    finalWordList.shuffle();
    mostOccurringWord = selectedWordList[0];
    occurrences = 4;

    dialogueBox.updateText(
      "🐟 Tap the fish with the matching word: $mostOccurringWord",
      newHighlightWord: mostOccurringWord,
    );

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
            correctSelectionsList.add(selectedWord);
          } else {
            // Track incorrect selections
            incorrectSelections.add(selectedWord);
          }
          checkIfUserCompleted(context);
        },
      );
      fishRectangles.add(fishRectangle);
      add(fishRectangle);
    }
  }

  void checkIfUserCompleted(BuildContext context) async {
    if (correctSelectionsList.length == occurrences ||
        incorrectSelections.length >= 4 ||
        selectedWords.length == 9) {
      final blurOverlay = blur.BlurOverlayComponent(size: size);
      add(blurOverlay);

      final girlWithFish = SpriteComponent()
        ..sprite = await loadSprite('girl-with-fish.png')
        ..size = Vector2(150, 150)
        ..position = Vector2(size.x * 0.1, size.y * 0.4);
      add(girlWithFish);

      final congratsDialogueBox = congratsdiacomp.CongratsDialogueBoxComponent(
        position: Vector2(size.x * 0.45, size.y * 0.4),
        size: Vector2(size.x * 0.5, size.y * 0.2),
        text: "Congratulations! You helped your friend capture all the fish.",
      );
      add(congratsDialogueBox);

      await _flutterTts.speak("Congratulations! You helped your friend capture all the fish.");

      await Future.delayed(const Duration(seconds: 6));

      molly.sprite = await loadSprite('girl-with-fish.png');
      congratsDialogueBox.updateText(
        newHyperlinkText: "Next level",
        
        newHyperlinkCallback: () {
          GameNavigator.switchToInitialScene(context, this);
        },
        
      );
      await _flutterTts.speak("Move on to the next level.");
    }
  }
}
