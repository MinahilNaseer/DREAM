import 'dart:ui' as ui;
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

class Afterfishlevel extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  SpriteComponent? forestScene;

  late SpriteComponent molly;
  late speechbox.DialogueBoxComponent dialogueBox;
  late TextComponent forestTitle;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late FlutterTts _flutterTts;

  bool isMoving = false;
  final double speed = 100;
  final double cycleSpeed = 70;
  bool isPondRemoved = false;
  late Timer forestSceneTimer;
  bool isAudioPlayed = false;
  late AudioPlayer _bicycleSoundPlayer;
  bool isBicycleSoundPlaying = false;

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

    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(220, 220)
      ..position = Vector2(size.x - 500, size.y - size.y * 0.28 + 20);
    add(pond);

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

    forestSceneTimer = Timer(3.0, onTick: () async {
      if (forestScene == null) {
        forestScene = SpriteComponent()
          ..sprite = await loadSprite('trees-scene.png')
          ..size = Vector2(350, 350)
          ..position = Vector2(size.x + 50, size.y - size.y * 0.28 - 70);
        add(forestScene!);
        forestTitle = TextComponent(
          text: "Whispering\nForest",
          position: Vector2(
              forestScene!.position.x + forestScene!.size.x / 3 + 50,
              forestScene!.position.y - 100),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: ui.Color.fromARGB(255, 163, 170, 62),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        add(forestTitle);

        if (!isAudioPlayed) {
          await _audioPlayer
              .play(AssetSource('audio/forest-wind-and-birds.mp3'));
          isAudioPlayed = true;
        }
      }
    });

    forestSceneTimer.start();
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

      forestSceneTimer.update(dt);

      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      if (!isPondRemoved) {
        pond.position.x -= speed * dt;

        if (pond.position.x + pond.size.x < 0) {
          if (pond.parent != null) remove(pond);
          isPondRemoved = true;

          await _flutterTts.speak(
              "Watch out! There’s a mysterious forest ahead.");
        }
      }

      if (forestScene != null) {
        forestScene!.position.x -= speed * dt;

        if (forestTitle != null) {
          forestTitle.position.x =
              forestScene!.position.x + forestScene!.size.x / 2 - 140;
        }

        if ((forestScene!.position.x - kidOnCycle.position.x).abs() < 100) {
          isMoving = false;
          stopBicycleSound();
          parallaxComponent.parallax!.baseVelocity = Vector2.zero();

          molly.sprite = await loadSprite('girl-idea.png');
          molly.position = Vector2(10, size.y * 0.1);
          add(molly);

          dialogueBox = speechbox.DialogueBoxComponent(
            position: Vector2(size.x * 0.35, size.y * 0.1),
            size: Vector2(size.x * 0.6, size.y * 0.15),
            text: "We’ve made it to the Whispering Forest!",
          );
          add(dialogueBox);

          await _flutterTts.speak(
              "We’ve made it to the Whispering Forest! Let's see what's stopping us from crossing the forest");

          
          Future.delayed(const Duration(seconds: 6), () async {
            isAudioPlayed = false;
            await _audioPlayer.stop();
            await _flutterTts.stop(); 
            switchToNewScene(buildContext!);
          });
        }
      }
    }else{
      stopBicycleSound();
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

  void switchToNewScene(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameWidget(game: ForestLevel()),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _flutterTts.stop();

    isMoving = true;
  }
}
