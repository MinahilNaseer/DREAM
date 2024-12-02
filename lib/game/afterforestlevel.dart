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
import 'forestlevel.dart';
import 'dart:math';

class Afterforestlevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent forest;
  SpriteComponent? mapScrool;
  late SpriteComponent molly;
  late DialogueBoxComponent dialogueBox;
  late FlutterTts _flutterTts;
  bool isMoving = false;
  final double speed = 100;
  final double cycleSpeed = 70;
  bool isForestRemoved = false;
  late Timer mapScroollTimer;
  bool isAudioPlayed = false;
  bool isQuestionAnswered = false;
  late SpriteComponent missingTileBucket;
  late RoundedRectangleComponent missingTilePlaceholder;
  bool isMapDisplayed = false;
  bool isDialogueBoxDisplayed = false;
  bool isMollyDisplayed = false;
  List<DraggableTile> currentTiles = [];
  int puzzleStage = 1; 

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

    dialogueBox = DialogueBoxComponent(
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

  @override
  void update(double dt) async {
    super.update(dt);

    if (isMoving) {
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
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();
          if (!isMapDisplayed) {
            molly.sprite = await loadSprite('animated-shocked-girl.png');
            molly.position = Vector2(
                10, size.y * 0.1); 
            molly.size = Vector2(120, 120); 
            add(molly);

            dialogueBox = DialogueBoxComponent(
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

                    final explanationBox = DialogueBoxComponent(
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
    }
  }

  
  String generateRandomQuestion() {
    final random = Random();
    final color =
        colorLetterMap.keys.elementAt(random.nextInt(colorLetterMap.length));
    final letter = colorLetterMap[color]!;
    return "Find the tile that is $color and shows the letter '$letter'!";
  }

  void startPuzzleGameplay() async {
    if (isQuestionAnswered)
      return; 

    isQuestionAnswered = true;
    
    final questionText = generateRandomQuestion();
    final questionBox = DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.15),
      text: questionText,
    );
    add(questionBox);

    await _flutterTts.speak(questionText +
        "Pick the correct color block and drag it towards the bucket.");

    addDraggableTiles(questionText);
  }

  void addDraggableTiles(String questionText) async {
    final List<DraggableTile> tileOptions = [];
    final random = Random();

    final color = questionText.split(' ')[5]; 
    final letter = questionText.split(' ').last.replaceAll("'", "");
    
    final correctTile = DraggableTile(
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
    
    currentTiles.add(correctTile);
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
      final incorrectTile = DraggableTile(
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
      currentTiles.add(incorrectTile);
    }
    for (var tile in tileOptions) {
      add(tile);
    }
    add(missingTileBucket);
  }

  void handleTileDropped(DraggableTile droppedTile) async {
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

  void snapToPlaceholder(DraggableTile tile) {
    
    remove(missingTileBucket);

    
    tile.position = missingTileBucket.position;
    tile.size = missingTileBucket.size;

    addSuccessFeedback();
  }

  Future<void> addSuccessFeedback() async {
    
    final successBox = DialogueBoxComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.15),
      text: "Great job! You placed the correct tile.",
    );

    
    add(successBox);

    
    await _flutterTts.speak("Great job! You placed the correct tile.");

    
    Future.delayed(const Duration(seconds: 5), () {
      if (successBox.parent != null) remove(successBox);
    });
  }

  Future<void> addFailureFeedback() async {
    
    final failureBox = DialogueBoxComponent(
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

    
    final dialogueBox = DialogueBoxComponent(
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

    
    final dialogueBox = DialogueBoxComponent(
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

    
    for (var tile in currentTiles) {
      if (tile.parent != null) {
        remove(tile);
      }
    }

    
    currentTiles.clear();

    
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

class DialogueBoxComponent extends PositionComponent {
  String text;

  DialogueBoxComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFFFAF3DD);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(20),
    );
    canvas.drawRRect(rrect, paint);

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      fontFamily: 'Arial',
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.x * 0.9,
    );

    final textOffset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }
}

class DraggableTile extends SpriteComponent with DragCallbacks {
  final String tileName; 
  final Function(DraggableTile) onDropOnPlaceholder;
  final SpriteComponent missingTilePlaceholder; 
  final Vector2 initialPosition; 
  bool isDragging = false;

  DraggableTile({
    required this.tileName,
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
    required this.onDropOnPlaceholder,
    required this.missingTilePlaceholder,
  })  : initialPosition = position.clone(), 
        super(sprite: sprite, size: size, position: position);

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isDragging) {
      position.add(event.delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;

    
    if ((position - missingTilePlaceholder.position).length < 50) {
      onDropOnPlaceholder(this); 
    } else {
      
      resetPosition();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    isDragging = false;
    resetPosition();
  }

  void resetPosition() {
    
    position.setFrom(initialPosition);
  }
}


class RoundedRectangleComponent extends RectangleComponent {
  final double cornerRadius;

  RoundedRectangleComponent({
    required Vector2 size,
    required Vector2 position,
    required Paint paint,
    this.cornerRadius = 10.0,
  }) : super(size: size, position: position, paint: paint);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0; 
    canvas.drawRRect(rrect, paint);
  }
}
