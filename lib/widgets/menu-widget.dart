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
      clipBehavior: Clip.none, // Allows the image to overflow outside the container
      children: [
        Container(
          width: double.infinity, // Full width to keep the card size consistent
          height: 120, // Constant height for all cards
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Image positioned on top of the container (overflowing it)
        Positioned(
          right: 0, // Adjust this value to fine-tune the exact position
          top: -30,  // Move the image above the container
          child: Image.asset(
            imageUrl,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
