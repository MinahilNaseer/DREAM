import 'dart:ui' as ui;
import 'package:dream/game/aftermaplevel.dart';
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
import 'package:dream/game/class/strokeroundreccompforest.dart' as recforest;
import 'package:dream/game/class/draggableblocks.dart' as draggableblocks;

class Afterforestlevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent forest;
  SpriteComponent? mapScrool;
  late SpriteComponent molly;
  late speechbox.DialogueBoxComponent dialogueBox;
  late FlutterTts _flutterTts;
  bool isMoving = false;
  final double speed = 100;
  final double cycleSpeed = 70;
  bool isForestRemoved = false;
  late Timer mapScroollTimer;
  bool isAudioPlayed = false;
  bool isQuestionAnswered = false;
  late SpriteComponent missingTileBucket;
  late recforest.StrokeRoundedRectangleComponent missingTilePlaceholder;
  bool isMapDisplayed = false;
  bool isDialogueBoxDisplayed = false;
  bool isMollyDisplayed = false;
  List<draggableblocks.DraggableTile> currentBlocks = [];
  int puzzleStage = 1; 
  late AudioPlayer _bicycleSoundPlayer;
  bool isBicycleSoundPlaying = false;

  final Map<String, String> colorLetterMap = {
    "blue": "B",
    "green": "G",
    "orange": "O",
    "pink": "P",
    "red": "R",
  };

  @override
  Future<void> onLoad() async {
    await _initializeTTS();
    _initializeBicycleSound();

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

    forest = SpriteComponent()
      ..sprite = await loadSprite('trees-scene.png')
      ..size = Vector2(280, 280)
      ..position = Vector2(size.x - 560, size.y - size.y * 0.28 - 30);
    add(forest);

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
      text: "Let's continue the journey! Tap on the screen to start moving.",
    );
    add(dialogueBox);

    await _flutterTts.speak(
        "Let's continue the journey! Tap on the screen to start moving.");

    mapScroollTimer = Timer(3.0, onTick: () async {
      if (mapScrool == null) {
        mapScrool = SpriteComponent()
          ..sprite = await loadSprite('map-scroll.png')
          ..size = Vector2(100, 100)
          ..position = Vector2(size.x + 50, size.y - size.y * 0.28 + 100);
        add(mapScrool!);
      }
    });

    mapScroollTimer.start();
    missingTileBucket = SpriteComponent()
      ..sprite = await loadSprite('bucket.png')
      ..size = Vector2(90, 90)
      ..position = Vector2(size.x * 0.1 + 120, size.y * 0.6 + 130);
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.5);
    await _flutterTts.setSpeechRate(0.4);
  }
  void _initializeBicycleSound() {
    _bicycleSoundPlayer = AudioPlayer();
  }

  void playBicycleSound() async {
    if (!isBicycleSoundPlaying) {
      await _bicycleSoundPlayer.setSource(AssetSource('audio/cycling-noise.mp3'));
      await _bicycleSoundPlayer.setVolume(1.0);
      await _bicycleSoundPlayer.setReleaseMode(ReleaseMode.loop);
      await _bicycleSoundPlayer.resume();
      isBicycleSoundPlaying = true;
    }
  }

  void stopBicycleSound() async {
    if (isBicycleSoundPlaying) {
      await _bicycleSoundPlayer.stop();
      isBicycleSoundPlaying = false;
    }
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
      playBicycleSound();
      if (molly.parent != null) remove(molly);
      if (dialogueBox.parent != null) remove(dialogueBox);
      mapScroollTimer.update(dt);
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);
      if (!isForestRemoved) {
        forest.position.x -= speed * dt;

        if (forest.position.x + forest.size.x < 0) {
          if (forest.parent != null) remove(forest);
          isForestRemoved = true;

          Future.delayed(const Duration(seconds: 3), () async {
            if (mapScrool == null) {
              mapScrool = SpriteComponent()
                ..sprite = await loadSprite('map-scroll.png')
                ..size = Vector2(200, 200)
                ..position = Vector2(
                    size.x,
                    size.y -
                        size.y * 0.28 -
                        70); 
              add(mapScrool!);
            }
          });
        }
      }
      if (mapScrool != null) {
        mapScrool!.position.x -= speed * dt;
        if ((mapScrool!.position.x - kidOnCycle.position.x).abs() < 80) {
          
          isMoving = false;
          stopBicycleSound(); 
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();
          if (!isMapDisplayed) {
            molly.sprite = await loadSprite('animated-shocked-girl.png');
            molly.position = Vector2(
                10, size.y * 0.1); 
            molly.size = Vector2(120, 120); 
            add(molly);

            dialogueBox = speechbox.DialogueBoxComponent(
              position: Vector2(size.x * 0.35, size.y * 0.1),
              size: Vector2(size.x * 0.6, size.y * 0.15),
              text: "Oh wow! It’s a map! What could it lead to?",
            );
            add(dialogueBox);

            await _flutterTts.speak(
                "Oh wow! It’s a map! What could it lead to? Let's open it and see!");

            isMollyDisplayed = true;
            Future.delayed(const Duration(seconds: 5), () async {
              if (molly.parent != null) {
                remove(molly);
              }
              if (dialogueBox.parent != null) {
                remove(dialogueBox);
              }
              isMollyDisplayed = false; 

              if (!isMapDisplayed) {
                isMapDisplayed = true;
                
                final overlay = RectangleComponent(
                  size: Vector2(size.x, size.y),
                  paint: Paint()
                    ..color = const Color(0xAA000000), 
                );
                add(overlay);

                final wholeMap = SpriteComponent()
                  ..sprite = await loadSprite(
                      'whole-map.png') 
                  ..size = Vector2(
                      size.x, size.y * 0.4) 
                  ..position = Vector2(
                      0,
                      size.y -
                          size.y *
                              0.4); 
                add(wholeMap);

                Future.delayed(const Duration(seconds: 1), () async {
                  if (!isDialogueBoxDisplayed) {
                    isDialogueBoxDisplayed = true;

                    final explanationBox = speechbox.DialogueBoxComponent(
                      position: Vector2(size.x * 0.1, size.y * 0.1),
                      size: Vector2(size.x * 0.8, size.y * 0.25),
                      text:
                          "This is a treasure map, but some parts are missing! To complete the map, we need to solve puzzles by selecting the correct blocks. Look at the hints on the missing parts, and let’s solve them to find the treasure!",
                    );
                    add(explanationBox);

                    await _flutterTts.speak(
                        "This is a treasure map, but some parts are missing! To complete the map, we need to solve puzzles by selecting the correct blocks. Look at the hints on the missing parts, and let’s solve them to find the treasure!");

                    Future.delayed(const Duration(seconds: 15), () {
                      
                      if (explanationBox.parent != null) remove(explanationBox);
                      if (wholeMap.parent != null) remove(wholeMap);

                      startPuzzleGameplay();
                    });
                  }
                });
              }
            });
          }
        }
        if (mapScrool!.position.x + mapScrool!.size.x < 0) {
          if (mapScrool!.parent != null) remove(mapScrool!);
        }
      }
    }else{
      stopBicycleSound();
    }
  }

  
  String generateRandomQuestion() {
    final random = Random();
    final color =
        colorLetterMap.keys.elementAt(random.nextInt(colorLetterMap.length));
    final letter = colorLetterMap[color]!;
    return "Find the block that is $color and shows the letter '$letter'!";
  }

  void startPuzzleGameplay() async {
    if (isQuestionAnswered)
      return; 

    isQuestionAnswered = true;
    
    final questionText = generateRandomQuestion();
    final questionBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.15),
      text: questionText,
    );
    add(questionBox);

    await _flutterTts.speak(questionText +
        "Pick the correct color block and drag it towards the bucket.");

    addDraggableBlocks(questionText);
  }

  void addDraggableBlocks(String questionText) async {
    final List<draggableblocks.DraggableTile> tileOptions = [];
    final random = Random();

    final color = questionText.split(' ')[5]; 
    final letter = questionText.split(' ').last.replaceAll("'", "");
    
    final correctTile = draggableblocks.DraggableTile(
      tileName: "Correct-$color-Tile",
      sprite: await loadSprite('correct_tiles/correct-$color-tile.png'),
      size: Vector2(70, 70),
      position: Vector2(size.x * 0.1, size.y * 0.6),
      missingTilePlaceholder: missingTileBucket, 
      onDropOnPlaceholder: (droppedTile) {
        handleTileDropped(droppedTile);
      },
    );
    tileOptions.add(correctTile);
    
    currentBlocks.add(correctTile);
    const incorrectTileNames = [
      "blue-with-D-tile.png",
      "blue-with-G-tile.png",
      "brown-with-B-tile.png",
      "brown-with-P-tile.png",
      "brown-with-R-tile.png",
      "green-with-C-tile.png",
      "green-with-G-tile.png",
      "green-with-P-tile.png",
      "green-with-T-tile.png",
      "grey-with-Q-tile.png",
      "pink-with-D-tile.png",
      "pink-with-Y-tile.png",
      "red-with-B-tile.png",
      "red-with-E-tile.png",
      "yellow-with-Y-tile.png"
    ];

    for (int i = 0; i < 3; i++) {
      final incorrectTile = draggableblocks.DraggableTile(
        tileName: "Incorrect-Tile-$i",
        sprite: await loadSprite(
            'incorrect_tiles/${incorrectTileNames[random.nextInt(incorrectTileNames.length)]}'),
        size: Vector2(70, 70),
        position: Vector2(size.x * (0.3 + (i * 0.2)), size.y * 0.6),
        missingTilePlaceholder: missingTileBucket, 
        onDropOnPlaceholder: (droppedTile) {
          handleTileDropped(droppedTile);
        },
      );
      tileOptions.add(incorrectTile);
      currentBlocks.add(incorrectTile);
    }
    for (var tile in tileOptions) {
      add(tile);
    }
    add(missingTileBucket);
  }

  void handleTileDropped(draggableblocks.DraggableTile droppedTile) async {
    final isCorrect = droppedTile.tileName.contains("Correct");

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 3), () async {
        remove(droppedTile);
      });
      await addSuccessFeedback();
      Future.delayed(const Duration(seconds: 3), () {
        if (puzzleStage == 1) {
          showUpdatedMap();
          puzzleStage++;
        } else if (puzzleStage == 2) {
          showUpdatedMapWithForest();
        }
      });
    } else {
      await addFailureFeedback();
      await Future.delayed(const Duration(seconds: 2));
      droppedTile.resetPosition();
    }
  }

  void snapToPlaceholder(draggableblocks.DraggableTile tile) {
    remove(missingTileBucket);
    tile.position = missingTileBucket.position;
    tile.size = missingTileBucket.size;
    addSuccessFeedback();
  }

  Future<void> addSuccessFeedback() async {
    final successBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.15),
      text: "Great job! You placed the correct block.",
    );
    add(successBox);
    await _flutterTts.speak("Great job! You placed the correct block.");

    Future.delayed(const Duration(seconds: 5), () {
      if (successBox.parent != null) remove(successBox);
    });
  }

  Future<void> addFailureFeedback() async {
    final failureBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.15),
      text: "Not quite! Try again!",
    );
    add(failureBox);
    await _flutterTts.speak("Not quite! Try again!");

    Future.delayed(const Duration(seconds: 5), () {
      if (failureBox.parent != null) remove(failureBox);
    });
  }

  void trackSelection(String tileName, {required bool isCorrect}) {
    print("Tile selected: $tileName, Correct: $isCorrect");
    final String result = isCorrect ? "Correct" : "Incorrect";
    print("Tracking data: $tileName -> $result");
  }

  void showUpdatedMap() async {
    final overlay = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()..color = const Color(0xAA000000), 
    );
    add(overlay);

    final updatedMap = SpriteComponent()
      ..sprite =
          await loadSprite('whole-map-with-pond.png') 
      ..size = Vector2(size.x, size.y * 0.4) 
      ..position =
          Vector2(0, size.y - size.y * 0.4); 
    add(updatedMap);

    final dialogueBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.2),
      text:
          "Look! After completing the puzzle, we have found the missing part: the pond! Now, let's move to the next one.",
    );
    add(dialogueBox);
    
    await _flutterTts.speak(
        "Look! After completing the puzzle, we have found the missing part, the pond! Now, let's move on to the next part.");
    
    Future.delayed(const Duration(seconds: 10), () {
      if (dialogueBox.parent != null) remove(dialogueBox);
      if (updatedMap.parent != null) remove(updatedMap);
      remove(overlay);

      startNextPuzzle();
    });
  }

  void showUpdatedMapWithForest() async {
    
    final overlay = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()..color = const Color(0xAA000000), 
    );
    add(overlay);

    final updatedMapWithForest = SpriteComponent()
      ..sprite =
          await loadSprite('whole-map-with-forest.png') 
      ..size = Vector2(size.x, size.y * 0.4) 
      ..position =
          Vector2(0, size.y - size.y * 0.4); 
    add(updatedMapWithForest);

    final dialogueBox = speechbox.DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.2),
      text:
          "Look! After completing the next puzzle, we have found the missing part: the forest! Now, we can find the treasure.",
    );
    add(dialogueBox);

    await _flutterTts.speak(
        "Look! After completing the next puzzle, we have found the missing part: the forest! Now, we can find the treasure.");

    
    Future.delayed(const Duration(seconds: 10), () {
      if (dialogueBox.parent != null) remove(dialogueBox);
      if (updatedMapWithForest.parent != null) remove(updatedMapWithForest);
      remove(overlay);

      // Navigate to AfterMapLevel
    switchToAfterMapLevel(buildContext!);
      
    });
  }

  void startNextPuzzle() {
    isQuestionAnswered = false;
    for (var tile in currentBlocks) {
      if (tile.parent != null) {
        remove(tile);
      }
    }
    currentBlocks.clear();
    startPuzzleGameplay();
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
        builder: (context) => GameWidget(game: Aftermaplevel()),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _flutterTts.stop();
    isMoving = true;
  }
}





