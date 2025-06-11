import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final double value;
  final double maxValue;
  final Color color;
  final IconData icon;
  final bool isInteger;

  const ProgressCard({
    Key? key,
    required this.title,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
    this.isInteger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child:Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Text and Progress Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: value / maxValue,
                    color: color,
                    backgroundColor: color.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isInteger 
                      ? "${value.toInt()} / ${maxValue.toInt()}" // Display as integer
                      : "${value.toStringAsFixed(1)}% / ${maxValue.toStringAsFixed(0)}%", // Display as percentage
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}