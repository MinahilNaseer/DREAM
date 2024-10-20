import 'dart:ui' as ui; 
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/input.dart';

import '../game/fishinglevel.dart'; 

class ScenicGame extends FlameGame with TapCallbacks {
  late SpriteComponent kidOnCycle;
  late ParallaxComponent parallaxComponent;
  late SpriteComponent road1, road2;
  late SpriteComponent grass1, grass2;
  late SpriteComponent pond;
  late ui.Image handIconImage; 

  bool isMoving = false;
  bool showPrompt = true; 
  final double speed = 100;
  bool hasPondPassed = false;
  bool isSceneSwitched = false;
  late Timer pondTimer;
  bool pondAdded = false;

  
  double handIconOffset = 0; 
  double handIconDirection = 1; 
  final double handIconMaxOffset = 5; 
  final double handIconSpeed = 0.05; 

  @override
  Future<void> onLoad() async {
    
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

    
    pondTimer = Timer(2, onTick: () {
      if (!pondAdded) {
        addPond();
      }
    });

    
    kidOnCycle = SpriteComponent()
      ..sprite = await loadSprite('kid-cycle.png')
      ..size = Vector2(180, 180)
      ..position = Vector2(10, size.y - size.y * 0.18 - 100);
    add(kidOnCycle);

    //print("Parallax, road, grass, and kid on cycle added.");

    
    handIconImage = await images.load('hand-icon.png'); 
  }

  Future<void> addPond() async {
    
    pond = SpriteComponent()
      ..sprite = await loadSprite('pond-fish.png')
      ..size = Vector2(220, 220)
      ..position = Vector2(size.x + 50, size.y - size.y * 0.28 - 100);
    add(pond);
    pondAdded = true;
    add(kidOnCycle); 
    //print("Pond added after 2 seconds, sliding onto the screen.");
  }

  @override
  void update(double dt) {
    super.update(dt);

    
    if (isMoving) {
      pondTimer.update(dt); 

      
      moveComponent(road1, road2, speed * dt);
      moveComponent(road2, road1, speed * dt);
      moveComponent(grass1, grass2, speed * dt);
      moveComponent(grass2, grass1, speed * dt);

      
      parallaxComponent.parallax!.baseVelocity = Vector2(speed, 0);

      if (pondAdded && !hasPondPassed) {
        pond.position.x -= speed * dt;

        
        if ((pond.position.x - kidOnCycle.position.x).abs() < 10) {
          //print("Kid and pond are parallel. Stopping everything.");
          isMoving = false; 
          parallaxComponent.parallax!.baseVelocity =
              Vector2.zero(); 

          switchToNewScene(); 
        }

        if (pond.position.x + pond.size.x <= 0) {
          hasPondPassed = true;
          remove(pond); 
          //print("Pond has moved off the screen and is removed.");
        }
      }
    }

    
    handIconOffset += handIconDirection * handIconSpeed;
    if (handIconOffset >= handIconMaxOffset || handIconOffset <= -handIconMaxOffset) {
      handIconDirection *= -1; 
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

  @override
  void onTapDown(TapDownEvent event) {
    if (showPrompt) {
      showPrompt = false; 
    } else {
      isMoving = true; 
      //print("Screen tapped, starting movement.");
    }
  }

  
  void switchToNewScene() {
    removeAll([
      road1,
      road2,
      grass1,
      grass2,
      kidOnCycle,
      pond,
      parallaxComponent
    ]); 

    final newScene = Fishinglevel();
    add(newScene); 
    //print("Switched to the new scene.");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (showPrompt) {
      
      final paint = Paint()
        ..color = const Color.fromARGB(255, 175, 116, 6).withOpacity(0.7);
      final rect =
          Rect.fromLTWH(size.x * 0.1, size.y * 0.2, size.x * 0.8, size.y * 0.2);
      final rrect = RRect.fromRectAndRadius(
          rect, const Radius.circular(20)); 
      canvas.drawRRect(rrect, paint); 

      
      final textStyle = TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);
      final textSpan = TextSpan(
        text: "Tap anywhere to start your adventure!",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.x * 0.7);
      textPainter.paint(canvas, Offset(size.x * 0.15, size.y * 0.3));

      
      final handIconSize = 70; 
      final handIconPosition = Offset(size.x * 0.5 - handIconSize / 2 + handIconOffset, size.y * 0.21); 
     
      
      final paintImage = Paint();
      canvas.drawImageRect(
        handIconImage,
        Rect.fromLTWH(0, 0, handIconImage.width.toDouble(), handIconImage.height.toDouble()), 
        Rect.fromLTWH(handIconPosition.dx, handIconPosition.dy, handIconSize.toDouble(), handIconSize.toDouble()), 
        paintImage,
      );

      
      final closeButtonSize = 40.0; 
      final closeButtonRect = Rect.fromLTWH(
          size.x * 0.85, size.y * 0.2, closeButtonSize, closeButtonSize);
      final closeButtonPaint = Paint()
        ..color = Colors.white; 
      canvas.drawCircle(
        Offset(closeButtonRect.center.dx, closeButtonRect.center.dy),
        closeButtonSize / 2, 
        closeButtonPaint,
      );

      
      final closeTextStyle = TextStyle(
          color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold);
      final closeTextSpan = TextSpan(text: "X", style: closeTextStyle);
      final closeTextPainter = TextPainter(
        text: closeTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      closeTextPainter.layout(minWidth: 0, maxWidth: closeButtonSize);

      
      closeTextPainter.paint(
        canvas,
        Offset(
          closeButtonRect.center.dx - closeTextPainter.width / 2,
          closeButtonRect.center.dy - closeTextPainter.height / 2,
        ),
      );
    }
  }
}
