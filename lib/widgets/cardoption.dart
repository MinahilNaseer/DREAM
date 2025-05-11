import 'package:flutter/material.dart';


class CardOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const CardOption({
    required this.text,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: isSelected ? selectedColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        color: isSelected ? selectedColor : Colors.white,
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}