import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const NavItem({
    Key? key,
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 72, 73, 176);
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          onTap(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          // Moderate width and height for the icon container
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey.shade50,
            shape: BoxShape.circle,
            boxShadow: isSelected ? [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ] : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              // Moderate icon size
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}