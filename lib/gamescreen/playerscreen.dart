import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/player-background.png',  // Add your background image
              fit: BoxFit.fill,
            ),
          ),
          // Cloud Sticker Image with "Player Selection" text inside it
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,  // Adjusted to center the cloud and text
            
            child: Stack(
              alignment: Alignment.center,  // Aligning the text in the center of the cloud
              children: [
                Image.asset(
                  'assets/images/cloud-sticker.png', 
                  width: 400, // Your cloud sticker image
                  height: 400,  // Increased the size to accommodate text
                ),
                // Title "Player Selection" inside the cloud image
                Text(
                  'Player\nSelection',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontSize: 40,  // Bigger font size
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,  // Soft yellow/golden color
                      letterSpacing: 2,  // Slight letter spacing
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.yellowAccent.withOpacity(0.8),  // Glow effect
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          blurRadius: 30.0,
                          color: Colors.yellowAccent.withOpacity(0.5),  // Outer glow effect
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Player Selection Buttons
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Female Player Option
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for female player selection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),  // Softer background color for princess
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/girl-character.png',  // Female player image/icon
                        height: 120,
                      ),
                      const Text(
                        'Princess',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Male Player Option
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for male player selection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent.withOpacity(0.8),  // Softer background color for knight
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/knight-character.png',  // Male player image/icon
                        height: 120,
                      ),
                      const Text(
                        'Knight',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
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