import 'package:flutter/material.dart';

class ProfileNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const ProfileNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navButton("Orders", 0),
          _navButton("Reservation", 1),
        ],
      ),
    );
  }

  Widget _navButton(String label, int index) {
    final isSelected = currentIndex == index;
    return TextButton(
      onPressed: () => onTabSelected(index),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.orange : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
