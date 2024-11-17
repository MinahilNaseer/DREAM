import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flame/events.dart';
import 'dart:math';

class ForestLevel extends FlameGame {
  late SpriteComponent background; // Background image component
  late RoundedRectangleComponent bottomRectangle; // Rounded rectangle component
  final AudioPlayer audioPlayer = AudioPlayer(); // Audio player instance
  Duration? totalDuration;

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
  AnimalRectangle? selectedRectangle;

  @override
  Future<void> onLoad() async {
    // Load the forest level background
    background = SpriteComponent()
      ..sprite = await loadSprite(
          'forest-animal-bg1.jpg') // Replace with the uploaded image name
      ..size = size // Full-screen background
      ..position = Vector2.zero(); // Positioned at the top-left corner
    add(background);

    // Add a custom rounded rectangle at the bottom of the screen
    bottomRectangle = RoundedRectangleComponent(
      position: Vector2(20, size.y - 260), // Padding from the bottom and sides
      size: Vector2(
          size.x - 40, 240), // Adjusted height to accommodate larger components
      color:
          const Color(0xFFADD8E6).withOpacity(0.7), // Light blue with opacity
      borderRadius: 25, // Rounded corners with a radius of 25 pixels
    );
    add(bottomRectangle);

    // Select a random audio file
    final audioFiles = [
      'Cow-1.mp3','Cow-2.mp3',
      'Dog-1.mp3','Dog-2.mp3',
      'Cat-1.mp3','Cat-2.mp3','Cat-3.mp3',
      'Sheep-1.mp3',
      'Lion-1.mp3',
      'Goat-1.mp3',
      'Horse-1.mp3','Horse-2.mp3',
      'Pig-1.mp3',
      'Rooster-1.mp3','Rooster-2.mp3'
    ];
    final selectedAudio = audioFiles[random.nextInt(audioFiles.length)];
    final audioName =
        selectedAudio.split('-')[0]; // Get the first part of the name

    // Load the selected audio and set total duration
    try {
      await audioPlayer.setAsset(
          'assets/audio/$selectedAudio'); // Replace with your sound file
      totalDuration =
          await audioPlayer.load(); // Get the total duration of the audio
    } catch (error) {
      print('Error loading audio: $error');
    }

    // Add an audio player UI component with reduced size
    add(AudioPlayerUI(
      position: Vector2(40, size.y - 230), // Positioned higher
      size: Vector2(size.x - 80, 60), // Reduced height for the audio player
      audioPlayer: audioPlayer,
      totalDuration: totalDuration ?? Duration.zero,
    ));

    // Prepare 5 unique animal names, including the name derived from the audio
    final selectedNames = <String>{
      audioName
    }; // Start with the name from the audio
    while (selectedNames.length < 5) {
      selectedNames.add(animalNames[random.nextInt(animalNames.length)]);
    }
    final selectedNamesList = selectedNames.toList()..shuffle();

    // Add animal name rectangles below the audio player, inside the rounded rectangle
    final double rectangleWidth =
        (size.x - 100) / 3; // Space for three rectangles in the first row
    // Adjusted height for the rectangles
    final double rectangleHeight = 40; // Increased rectangle height
    final double firstRowY =
        size.y - 160; // Adjusted position for the first row
    final double secondRowY =
        size.y - 100; // Adjusted position for the second row

// First row: 3 rectangles
    for (int i = 0; i < 3; i++) {
      add(AnimalRectangle(
        position: Vector2(30 + i * (rectangleWidth + 15), firstRowY),
        size: Vector2(rectangleWidth, rectangleHeight),
        text: selectedNamesList[i],
        onTapCallback: onRectangleTap,
      ));
    }

// Second row: 2 rectangles
    for (int i = 0; i < 2; i++) {
      add(AnimalRectangle(
        position: Vector2(70 + i * (rectangleWidth + 20), secondRowY),
        size: Vector2(rectangleWidth, rectangleHeight),
        text: selectedNamesList[i + 3],
        onTapCallback: onRectangleTap,
      ));
    }
  }

  void onRectangleTap(AnimalRectangle rectangle) {
    // Unselect the currently selected rectangle, if any
    if (selectedRectangle != null && selectedRectangle != rectangle) {
      selectedRectangle!.unselect();
    }

    // Select the new rectangle
    selectedRectangle = rectangle;
    rectangle.select();
  }

  @override
  void onRemove() {
    super.onRemove();
    audioPlayer
        .dispose(); // Dispose of the audio player when the game is removed
  }
}

class AnimalRectangle extends PositionComponent with TapCallbacks {
  final String text;
  final Function(AnimalRectangle) onTapCallback; // Callback for when tapped
  bool isSelected = false; // State to track selection
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
    // Add rectangle background with rounded corners
    background = RoundedRectangleComponent(
      position: Vector2.zero(),
      size: size,
      color: const Color(0xFF90EE90).withOpacity(0.8), // Light green background
      borderRadius: 15, // Rounded corners
    );
    add(background);

    // Add text component
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
        size.x / 2 - text.length * 4.5, // Center horizontally
        size.y / 4, // Adjusted vertical centering for increased height
      ),
    );
    add(textComponent);
  }

  void select() {
    isSelected = true;

    // Change background and text color for selection
    background.paint.color =
        const Color(0xFF007BFF).withOpacity(0.8); // Blue background
    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white, // White text
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void unselect() {
    isSelected = false;

    // Reset background and text color
    background.paint.color =
        const Color(0xFF90EE90).withOpacity(0.8); // Default green
    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.black, // Black text
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapCallback(this); // Notify parent of the tap
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
    // Listen for audio position updates
    audioPlayer.positionStream.listen((position) {
      currentDuration = position;
    });

    // Listen for the audio completion and reset to zero
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer.seek(Duration.zero); // Reset to the start
        audioPlayer.stop(); // Ensure the playback stops
        currentDuration = Duration.zero; // Reset the current duration
      }
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the background for the audio player
    final Paint backgroundPaint = Paint()
      ..color =
          const Color(0xFFE6E6FA).withOpacity(0.9); // Lavender with opacity
    final RRect backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y - 20), // Adjusted to the reduced size
      Radius.circular(15),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    final double buttonSize = 25; // Reduced circle size
    final double sliderHeight = 8; // Reduced slider height
    final double circleVerticalOffset =
        size.y / 4; // Align with slider vertically
    final Paint playButtonPaint = Paint()..color = Colors.green;

    // Draw a circular play button
    canvas.drawCircle(
      Offset(30,
          circleVerticalOffset), // Adjusted to align with the slider progress
      buttonSize / 2,
      playButtonPaint,
    );

    // Draw a play triangle icon (properly centered inside the circle)
    final path = Path()
      ..moveTo(25, circleVerticalOffset - 8) // Top point of the triangle
      ..lineTo(35, circleVerticalOffset) // Right point of the triangle
      ..lineTo(25, circleVerticalOffset + 8) // Bottom point of the triangle
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);

    // Draw the slider background
    final Paint sliderBackgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4);
    canvas.drawRect(
      Rect.fromLTWH(70, circleVerticalOffset - sliderHeight / 2, size.x - 140,
          sliderHeight),
      sliderBackgroundPaint,
    );

    // Draw the slider progress
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

    // Draw the current duration text
    final textPainter = TextPainter(
      text: TextSpan(
        text:
            '${formatDuration(currentDuration)} / ${formatDuration(totalDuration)}',
        style: const TextStyle(
            color: Colors.black, fontSize: 14), // Slightly larger text
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
    // Toggle play and pause on tap
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
