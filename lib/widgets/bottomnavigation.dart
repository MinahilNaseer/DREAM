import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0), // Margin for spacing from screen edges
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // Padding inside the container
      decoration: BoxDecoration(
        color: const Color.fromARGB(71, 142, 31, 161), // Background color of the box
        borderRadius: BorderRadius.circular(30), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // Shadow effect
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Button
          GestureDetector(
            onTap: () => onTap(0),
            child: _buildNavItem(
              icon: Icons.home_outlined,
              label: "Home",
              isSelected: currentIndex == 0,
            ),
          ),
          // Profile Button
          GestureDetector(
            onTap: () => onTap(1),
            child: _buildNavItem(
              icon: Icons.person_outline,
              label: "Profile",
              isSelected: currentIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  // Method to build each navigation item with an icon and label
  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30,
          color: isSelected ? Color(0xFF0D47A1) : Colors.white70, // Active or inactive color
        ),
        const SizedBox(width: 8), // Spacing between the icon and label
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFF0D47A1) : Colors.white70, // Active or inactive color
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold for active label
          ),
        ),
      ],
    );
  }
}
