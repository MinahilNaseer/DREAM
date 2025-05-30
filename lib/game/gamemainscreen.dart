import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import '../game/scenicgame.dart';

class GameMainScreen extends StatefulWidget {
  final Map<String, dynamic> childData;

  const GameMainScreen({Key? key, required this.childData}) : super(key: key);

  @override
  _GameMainScreenState createState() => _GameMainScreenState();
}

class _GameMainScreenState extends State<GameMainScreen> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _playWelcomeMessage();
  }

  
  void _initializeTTS() {
    _flutterTts = FlutterTts();

    
    _flutterTts.setLanguage("en-US"); 
    _flutterTts.setPitch(1.5); 
    _flutterTts.setSpeechRate(0.4); 
  }

  
  void _playWelcomeMessage() async {
    await _flutterTts.speak(
      "Welcome to Dream Quest! Get ready for an amazing adventure! Tap start to begin your journey, solve puzzles, and find hidden treasures. Let the fun begin!",
    );
  }

  @override
  void dispose() {
    _flutterTts.stop(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/play/game-background.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/game_logo.png',
                  height: 300,
                  width: 300,
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  color: const Color(0xFF0D47A1),
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
                children: const [
                  TextSpan(
                    text: 'Get ready for a fun adventure! Tap ',
                  ),
                  TextSpan(
                    text: 'START',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DB6AC),
                    ),
                  ),
                  TextSpan(
                    text:
                        ' to begin your journey, solve puzzles, and find the hidden treasure!',
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameWidget(game: ScenicGame(childData: widget.childData)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: const Color(0xFF4DB6AC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: const Color(0xFFFFAB91),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'EXIT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
