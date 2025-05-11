import 'package:dream/game/afterfishlevel.dart';
import 'package:dream/game/forestlevel.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:dream/game/afterforestlevel.dart';

class GameNavigator {
 static void switchToInitialScene(
    BuildContext context, Map<String, dynamic> childData) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => GameWidget(
        game: Afterfishlevel(childData: childData),
      ),
    ),
  );
}

}

