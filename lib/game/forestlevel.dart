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

class ForestLevel extends FlameGame {
  late SpriteComponent background;
  late RoundedRectangleComponent bottomRectangle;
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration? totalDuration;
  late DialogueBoxComponent dialogueBox;
  late SpriteComponent molly;
  late FlutterTts tts;
  SpriteComponent? animalImage;
  bool isGameStarted = false;
  bool firstAttemptMade = false;
  String? firstAttemptAnimal;
  int retryCount = 0;
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
  AnimalRectangle? selectedRectangle;

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

    bottomRectangle = RoundedRectangleComponent(
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

    dialogueBox = DialogueBoxComponent(
      position: Vector2(130, 70),
      size: Vector2(size.x - 150, 120),
      text:
          "Listen to the sounds and tap the correct name to reveal them. Let's start!",
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
      add(AnimalRectangle(
        position: Vector2(30 + i * (rectangleWidth + 15), firstRowY),
        size: Vector2(rectangleWidth, rectangleHeight),
        text: selectedNamesList[i],
        onTapCallback: onRectangleTap,
      ));
    }

    for (int i = 0; i < 2; i++) {
      add(AnimalRectangle(
        position: Vector2(70 + i * (rectangleWidth + 20), secondRowY),
        size: Vector2(rectangleWidth, rectangleHeight),
        text: selectedNamesList[i + 3],
        onTapCallback: onRectangleTap,
      ));
    }
  }

  void onRectangleTap(AnimalRectangle rectangle) async {
    if (!firstAttemptMade) {
      firstAttemptMade = true;
      firstAttemptAnimal = rectangle.text; 
    }
    retryCount++;
    if (selectedRectangle != null && selectedRectangle != rectangle) {
      selectedRectangle!.unselect();
    }

    selectedRectangle = rectangle;
    rectangle.select();

    if (rectangle.text == correctAnimal) {
      roundData.add({
        'correctAnimal': correctAnimal,
        'firstAttempt': firstAttemptAnimal,
        'retryCount': retryCount,
      });
      debugPrint('Round Data: $roundData');
      
      retryCount = 0; 
      firstAttemptMade = false;
      showAnimalImage(correctAnimal!);
      await tts.speak("Congratulations! You found the $correctAnimal!");
      onTaskCompleted();
    } else {
      removeAnimalImage();
      await tts.speak("Try again! That's not the right animal.");
    }
  }
  void onTaskCompleted() async {
  
  await tts.speak("Great job! Let's continue our journey.");

  
  Future.delayed(const Duration(seconds: 3), () {
    Navigator.of(buildContext!).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameWidget(game: Afterforestlevel()),
      ),
    );
  });
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
}

class AnimalRectangle extends PositionComponent with TapCallbacks {
  final String text;
  final Function(AnimalRectangle) onTapCallback;
  bool isSelected = false;
  late RoundedRectangleComponent background;
  late TextComponent textComponent;

  AnimalRectangle({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    required this.onTapCallback,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    background = RoundedRectangleComponent(
      position: Vector2.zero(),
      size: size,
      color: const Color(0xFF90EE90).withOpacity(0.8),
      borderRadius: 15,
    );
    add(background);

    textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(
        size.x / 2 - text.length * 4.5,
        size.y / 4,
      ),
    );
    add(textComponent);
  }

  void select() {
    isSelected = true;

    background.paint.color = const Color(0xFF007BFF).withOpacity(0.8);
    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void unselect() {
    isSelected = false;

    background.paint.color = const Color(0xFF90EE90).withOpacity(0.8);
    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapCallback(this);
  }
}

class AudioPlayerUI extends PositionComponent with TapCallbacks {
  final AudioPlayer audioPlayer;
  final Duration totalDuration;
  Duration currentDuration = Duration.zero;

  AudioPlayerUI({
    required Vector2 position,
    required Vector2 size,
    required this.audioPlayer,
    required this.totalDuration,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    audioPlayer.positionStream.listen((position) {
      currentDuration = position;
    });

    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer.seek(Duration.zero);
        audioPlayer.stop();
        currentDuration = Duration.zero;
      }
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Paint backgroundPaint = Paint()
      ..color = const Color(0xFFE6E6FA).withOpacity(0.9);
    final RRect backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y - 20),
      Radius.circular(15),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    final double buttonSize = 25;
    final double sliderHeight = 8;
    final double circleVerticalOffset = size.y / 4;
    final Paint playButtonPaint = Paint()..color = Colors.green;

    canvas.drawCircle(
      Offset(30, circleVerticalOffset),
      buttonSize / 2,
      playButtonPaint,
    );

    final path = Path()
      ..moveTo(25, circleVerticalOffset - 8)
      ..lineTo(35, circleVerticalOffset)
      ..lineTo(25, circleVerticalOffset + 8)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);

    final Paint sliderBackgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4);
    canvas.drawRect(
      Rect.fromLTWH(70, circleVerticalOffset - sliderHeight / 2, size.x - 140,
          sliderHeight),
      sliderBackgroundPaint,
    );

    final Paint sliderProgressPaint = Paint()..color = Colors.green;
    double progress = totalDuration.inMilliseconds > 0
        ? (currentDuration.inMilliseconds / totalDuration.inMilliseconds) *
            (size.x - 140)
        : 0;
    canvas.drawRect(
      Rect.fromLTWH(
          70, circleVerticalOffset - sliderHeight / 2, progress, sliderHeight),
      sliderProgressPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text:
            '${formatDuration(currentDuration)} / ${formatDuration(totalDuration)}',
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(190, circleVerticalOffset + 10));
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play().catchError((error) {
        print('Error playing audio: $error');
      });
    }
  }
}

class RoundedRectangleComponent extends PositionComponent {
  final Paint paint;
  final double borderRadius;

  RoundedRectangleComponent({
    required Vector2 position,
    required Vector2 size,
    required Color color,
    this.borderRadius = 0,
  })  : paint = Paint()..color = color,
        super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);
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
