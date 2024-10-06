import 'package:flutter/material.dart';

class GameMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
                // Shrinking the background slightly
              child: Image.asset(
                'assets/images/mobile_game_initial_back.png',  // Replace with your image path
                fit: BoxFit.fill,
                //opacity:,  // Ensures the image is smaller to allow visibility for other elements
              ),
            ),
          ),
          // Game Title Logo
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,  // Adjusted for better visibility
            left: MediaQuery.of(context).size.width * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: Column(
              children: [
                Text(
                  'A Magical Journey to Find the Treasure',
                  style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFFFFAB91),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'assets/icons/DREAM_Quest_logo.png',  // Your logo path
                  height: 400,  // Adjust the size of the logo as needed
                ),
                
                // Additional Text below logo
                
              ],
            ),
          ),
          // Buttons Row (Start and Exit)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start Button
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to start the game
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: Color(0xFF4DB6AC),  // Soft turquoise color matching the theme
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'START',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 30),  // Space between the buttons
                // Exit Button
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to exit the game
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: Color(0xFFFFAB91),  // Soft coral color matching the logo's warm colors
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
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
