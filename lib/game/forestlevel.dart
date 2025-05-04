import 'dart:io';
import 'package:dream/game/afterfishlevel.dart';
import 'package:dream/game/afterforestlevel.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flame/events.dart';
import 'dart:math';
import 'package:dream/game/class/animalrectangle.dart' as animalrec;
import 'package:dream/game/class/filledroundreccomp.dart' as roundrec;
import 'package:dream/game/class/dialogueboxcomponent.dart' as diabox;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream/global.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForestLevel extends FlameGame {
  late SpriteComponent background;
  late roundrec.FilledRoundedRectangleComponent bottomRectangle;
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration? totalDuration;
  late diabox.DialogueBoxComponent dialogueBox;
  late SpriteComponent molly;
  late FlutterTts tts;
  SpriteComponent? animalImage;
  bool isGameStarted = false;
  final List<Map<String, dynamic>> roundData = [];

  final Map<String, String> animalImageMap = {
    'Cat': 'cat.png',
    'Cow': 'cow.png',
    'Dog': 'dog.png',
    'Goat': 'goat.png',
    'Horse': 'horse.png',
    'Lion': 'lion.png',
    'Pig': 'pig.png',
    'Rooster': 'rooster.png',
    'Sheep': 'sheep.png',
  };

  final List<String> animalNames = [
    'Frog',
    'Rabbit',
    'Fox',
    'Deer',
    'Panda',
    'Eagle',
    'Shark',
    'Dolphin',
    'Zebra',
    'Giraffe',
    'Camel',
    'Peacock',
    'Koala',
    'Penguin',
    'Owl'
  ];
  final Random random = Random();
  String? correctAnimal;
  int roundCount = 0;
  final int maxRounds = 3;
  int correctAnswers = 0;
  double currentLevelScore = 0.0;
  bool isSelectionDisabled = false;

  @override
  Future<void> onLoad() async {
    tts = FlutterTts();
    tts.setLanguage("en-US");
    tts.setPitch(1.5);
    tts.setSpeechRate(0.4);

    background = SpriteComponent()
      ..sprite = await loadSprite('forest-background.jpeg')
      ..size = size
      ..position = Vector2.zero();
    add(background);

    bottomRectangle = roundrec.FilledRoundedRectangleComponent(
      position: Vector2(20, size.y - 210),
      size: Vector2(size.x - 40, 190),
      color: const Color(0xFFADD8E6).withOpacity(0.7),
      borderRadius: 25,
    );
    add(bottomRectangle);

    molly = SpriteComponent()
      ..sprite = await loadSprite('animated-waving-girl.png')
      ..size = Vector2(150, 150)
      ..position = Vector2(10, 50);
    add(molly);

    dialogueBox = diabox.DialogueBoxComponent(
      position: Vector2(130, 70),
      size: Vector2(size.x - 150, 120),
      text: "Listen to the sounds and tap the correct name to reveal them. Let's start!",
    );
    add(dialogueBox);

    await tts.speak(
        "The animals here are shy. Listen to the sounds and tap the correct name to reveal them. The animal will make its sound only once. Let's start!");

    tts.setCompletionHandler(() async {
      if (!isGameStarted) {
        isGameStarted = true;
        await Future.delayed(Duration(seconds: 2));
        startGame();
      }
    });
  }

  Future<void> startGame() async {
    isSelectionDisabled = false;
    removeAnimalImage();
    clearAnimalRectangles();

    final audioFiles = [
      'Cat-1.mp3',
      'Cow-1.mp3',
      'Dog-1.mp3',
      'Goat-1.mp3',
      'Horse-1.mp3',
      'Lion-1.mp3',
      'Pig-1.mp3',
      'Rooster-1.mp3',
      'Sheep-1.mp3',
    ];
    final selectedAudio = audioFiles[random.nextInt(audioFiles.length)];
    correctAnimal = selectedAudio.split('-')[0];

    try {
      await audioPlayer.setAsset('assets/audio/$selectedAudio');
      totalDuration = await audioPlayer.load();
    } catch (error) {
      print('Error loading audio: $error');
    }

    await audioPlayer.play();

    final selectedNames = <String>{correctAnimal!};
    while (selectedNames.length < 5) {
      selectedNames.add(animalNames[random.nextInt(animalNames.length)]);
    }
    final selectedNamesList = selectedNames.toList()..shuffle();

    addAnimalRectangles(selectedNamesList);
  }

  void clearAnimalRectangles() {
    for (var component in children.toList()) {
      if (component is animalrec.AnimalRectangle) {
        remove(component);
      }
    }
  }

  void removeAnimalImage() {
    if (animalImage != null && animalImage!.parent != null) {
      remove(animalImage!);
      animalImage = null;
    }
  }

  void addAnimalRectangles(List<String> selectedNamesList) {
    final double rectangleWidth = (size.x - 100) / 3;
    final double rectangleHeight = 40;
    final double firstRowY = size.y - 160;
    final double secondRowY = size.y - 100;

    for (int i = 0; i < 3; i++) {
      add(animalrec.AnimalRectangle(
        position: Vector2(30 + i * (rectangleWidth + 15), firstRowY),
        size: Vector2(rectangleWidth, rectangleHeight),
        text: selectedNamesList[i],
        onTapCallback: onRectangleTap,
      ));
    }

    for (int i = 0; i < 2; i++) {
      add(animalrec.AnimalRectangle(
        position: Vector2(70 + i * (rectangleWidth + 20), secondRowY),
        size: Vector2(rectangleWidth, rectangleHeight),
        text: selectedNamesList[i + 3],
        onTapCallback: onRectangleTap,
      ));
    }
  }
  int attempts = 0;

  void onRectangleTap(animalrec.AnimalRectangle rectangle) async {
  if (isSelectionDisabled) return;

  isSelectionDisabled = true;

  roundData.add({
    'selectedAnimal': rectangle.text,
    'correctAnimal': correctAnimal,
    'wasCorrect': rectangle.text == correctAnimal,
    'timestamp': DateTime.now().toString(),
  });

  if (rectangle.text == correctAnimal) {
    correctAnswers++;
    showAnimalImage(correctAnimal!);
    await tts.speak("Congratulations! You found the $correctAnimal!");
    roundCount++;
    attempts = 0;
    await Future.delayed(Duration(seconds: 6));
    if (roundCount < maxRounds) {
      startGame();
    } else {
      calculateFinalScore();
      await _storeForestScore();
      await tts.speak("We made it through the forest adventure!");
      onTaskCompleted();
    }
  } else {
    attempts++;
    if (attempts < 2) {
      await tts.speak("That's not the right one. Try again carefully.");
      isSelectionDisabled = false;
    } else {
      await tts.speak("🔄 Oops! That animal is still hiding. Let's try a different sound.");
      roundCount++;
      attempts = 0;
      await Future.delayed(Duration(seconds: 6));
      if (roundCount < maxRounds) {
        startGame();
      } else {
        calculateFinalScore();
        await _storeForestScore();
        await tts.speak("We made it through the forest adventure!");
        onTaskCompleted();
      }
    }
  }
}


  void calculateFinalScore() {
    // Simple scoring - 1 point per correct answer, max 3 points
    currentLevelScore = correctAnswers.toDouble();
    print('Calculated Forest Level Score: $currentLevelScore/3');
  }

  Future<void> _storeForestScore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null ) {
        print('User not authenticated or no child selected');
        return;
      }

      final scoresDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .doc(currentSelectedChildId)
          .collection('dyslexiascore')
          .doc('game_scores');

      await scoresDoc.set({
        'forestLevelScore': currentLevelScore,
      }, SetOptions(merge: true));

      print('🌲 Forest level results saved');
    } catch (e) {
      print('🔥 Error storing forest score: $e');
    }
  }

  void showAnimalImage(String animalName) async {
    final animalPath = animalImageMap[animalName];
    if (animalPath != null) {
      removeAnimalImage();

      animalImage = SpriteComponent()
        ..sprite = await Sprite.load(animalPath)
        ..size = Vector2(150, 150)
        ..position = Vector2(size.x / 2 - 75, size.y - 420);
      add(animalImage!);
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    audioPlayer.dispose();
  }

  void onTaskCompleted() async {
    await tts.speak("Great job! Lets continue our jouney");
    
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(buildContext!).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameWidget(game: Afterforestlevel()),
        ),
      );
    });
  }
}