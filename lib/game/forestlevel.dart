import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flame/events.dart';

class ForestLevel extends FlameGame {
  late SpriteComponent background; // Background image component
  late RoundedRectangleComponent bottomRectangle; // Rounded rectangle component
  final AudioPlayer audioPlayer = AudioPlayer(); // Audio player instance
  Duration? totalDuration;

  @override
  Future<void> onLoad() async {
    // Load the forest level background
    background = SpriteComponent()
      ..sprite = await loadSprite('forest_scene_bg.png') // Replace with the uploaded image name
      ..size = size // Full-screen background
      ..position = Vector2.zero(); // Positioned at the top-left corner
    add(background);

    // Add a custom rounded rectangle at the bottom of the screen
    bottomRectangle = RoundedRectangleComponent(
      position: Vector2(20, size.y - 150), // Padding from the bottom and sides
      size: Vector2(size.x - 40, 100), // Reduced height for the rectangle
      color: const Color(0xFFADD8E6).withOpacity(0.7), // Light blue with opacity
      borderRadius: 25, // Rounded corners with a radius of 25 pixels
    );
    add(bottomRectangle);

    // Load the audio and set total duration
    try {
      await audioPlayer.setAsset('assets/audio/cow-moo-1.mp3');
 // Replace with your sound file
      totalDuration = await audioPlayer.load(); // Get the total duration of the audio
    } catch (error) {
      print('Error loading audio: $error');
    }

    // Add an audio player UI component
    add(AudioPlayerUI(
      position: Vector2(40, size.y - 140),
      size: Vector2(size.x - 80, 80), // Adjusted size for smaller background
      audioPlayer: audioPlayer,
      totalDuration: totalDuration ?? Duration.zero,
    ));
  }

  @override
  void onRemove() {
    super.onRemove();
    audioPlayer.dispose(); // Dispose of the audio player when the game is removed
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
    final Paint backgroundPaint = Paint()..color = const Color(0xFFE6E6FA).withOpacity(0.9); // Lavender with opacity
    final RRect backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y - 20), // Reduced height
      Radius.circular(15),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    final double buttonSize = 30; // Circle size
    final double sliderHeight = 10; // Slider height
    final double circleVerticalOffset = size.y / 3; // Align with slider vertically
    final Paint playButtonPaint = Paint()..color = Colors.green;

    // Draw a circular play button
    canvas.drawCircle(
      Offset(40, circleVerticalOffset), // Adjusted to align with the slider progress
      buttonSize / 2,
      playButtonPaint,
    );

    // Draw a play triangle icon (properly centered inside the circle)
    final path = Path()
      ..moveTo(35, circleVerticalOffset - 10) // Top point of the triangle
      ..lineTo(45, circleVerticalOffset) // Right point of the triangle
      ..lineTo(35, circleVerticalOffset + 10) // Bottom point of the triangle
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);

    // Draw the slider background
    final Paint sliderBackgroundPaint = Paint()..color = Colors.grey.withOpacity(0.4);
    canvas.drawRect(
      Rect.fromLTWH(80, circleVerticalOffset - sliderHeight / 2, size.x - 140, sliderHeight),
      sliderBackgroundPaint,
    );

    // Draw the slider progress
    final Paint sliderProgressPaint = Paint()..color = Colors.green;
    double progress = totalDuration.inMilliseconds > 0
        ? (currentDuration.inMilliseconds / totalDuration.inMilliseconds) * (size.x - 140)
        : 0;
    canvas.drawRect(
      Rect.fromLTWH(80, circleVerticalOffset - sliderHeight / 2, progress, sliderHeight),
      sliderProgressPaint,
    );

    // Draw the current duration text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${formatDuration(currentDuration)} / ${formatDuration(totalDuration)}',
        style: const TextStyle(color: Colors.black, fontSize: 12),
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
