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
import 'package:flutter/gestures.dart';


class Fishinglevel extends FlameGame with TapCallbacks {
  final BuildContext context;

  Fishinglevel(this.context);
  late SpriteComponent underwater;
  late SpriteComponent background;
  late SpriteComponent island;
  late SpriteComponent kidOnRock;
  late SpriteComponent molly;
  late DialogueBoxComponent dialogueBox;
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

   final List<String> wordList = [
    "saw", "was", "god", "dog", "straw", "live", "evil", "what",
    "who", "why", "where", "there", "how", "one", "do", "has", "two",
    "said", "come", "some", "the", "of", "a", "to", "is", "you", "was",
    "are", "and", "it", "in", "at", "he", "she", "we", "by", "on", "up",
    "no", "yes", "not", "pan", "nap", "bat", "tab", "lap", "pal", "tip",
    "pit", "pot", "top","bear", "pear", "hire", "wire","crown", "frown",
    "again", "begin", "sure", "pure", "look", "took", "book", "hook", "cook", "walk", "talk",
    
  ];

  bool showProceedButton = false; // Flag to control button visibility

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

  // Add Molly's sprite
  molly
    ..size = Vector2(150, 150)
    ..position = Vector2(10, size.y * 0.1); // Position Molly to the left of the dialogue box
  add(molly);

