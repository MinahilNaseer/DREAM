import 'dart:ui' as ui;
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/timer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dream/game/class/dialogueboxcomponent.dart' as speechbox;
import 'forestlevel.dart';
import 'dart:math';
import 'package:dream/game/class/dialogueboxcomponent.dart' as diabox;
import 'package:dream/game/class/filledrecwithword.dart' as recwithword;
import 'package:dream/game/class/filledroundreccomp.dart' as recstart;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dream/game/class/togglebutton.dart';

class Aftermaplevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;

  late SpriteComponent mapScrool;
  late SpriteComponent molly;
  late speechbox.DialogueBoxComponent dialogueBox;
  SpriteComponent? gate;

  late FlutterTts _flutterTts;

  bool isMoving = false;
  final double speed = 100;

  bool gateAppeared = false;
  late Timer gateTimer;

  bool showOverlay = false;
  late RectangleComponent overlay;
  late diabox.DialogueBoxComponent instructionBox;
  late recwithword.FilledRoundedRectangleWithWordComponent wordBox;

  late TextComponent recognizedTextDisplay;

  late stt.SpeechToText speechToText;
  late PositionComponent? toggleButton;
  bool isRecording = false;
  String displayedWord = "APPLE";
  String recognizedText = "";
  late PositionComponent overlayContainer;
  bool gateOpened = false;
  late SpriteComponent treasureChest;
  bool isTreasureMoving = false;
  late speechbox.DialogueBoxComponent foundTreasureBox;
  List<String> dyslexiaWords = [
    "cat",
    "bat",
    "dog",
    "pin",
    "pen",
    "ship",
    "sheep",
    "was",
    "on",
    "no",
    "big",
    "dig",
    "tap",
    "ship",
    "shop",
    "chip",
    "chat",
    "hit",
    "fish",
    "wish",
    "dish",
    "sun",
    "run",
    "fun",
  ];
  SpriteComponent? leftGate;
  SpriteComponent? rightGate;
  bool gatesMoving = false;
  late AudioPlayer _bicycleSoundPlayer;
  bool isBicycleSoundPlaying = false;
  int correctProunicationCount = 0;

  @override
  Future<void> onLoad() async {
    await _initializeTTS();
    _initializeSpeechToText();
    _bicycleSoundPlayer = AudioPlayer();

    parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('landscape.jpg'),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
    add(parallaxComponent);

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

    mapScrool = SpriteComponent()
      ..sprite = await loadSprite('map-scroll.png')
      ..size = Vector2(90, 90)
      ..position = Vector2(size.x - 100, size.y - size.y * 0.28 - 580);
    add(mapScrool);

    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position = Vector2(70, size.y - size.y * 0.18 - 100);
    add(kidOnCycle);

    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(10, size.y * 0.1);
    add(molly);

    dialogueBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.35, size.y * 0.1),
      size: Vector2(size.x * 0.6, size.y * 0.15),
      text: "Let's go find the treasure! Tap on the screen to start moving.",
    );
    add(dialogueBox);

    speakDialogue(dialogueBox.text);

    gateTimer = Timer(3.0, onTick: () async {
      if (!gateAppeared) {
        gateAppeared = true;
        gate = SpriteComponent()
          ..sprite = await loadSprite('newgate-game.png')
          ..size = Vector2(150, 150)
          ..position = Vector2(size.x + 90, size.y - size.y * 0.18 - 40)
          ..angle = pi / 20;
        add(gate!);
      }
    });

    gateTimer.start();
  }

  Future<void> speakDialogue(String text) async {
    await _flutterTts.stop();
    print("Speaking: $text");
    await _flutterTts.speak(text);
  }

  void playBicycleSound() async {
    try {
      if (!isBicycleSoundPlaying) {
        await _bicycleSoundPlayer
            .setSource(AssetSource('audio/cycling-noise.mp3'));
        await _bicycleSoundPlayer.setVolume(1.0);
        await _bicycleSoundPlayer.setReleaseMode(ReleaseMode.loop);
        await _bicycleSoundPlayer.resume();
        isBicycleSoundPlaying = true;
      }
    } catch (e) {
      print("🚨 Error playing bicycle sound: $e");
    }
  }

  void stopBicycleSound() async {
    try {
      if (isBicycleSoundPlaying) {
        await _bicycleSoundPlayer.stop();
        isBicycleSoundPlaying = false;
      }
    } catch (e) {
      print("🚨 Error stopping bicycle sound: $e");
    }
  }

  String getRandomWord() {
    final random = Random();
    return dyslexiaWords[random.nextInt(dyslexiaWords.length)];
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.5);
    await _flutterTts.setSpeechRate(0.4);
  }

  void _initializeSpeechToText() async {
    speechToText = stt.SpeechToText();
    await speechToText.initialize(
      onStatus: (status) {
        print("🟡 SpeechToText status: $status");
        if (status == 'done' && recognizedText.isNotEmpty) {
          print("🛑 Speech recognition completed.");
        }
      },
      onError: (error) => print("❌ SpeechToText error: $error"),
    );
  }

  void showGateTaskOverlay() async {
    displayedWord = getRandomWord();

    Future.delayed(Duration(seconds: 5), () async {
      remove(kidOnCycle);
      overlayContainer = PositionComponent();

      overlay = RectangleComponent(
        size: Vector2(size.x, size.y),
        paint: Paint()..color = const Color(0xAA000000),
      );
      overlayContainer.add(overlay);

      molly = SpriteComponent()
        ..sprite = await loadSprite('girl-idea.png')
        ..size = Vector2(150, 150)
        ..position = Vector2(10, size.y * 0.1);
      overlayContainer.add(molly);

      instructionBox = diabox.DialogueBoxComponent(
        position: Vector2(size.x * 0.35, size.y * 0.1),
        size: Vector2(size.x * 0.6, size.y * 0.15),
        text: "To open the gate, say the word written correctly:",
      );
      overlayContainer.add(instructionBox);

      await speakDialogue("To open the gate, say the word written correctly:");

      wordBox = recwithword.FilledRoundedRectangleWithWordComponent(
        position: Vector2(size.x * 0.2, size.y * 0.5),
        size: Vector2(size.x * 0.6, 150),
        color: const Color(0xFFFAF3DD),
        borderRadius: 20,
        word: displayedWord,
      );
      overlayContainer.add(wordBox);

      recognizedTextDisplay = TextComponent(
        text: "Recognized: ",
        position: Vector2(wordBox.position.x + 20, wordBox.position.y + 100),
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      );
      overlayContainer.add(recognizedTextDisplay);

      addToggleButton();
      overlayContainer.add(toggleButton!);

      add(overlayContainer);

      await speakPhonics(displayedWord);
      await _flutterTts.speak(instructionBox.text);
    });
  }

  Future<void> speakPhonics(String word) async {
    String phonics = word.split('').join(' ');
    await _flutterTts.speak("Let's sound it out: $phonics");

    await Future.delayed(Duration(seconds: 3));

    await _flutterTts.speak("Now say the whole word: $word");
  }

  void addToggleButton() {
    var buttonText = TextComponent(
      text: "Press to Start",
      position: Vector2(75, 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    toggleButton = ToggleButton(
      position: Vector2(size.x * 0.32, wordBox.position.y + 200),
      buttonText: buttonText,
      onPressed: () => _toggleSpeechRecognition(buttonText),
    );

    overlayContainer.add(toggleButton!);
  }

  void _toggleSpeechRecognition(TextComponent buttonText) {
    if (isRecording) {
      speechToText.stop();
      isRecording = false;
      buttonText.text = "Press to Start";
    } else {
      _startSpeechRecognition(buttonText);
      isRecording = true;
      buttonText.text = "Stop";
    }
  }

  void _startSpeechRecognition(TextComponent buttonText) async {
    if (speechToText.isAvailable) {
      print("🎤 Speech recognition started...");
      isRecording = true;
      recognizedText = "";

      speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          recognizedTextDisplay.text = "Recognized: $recognizedText";

          if (result.finalResult) {
            print("🎤 Final recognition result: ${result.recognizedWords}");
            isRecording = false;
            buttonText.text = "Press to Start";

            if (recognizedText.isNotEmpty) {
              _analyzeRecordedWord();
            } else {
              print("⚠️ No valid word detected in final result.");
            }
          }
        },
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 2),
      );
    } else {
      print("❌ Speech recognition is not available.");
      buttonText.text = "Press to Start";
    }
  }

  void _analyzeRecordedWord() {
    if (recognizedText.isEmpty || recognizedText.trim().isEmpty) {
      print("⚠️ No valid word recognized, skipping analysis.");
      return;
    }

    recognizedTextDisplay.text = "Recognized: $recognizedText";
    bool isCorrect = recognizedText.toLowerCase().trim() ==
        displayedWord.toLowerCase().trim();

    if (isCorrect) {
      print("✅ Correct word: $recognizedText");
      _onCorrectPronunciation();
    } else {
      print("❌ Incorrect word: $recognizedText");
      _onIncorrectPronunciation();
    }
  }

  bool _doWordsRhyme(String word1, String word2) {
    if (word1.length < 2 || word2.length < 2) return false;
    return word1.substring(word1.length - 2) ==
        word2.substring(word2.length - 2);
  }

  int correctResponses = 0;
  int incorrectResponses = 0;

  void _onCorrectPronunciation() async {
    correctResponses++;
    correctProunicationCount++;
    speechToText.stop();
    isRecording = false;

    instructionBox.text = "✅ Great! You pronounced it correctly!";
    print("🟢 Speaking: Great! You pronounced it correctly!");

    await speakDialogue("Great! You pronounced it correctly!");

    if (correctProunicationCount >= 3) {
      
      Future.delayed(Duration(seconds: 4), () {
        hideGateTaskOverlay();
        openGate();
        showKidOnCycleAfterGate();
      });
    } else {
      
      Future.delayed(Duration(seconds: 4), () {
        
        displayedWord = getRandomWord();
        wordBox.word = displayedWord;
        recognizedTextDisplay.text = "Recognized: ";
        instructionBox.text =
            "To open the gate, say the word written correctly:";
        addToggleButton(); 
        speakPhonics(displayedWord); 
      });
    }
  }

  void _onIncorrectPronunciation() async {
    incorrectResponses++;
    speechToText.stop();
    isRecording = false;

    instructionBox.text = "❌ Oops! Try again.";
    print("🔴 Speaking: Oops! Try again.");

    await speakDialogue("Oops! Try again.");
  }

  void showPerformanceSummary() {
    final summary =
        "Correct: $correctResponses, Incorrect: $incorrectResponses";
    print(summary);
  }

  void openGate() async {
    if (gate != null) {
      leftGate = SpriteComponent()
        ..sprite = await loadSprite('left-side-gate.png')
        ..size = Vector2(100, 150)
        ..position = Vector2(gate!.position.x - 300, gate!.position.y - 20);

      rightGate = SpriteComponent()
        ..sprite = await loadSprite('right-side-gate.png')
        ..size = Vector2(100, 150)
        ..position = Vector2(gate!.position.x - 300, gate!.position.y + 40);

      remove(gate!);
      gate = null;
      add(leftGate!);
      add(rightGate!);

      gatesMoving = true;
    }
  }

  void showTreasureChest() async {
    treasureChest = SpriteComponent()
      ..sprite = await loadSprite('treasure chest.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(size.x + 50, size.y - size.y * 0.18 - 50);

    add(treasureChest);
    isTreasureMoving = true;
  }

  void showKidOnCycleAfterGate() {
    if (gate != null) {
      kidOnCycle.position = Vector2(100, size.y - size.y * 0.18 - 80);
      add(kidOnCycle);
    }
  }

  void hideGateTaskOverlay() {
    if (overlayContainer.parent != null) {
      remove(overlayContainer);
    }
  }

  void moveGateLeftAndRemove(double dt) {
    if (gateOpened && gate != null) {
      gate!.position.x -= speed * dt;

      if (gate!.position.x + gate!.size.x < 0) {
        remove(gate!);
        gate = null;
        isMoving = true;

        Future.delayed(Duration(seconds: 4), () {
          showTreasureChest();
        });
      }
    }
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
      if (molly.parent != null) remove(molly);
      if (dialogueBox.parent != null) remove(dialogueBox);
      playBicycleSound();

      gateTimer.update(dt);

      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      mapScrool.position = Vector2(size.x - mapScrool.size.x - 10, 10);

      if (gate != null) {
        gate!.position.x -= speed * dt;

        if (gate != null) {
          double distance =
              (gate!.position.x - (kidOnCycle.position.x + kidOnCycle.size.x))
                  .abs();
          if (distance < 2) {
            isMoving = false;
            parallaxComponent.parallax!.baseVelocity = Vector2.zero();

            molly = SpriteComponent()
              ..sprite = await loadSprite('animated-shocked-girl.png')
              ..size = Vector2(120, 120)
              ..position = Vector2(10, size.y * 0.1);
            add(molly);

            dialogueBox = speechbox.DialogueBoxComponent(
              position: Vector2(size.x * 0.35, size.y * 0.1),
              size: Vector2(size.x * 0.6, size.y * 0.15),
              text: "Oh no! There is a barrier that is blocking the way.",
            );
            add(dialogueBox);

            await speakDialogue(
                "Oh no! There is a barrier that is blocking the way.");

            if (!showOverlay) {
              Future.delayed(Duration(seconds: 4), () {
                remove(molly);
                remove(dialogueBox);
              });

              showOverlay = true;
              showGateTaskOverlay();
            }
          } else {
            gate!.position.x -= speed * dt;
          }

          if (!isRecording) {
            speechToText.stop();
          }
        }
      }

      if (gatesMoving) {
        if (leftGate != null && rightGate != null) {
          leftGate!.position.x -= speed * dt;
          rightGate!.position.x -= speed * dt;

          if (leftGate!.position.x + leftGate!.size.x < 0 &&
              rightGate!.position.x + rightGate!.size.x < 0) {
            remove(leftGate!);
            remove(rightGate!);
            leftGate = null;
            rightGate = null;
            gatesMoving = false;
            isMoving = true;

            Future.delayed(Duration(seconds: 4), () {
              showTreasureChest();
            });
          }
        }
      }

      if (isTreasureMoving && treasureChest != null) {
        treasureChest.position.x -= speed * dt;

        if (treasureChest.position.x <= size.x / 2 + 40) {
          isTreasureMoving = false;

          isMoving = false;
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();
          stopBicycleSound();

          Future.delayed(Duration(seconds: 1), () {
            showMollyAndDialogue();
          });
        }
      }
    } else {
      stopBicycleSound();
    }
  }

  void showMollyAndDialogue() async {
    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-yay-girl.png')
      ..size = Vector2(90, 150)
      ..position = Vector2(10, size.y * 0.1);
    add(molly);

    foundTreasureBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.35, size.y * 0.1),
      size: Vector2(size.x * 0.6, size.y * 0.15),
      text: "🎉 Wow! We finally found the treasure! 🎉",
    );
    add(foundTreasureBox);

    await speakDialogue("Wow! We finally found the treasure! ");
  }

  void moveComponent(SpriteComponent component1, SpriteComponent component2,
      double movementSpeed) {
    component1.position.x -= movementSpeed;
    component2.position.x -= movementSpeed;

    if (component1.position.x + component1.size.x <= 0) {
      component1.position.x = component2.position.x + component2.size.x - 30;
    }
    if (component2.position.x + component2.size.x <= 0) {
      component2.position.x = component1.position.x + component1.size.x - 30;
    }
  }

  void switchToAfterMapLevel(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameWidget(game: ForestLevel()),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _flutterTts.stop();

    if (gateOpened && !gatesMoving) {
      gatesMoving = true;
      isMoving = true;
    } else {
      isMoving = true;
    }
    playBicycleSound();
  }
}
