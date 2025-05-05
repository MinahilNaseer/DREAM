// A cleaner and well-structured version of the ForestLevel Flame Game

import 'dart:math';
import 'dart:io';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dream/global.dart';
import 'package:dream/game/class/animalrectangle.dart' as animalrec;
import 'package:dream/game/class/filledroundreccomp.dart' as roundrec;
import 'package:dream/game/class/dialogueboxcomponent.dart' as diabox;
import 'package:dream/game/afterforestlevel.dart';

class ForestLevel extends FlameGame {
  late SpriteComponent background;
  late roundrec.FilledRoundedRectangleComponent bottomRectangle;
  late diabox.DialogueBoxComponent dialogueBox;
  late SpriteComponent molly;
  SpriteComponent? animalImage;

  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts tts = FlutterTts();
  final Random random = Random();

  bool isGameStarted = false;
  bool isSelectionDisabled = false;
  int roundCount = 0;
  int correctAnswers = 0;
  int attempts = 0;
  final int maxRounds = 3;
  double currentLevelScore = 0.0;

  String? correctAnimal;
  Duration? totalDuration;
  final List<Map<String, dynamic>> roundData = [];

  final Map<String, String> animalImageMap = {
    'Cat': 'cat.png', 'Cow': 'cow.png', 'Dog': 'dog.png',
    'Goat': 'goat.png', 'Horse': 'horse.png', 'Lion': 'lion.png',
    'Pig': 'pig.png', 'Rooster': 'rooster.png', 'Sheep': 'sheep.png',
  };

  final List<String> animalNames = [
    'Frog', 'Rabbit', 'Fox', 'Deer', 'Panda', 'Eagle', 'Shark',
    'Dolphin', 'Zebra', 'Giraffe', 'Camel', 'Peacock', 'Koala',
    'Penguin', 'Owl'
  ];

  @override
  Future<void> onLoad() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.5);
    await tts.setSpeechRate(0.4);

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

    await tts.speak("The animals here are shy. Listen to the sounds and tap the correct name to reveal them. The animal will make its sound only once. Let's start!");

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

    final audioFiles = animalImageMap.keys.map((e) => '$e-1.mp3').toList();
    final selectedAudio = audioFiles[random.nextInt(audioFiles.length)];
    correctAnimal = selectedAudio.split('-')[0];

    try {
      await audioPlayer.setAsset('assets/audio/$selectedAudio');
      totalDuration = await audioPlayer.load();
    } catch (e) {
      print('Error loading audio: $e');
    }

    await audioPlayer.play();

    final selectedNames = <String>{correctAnimal!};
    while (selectedNames.length < 5) {
      selectedNames.add(animalNames[random.nextInt(animalNames.length)]);
    }
    final selectedList = selectedNames.toList()..shuffle();
    addAnimalRectangles(selectedList);
  }

  void addAnimalRectangles(List<String> names) {
    final double w = (size.x - 100) / 3;
    final double h = 40;
    final double row1 = size.y - 160;
    final double row2 = size.y - 100;

    for (int i = 0; i < 3; i++) {
      add(animalrec.AnimalRectangle(
        position: Vector2(30 + i * (w + 15), row1),
        size: Vector2(w, h),
        text: names[i],
        onTapCallback: onRectangleTap,
      ));
    }
    for (int i = 0; i < 2; i++) {
      add(animalrec.AnimalRectangle(
        position: Vector2(70 + i * (w + 20), row2),
        size: Vector2(w, h),
        text: names[i + 3],
        onTapCallback: onRectangleTap,
      ));
    }
  }

  void onRectangleTap(animalrec.AnimalRectangle rect) async {
    if (isSelectionDisabled) return;
    isSelectionDisabled = true;

    roundData.add({
      'selectedAnimal': rect.text,
      'correctAnimal': correctAnimal,
      'wasCorrect': rect.text == correctAnimal,
      'timestamp': DateTime.now().toString(),
    });

    if (rect.text == correctAnimal) {
      correctAnswers++;
      showAnimalImage(correctAnimal!);
      await tts.speak("Congratulations! You found the $correctAnimal!");
      roundCount++;
      attempts = 0;
      await Future.delayed(Duration(seconds: 6));
    } else {
      attempts++;
      if (attempts < 2) {
        await tts.speak("That's not the right one. Try again.");
        isSelectionDisabled = false;
        return;
      } else {
        await tts.speak("Oops! That animal is still hiding. Let's try a different sound.");
        roundCount++;
        attempts = 0;
        await Future.delayed(Duration(seconds: 6));
      }
    }

    if (roundCount < maxRounds) {
      startGame();
    } else {
      calculateFinalScore();
      await _storeForestScore();
      await tts.speak("We made it through the forest adventure!");
      onTaskCompleted();
    }
  }

  void calculateFinalScore() {
    currentLevelScore = correctAnswers.toDouble();
    print('Forest Level Score: $currentLevelScore/$maxRounds');
  }

  Future<void> _storeForestScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final scoreRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('children')
        .doc(currentSelectedChildId)
        .collection('dyslexiascore')
        .doc('game_scores');

    await scoreRef.set({ 'forestLevelScore': currentLevelScore }, SetOptions(merge: true));
  }

  void showAnimalImage(String name) async {
    final path = animalImageMap[name];
    if (path != null) {
      removeAnimalImage();
      animalImage = SpriteComponent()
        ..sprite = await Sprite.load(path)
        ..size = Vector2(150, 150)
        ..position = Vector2(size.x / 2 - 75, size.y - 420);
      add(animalImage!);
    }
  }

  void removeAnimalImage() {
    if (animalImage?.parent != null) remove(animalImage!);
    animalImage = null;
  }

  void clearAnimalRectangles() {
    for (final c in children.whereType<animalrec.AnimalRectangle>().toList()) {
      remove(c);
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    audioPlayer.dispose();
  }

  void onTaskCompleted() async {
    await tts.speak("Great job! Let's continue our journey.");
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(buildContext!).pushReplacement(
        MaterialPageRoute(builder: (context) => GameWidget(game: Afterforestlevel())),
      );
    });
  }
}