   // Add the dialogue box
    dialogueBox = DialogueBoxComponent(
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
    _flutterTts.setPitch(1.5); // Child-like pitch
    _flutterTts.setSpeechRate(0.4); // Slow enough for kids
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

     // Update dialogue box text with the most occurring word highlighted
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
          }
          checkIfUserCompleted(context); // Ensure context is passed here
        },
      );
      fishRectangles.add(fishRectangle);
      add(fishRectangle);
    }
  }

  void checkIfUserCompleted(BuildContext context) async {
  if (correctSelections == occurrences || selectedWords.length == 9) {
    final blurOverlay = BlurOverlayComponent(size: size);
    add(blurOverlay);
    // Show the congratulatory dialogue box
    // Add the girl-with-fish sprite
        final girlWithFish = SpriteComponent()
          ..sprite = await loadSprite('girl-with-fish.png') // Replace with your girl-with-fish asset
          ..size = Vector2(150, 150)
          ..position = Vector2(size.x * 0.1, size.y * 0.4); // Centered position
        add(girlWithFish);

    final congratsDialogueBox = CongratsDialogueBoxComponent(
      position: Vector2(size.x * 0.45, size.y * 0.4),
      size: Vector2(size.x * 0.5, size.y * 0.2),
      text: "Congratulations! You helped your friend capture all the fish.",
    );
    add(congratsDialogueBox);

    // Play the narration
    await _flutterTts.speak(
        "Congratulations! You helped your friend capture all the fish. As a thank-you, your friend has a gift for you!");

    await Future.delayed(const Duration(seconds: 8));

    // Declare the giftBox variable here
    late GiftBoxComponent giftBox;

    // Add the gift box component
    giftBox = GiftBoxComponent(
      sprite: await loadSprite('gift-box.png'), // Replace with your gift box asset
      size: Vector2(200, 200),
      position: Vector2(size.x * 0.2, size.y * 0.5),
      onGiftOpened: () async {
        remove(giftBox); // Remove the gift box

        // Add the friendship badge
        final friendshipBadge = SpriteComponent()
          ..sprite = await loadSprite('friendship-badge.png') // Replace with your badge asset
          ..size = Vector2(150, 150)
          ..position = Vector2(size.x * 0.2, size.y * 0.5);
        add(friendshipBadge);

        // Wait for 3 seconds before removing the badge
        await Future.delayed(const Duration(seconds: 3));
        remove(friendshipBadge);

        // Update Molly to hold the fish
        molly.sprite = await loadSprite('girl-with-fish.png');
        // Update the dialogue box to include the hyperlink
        congratsDialogueBox.updateText(
          newText: "Congratulations! You helped your friend capture all the fish.",
          newHyperlinkText: "Next level",
          newHyperlinkCallback: () {
            GameNavigator.switchToInitialScene(context, this); // Navigate to the next screen
          },
        );
      },
    );
    add(giftBox);
    await _flutterTts.speak("Open the gift to see what's inside!");
  }
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

class GiftBoxComponent extends SpriteComponent with TapCallbacks {
  final Function onGiftOpened;

  GiftBoxComponent({
    required this.onGiftOpened,
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position);

  @override
  bool onTapUp(TapUpEvent event) {
    onGiftOpened(); // Call the function when the gift is tapped
    return true;
  }
}

class DialogueBoxComponent extends PositionComponent {
  String text;
  String? highlightWord; // Word to highlight

  DialogueBoxComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    this.highlightWord,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the rounded rectangle for the dialogue box
    final paint = Paint()..color = const Color(0xFFFAF3DD); // Cream background color
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(20), // Rounded corners
    );
    canvas.drawRRect(rrect, paint);

    // Prepare the text with the highlight
    final defaultTextStyle = TextStyle(
      color: Colors.black, // Default text color
      fontSize: 22, // Font size
      fontWeight: FontWeight.w500, // Medium weight
      fontFamily: 'Arial', // Dyslexia-friendly font
    );

    final highlightedTextStyle = TextStyle(
      color: Color(0xFF008080), // Dyslexia-friendly teal color
      fontSize: 22, // Font size
      fontWeight: FontWeight.w700, // Slightly bolder for emphasis
      fontFamily: 'Arial', // Dyslexia-friendly font
    );

    final spans = <TextSpan>[];
    text.split(' ').forEach((word) {
      spans.add(
        TextSpan(
          text: word + ' ', // Include a space after each word
          style: word == highlightWord ? highlightedTextStyle : defaultTextStyle,
        ),
      );
    });

    final textPainter = TextPainter(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.x * 0.9, // Fit within the box
    );

    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  // Method to update the text and highlight word in the dialogue box
  void updateText(String newText, {String? newHighlightWord}) {
    text = newText;
    highlightWord = newHighlightWord;
  }
}
class CongratsDialogueBoxComponent extends PositionComponent with TapCallbacks {
  String text;
  String? highlightWord; // Word to highlight
  String? hyperlinkText; // Text for the hyperlink
  VoidCallback? onHyperlinkTap; // Callback for hyperlink tap

  CongratsDialogueBoxComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    this.highlightWord,
    this.hyperlinkText,
    this.onHyperlinkTap,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the rounded rectangle for the dialogue box
    final paint = Paint()..color = const Color(0xFFFAF3DD); // Cream background color
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(20), // Rounded corners
    );
    canvas.drawRRect(rrect, paint);

    // Prepare the text with the highlight
    final defaultTextStyle = TextStyle(
      color: Colors.black, // Default text color
      fontSize: 22, // Font size
      fontWeight: FontWeight.w500, // Medium weight
      fontFamily: 'Arial', // Dyslexia-friendly font
    );

    final hyperlinkTextStyle = TextStyle(
      color: Colors.blue, // Hyperlink color
      fontSize: 15, // Font size
      fontWeight: FontWeight.w500, // Medium weight
      fontFamily: 'Arial',
      decoration: TextDecoration.underline, // Underline for hyperlink
    );

    final spans = <TextSpan>[
      TextSpan(text: text + '\n', style: defaultTextStyle), // Main text
      if (hyperlinkText != null)
        TextSpan(
          text: hyperlinkText,
          style: hyperlinkTextStyle,
          recognizer: TapGestureRecognizer()..onTap = onHyperlinkTap,
        ), // Hyperlink text
    ];

    final textPainter = TextPainter(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.x * 0.9, // Fit within the box
    );

    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (onHyperlinkTap != null) onHyperlinkTap!(); // Trigger hyperlink tap callback
    return true;
  }

  // Method to update the text, hyperlink, and highlight word
  void updateText({
    String? newText,
    String? newHighlightWord,
    String? newHyperlinkText,
    VoidCallback? newHyperlinkCallback,
  }) {
    if (newText != null) text = newText;
    highlightWord = newHighlightWord;
    hyperlinkText = newHyperlinkText;
    onHyperlinkTap = newHyperlinkCallback;
  }
}



