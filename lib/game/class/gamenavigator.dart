import 'package:dream/game/afterfishlevel.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameNavigator {
  static void switchToInitialScene(BuildContext context, FlameGame game) {
    
    Navigator.of(context).pop();
    
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameWidget(game: Afterfishlevel())),
    );
  }
}
