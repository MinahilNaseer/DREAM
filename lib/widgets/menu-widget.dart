import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final String level;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradientColors;

  const LevelCard({
    Key? key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, 
      children: [
        Container(
          width: double.infinity, 
          height: 120, 
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 100.0), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow, 
                    size: 24, 
                    color: Colors.white, 
                  ),
                ),
                const SizedBox(height: 10), 
                
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Positioned(
          right: 0, 
          top: -30,  
          child: SizedBox(
            height: 120,
            width: 150,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain, 
            ),
          ),
        ),
      ],
    );
  }
}
