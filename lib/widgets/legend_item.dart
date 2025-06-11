import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double graphSize;

  const LegendItem({
    Key? key,
    required this.color,
    required this.label,
    required this.graphSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: graphSize * 0.03,
          height: graphSize * 0.03,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: graphSize * 0.01),
        Text(
          label,
          style: TextStyle(
            fontSize: graphSize * 0.035, // Increased from 0.025
            fontWeight: FontWeight.w300, // Added medium weight
            color: Colors.black87, // Made text color darker
          ),
        ),
      ],
    );
  }
}