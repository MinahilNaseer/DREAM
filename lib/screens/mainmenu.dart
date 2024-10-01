import 'package:flutter/material.dart';
import '../widgets/menu-widget.dart'; // Import the widget

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Upper part with user information, taking 25% of screen height
            Container(
              height: MediaQuery.of(context).size.height * 0.25, // 25% of screen height
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Hi Akshay",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1), // Dark blue text for better contrast
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "5 Years old",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D47A1), // Dark blue text for contrast
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Lower container that starts right below the upper part
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3), // Soft grey for container
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Main Menu",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // First level card
                      LevelCard(
                        level: "Level 1",
                        title: "Travel newbie",
                        imageUrl: "assets/images/math-problem.png", // Local image asset
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(height: 20),
                      // Second level card
                      LevelCard(
                        level: "Level 2",
                        title: "Continuing",
                        imageUrl: "assets/images/writing-girl.png", // Local image asset
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      // Third level card
                      LevelCard(
                        level: "Level 3",
                        title: "Experienced",
                        imageUrl: "assets/images/kids-playing-game.png", // Local image asset
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
