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

class Aftermaplevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  //late SpriteComponent forest;
  late SpriteComponent mapScrool;
  late SpriteComponent molly;
  late speechbox.DialogueBoxComponent dialogueBox;
  SpriteComponent? gate;

  late FlutterTts _flutterTts;

  bool isMoving = false;
  final double speed = 100;
  //final double cycleSpeed = 70;
  bool gateAppeared = false;
  late Timer gateTimer;

  //bool isDialogueBoxDisplayed = false;
  //bool isMollyDisplayed = false;
  bool showOverlay = false;
  late RectangleComponent overlay; // The overlay rectangle
  late diabox.DialogueBoxComponent instructionBox;
  late recwithword.FilledRoundedRectangleWithWordComponent wordBox;
  //late ButtonComponent startButton;
  late TextComponent recognizedTextDisplay;

  //late FlutterTts _flutterTts;
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

  @override
  Future<void> onLoad() async {
    await _initializeTTS();
    _initializeSpeechToText();

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

    // Speak the dialogue box text
    speakDialogue(dialogueBox.text);

    gateTimer = Timer(3.0, onTick: () async {
      if (!gateAppeared) {
        gateAppeared = true; // Ensure the gate appears only once
        gate = SpriteComponent()
          ..sprite = await loadSprite('gate.png')
          ..size = Vector2(250, 250)
          ..position = Vector2(size.x + 60, size.y - size.y * 0.18 - 130)
          ..angle = pi / 20;
        add(gate!);
      }
    });

    gateTimer.start();
  }

  /// Speak the given dialogue text
  Future<void> speakDialogue(String text) async {
    // Stop any ongoing speech
    await _flutterTts.stop();

    // Log the text being spoken for debugging
    print("Speaking: $text");

    // Speak the dialogue text
    await _flutterTts.speak(text);
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
        print("SpeechToText status: $status");
        if (status == 'done') {
          isRecording = false;
          _analyzeRecordedWord();
        }
      },
      onError: (error) => print("SpeechToText error: $error"),
    );
  }

  void showGateTaskOverlay(String word) async {
    Future.delayed(Duration(seconds: 5), () async {
      remove(kidOnCycle);
      overlayContainer = PositionComponent();

      // Create a dim overlay
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
        word: word,
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

      await speakPhonics(word);
      await _flutterTts.speak(instructionBox.text);
    });
  }

  Future<void> speakPhonics(String word) async {
    // Pronounce each letter individually
    String phonics = word.split('').join(' ');
    await _flutterTts.speak("Let's sound it out: $phonics");

    // Delay to allow letter pronunciation to finish
    await Future.delayed(Duration(seconds: 3));

    // Pronounce the whole word
    await _flutterTts.speak("Now say the whole word: $word");
  }

  void addToggleButton() {
    var buttonText = TextComponent(
      text: "Press to Start",
      position: Vector2(75, 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      isRecording = true;
      recognizedText = ""; // Reset recognized text
      speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          if (!isRecording) return; // Ensure we only analyze once

          // Check if the recognition result is final
          if (result.finalResult) {
            isRecording = false;
            buttonText.text = "Press to Start";
            _analyzeRecordedWord();
          }
        },
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 2),
      );
    } else {
      print("Speech recognition is not available.");
      buttonText.text = "Press to Start";
    }
  }

  void _analyzeRecordedWord() {
    recognizedTextDisplay.text = "Recognized: $recognizedText";

    if (recognizedText.toLowerCase() == displayedWord.toLowerCase()) {
      _onCorrectPronunciation();
    } else {
      instructionBox.text = "Oops! Try again.";
      _flutterTts.speak(instructionBox.text);
    }
    isRecording = false;
    toggleButton?.children.whereType<TextComponent>().first.text =
        "Press to Start";
  }

  void _onCorrectPronunciation() async {
    speechToText.stop(); // Stop recognition
    isRecording = false;

    // Provide feedback
    instructionBox.text = "Great! You pronounced it correctly!";
    await _flutterTts.speak(instructionBox.text);

    // Logic to open the gate or proceed to the next level can be added here
    Future.delayed(Duration(seconds: 4), () {
      hideGateTaskOverlay();
      openGate();
      showKidOnCycleAfterGate();
    });
  }

  void openGate() async {
    if (gate != null) {
      gate!.sprite = await loadSprite('gate-open.png');
      gate!.size = Vector2(250, 250); // Adjust size as needed for open gate

      // Position the gate slightly more to the left when it opens
      gate!.position = Vector2(size.x - 350, size.y - size.y * 0.18 - 190);
      gateOpened = true;
    }
  }

  void showKidOnCycleAfterGate() {
    if (gate != null) {
      kidOnCycle.position = Vector2(130, size.y - size.y * 0.18 - 100);
      add(kidOnCycle);
    }
  }

  void hideGateTaskOverlay() {
    if (overlayContainer.parent != null) {
      remove(overlayContainer);
    }
  }

  // This method will handle the movement of the gate to the left and its removal
  void moveGateLeftAndRemove(double dt) {
    if (gateOpened && gate != null) {
      gate!.position.x -= speed * dt;

      // Check if the gate has moved completely off-screen
      if (gate!.position.x + gate!.size.x < 0) {
        remove(gate!);
        gate = null;
        isMoving = true; // Resume movement after the gate is removed

        // Show treasure and Molly after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        showTreasureAndMolly();
        isMoving = false; // Stop movement when the treasure is found
      });
      
      }
    }
  }
  // Modify `showTreasureAndMolly` method
