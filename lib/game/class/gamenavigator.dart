import 'package:dream/game/afterfishlevel.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameNavigator {
  static void switchToInitialScene(BuildContext context, FlameGame game) {
    // Close the current game screen (optional)
    Navigator.of(context).pop();
    
    // Navigate to the Afterfishlevel
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameWidget(game: Afterfishlevel())),
    );
  }
}
