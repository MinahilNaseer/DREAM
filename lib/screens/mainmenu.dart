import 'package:flutter/material.dart';
import 'dart:math'; 

import '../widgets/bottomnavigation.dart';
import '../widgets/menu-widget.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true); 
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    
    if (index == 0) {
      
    } else if (index == 1) {
      
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            Stack(
              children: [
                
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          
                          Positioned(
                            left: _controller.value * MediaQuery.of(context).size.width * 0.7,
                            top: 50 + sin(_controller.value * 2 * pi) * 20,
                            child: Icon(Icons.edit, color: Colors.blueAccent.withOpacity(0.2), size: 40),
                          ),
                          
                          Positioned(
                            right: _controller.value * MediaQuery.of(context).size.width * 0.5,
                            top: 100 + cos(_controller.value * 2 * pi) * 30,
                            child: Icon(Icons.star, color: Colors.yellowAccent.withOpacity(0.3), size: 50),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25, 
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Welcome to ", 
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                                Text(
                              "DREAM!", 
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                              ],
                            ),
                            
                            SizedBox(height: 4),
                            Text(
                              "Let's start to detect learning challenges.", 
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      
                      Image.asset(
                        'assets/icons/icon_app.png', 
                        height: 140,
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
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
                  child: const SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Main Menu",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        SizedBox(height: 30),
                        
                        LevelCard(
                          level: "Level 1",
                          title: "Detect Dyscalculia: ",
                          subtitle: "Math Skill Challenges",
                          imageUrl: "assets/images/math-problem.png", 
                          gradientColors: [Colors.pinkAccent, Colors.orangeAccent],
                        ),
                        SizedBox(height: 30),
                        
                        LevelCard(
                          level: "Level 2",
                          title: "Detect Dysgraphia: ",
                          subtitle: "Writing Assessment",
                          imageUrl: "assets/images/writing-girl.png", 
                          gradientColors: [Colors.blueAccent, Colors.cyanAccent],
                        ),
                        SizedBox(height: 30),
                        
                        LevelCard(
                          level: "Level 3",
                          title: "Dyslexia Detection: ",
                          subtitle: "Interactive Game",
                          imageUrl: "assets/images/kids-playing-game.png", 
                          gradientColors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
      ),
    );
  }
}