void showTreasureAndMolly() async {
  // Add the treasure chest image
  treasureChest = SpriteComponent()
    ..sprite = await loadSprite('treasure chest.png')
    ..size = Vector2(150, 150)
    ..position = Vector2(size.x + 50, size.y - size.y * 0.18 - 150);
  add(treasureChest);

  isTreasureMoving = true;
}

  //@override
  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
      // Remove Molly and dialogue box if they exist
      if (molly.parent != null) remove(molly);
      if (dialogueBox.parent != null) remove(dialogueBox);

      // Update gate timer
      gateTimer.update(dt);

      // Move road and grass components to simulate scrolling
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      // Move parallax background
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      // Ensure the map scroll remains fixed in the top-right corner
      mapScrool.position = Vector2(size.x - mapScrool.size.x - 10, 10);

      // Check if the gate exists
      if (gate != null) {
        // Move the gate toward the screen
        gate!.position.x -= speed * dt;

        // Stop movement when kidOnCycle reaches the gate
        if (gate != null) {
          double distance =
              (gate!.position.x - (kidOnCycle.position.x + kidOnCycle.size.x))
                  .abs();
          if (distance < 2) {
            // Stop when kidOnCycle is close to the gate
            isMoving = false; // Stop all movement
            parallaxComponent.parallax!.baseVelocity =
                Vector2.zero(); // Stop background
            // Display Molly as a shocked character
            molly = SpriteComponent()
              ..sprite = await loadSprite('animated-shocked-girl.png')
              ..size = Vector2(120, 120)
              ..position = Vector2(10, size.y * 0.1);
            add(molly);

            // Update the dialogue box
            dialogueBox = speechbox.DialogueBoxComponent(
              position: Vector2(size.x * 0.35, size.y * 0.1),
              size: Vector2(size.x * 0.6, size.y * 0.15),
              text: "Oh no! This gate is blocking the way.",
            );
            add(dialogueBox);

            // Speak the dialogue
            await speakDialogue("Oh no! This gate is blocking the way.");
            // Show the overlay after the gate dialogue
            if (!showOverlay) {
              Future.delayed(Duration(seconds: 4), () {
                remove(molly);
                remove(dialogueBox);
              });

              showOverlay = true;
              showGateTaskOverlay("APPLE"); // Example preschooler-friendly word
            }
          } else {
            // Move the gate toward the screen
            gate!.position.x -= speed * dt;
          }
          // Stop the recording if the player moves on or presses the button again
          if (!isRecording) {
            speechToText.stop();
          }
        }
      }
      // Move the gate left if it has been opened
      moveGateLeftAndRemove(dt);
      // Move the treasure chest if it is set to move
    if (isTreasureMoving && treasureChest != null) {
      treasureChest.position.x -= speed * dt;

      // Stop the treasure chest and show Molly with the dialogue when it reaches the left side
      if (treasureChest.position.x <= size.x / 2 - 75) {
        isTreasureMoving = false;

        // Add Molly with the shocked sprite
        molly = SpriteComponent()
          ..sprite = await loadSprite('animated-shocked-girl.png')
          ..size = Vector2(150, 150)
          ..position = Vector2(10, size.y * 0.1);
        add(molly);

        // Add dialogue box
        foundTreasureBox = speechbox.DialogueBoxComponent(
          position: Vector2(size.x * 0.35, size.y * 0.1),
          size: Vector2(size.x * 0.6, size.y * 0.15),
          text: "We have found the treasure!",
        );
        add(foundTreasureBox);

        // Speak the dialogue
        await speakDialogue("We have found the treasure!");
      }
    }
    }
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

    if (gateOpened) {
    // If the gate is opened, start moving the gate left
    isMoving = true; // Temporarily stop the kid on cycle until the gate moves off-screen
  } else {
    isMoving = true; // Continue the regular movement
  }
  }
}

class ToggleButton extends PositionComponent with TapCallbacks {
  final TextComponent buttonText;
  final VoidCallback onPressed;

  ToggleButton({
    required Vector2 position,
    required this.buttonText,
    required this.onPressed,
  }) : super(position: position, size: Vector2(150, 60));

  @override
  void onLoad() {
    add(recstart.FilledRoundedRectangleComponent(
      position: Vector2.zero(),
      size: size,
      color: Colors.green,
      borderRadius: 15,
    ));
    add(buttonText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}
