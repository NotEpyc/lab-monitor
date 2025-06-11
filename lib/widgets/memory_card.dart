import 'package:flutter/material.dart';
import 'package:lab_monitor/widgets/progress_card.dart';

class MemoryCard extends StatelessWidget {
  final double memoryUsage;
  
  const MemoryCard({
    Key? key,
    required this.memoryUsage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressCard(
      title: "Average Memory Usage",
      value: memoryUsage,
      maxValue: 100,
      color: Colors.blue,
      icon: Icons.storage,
    );
  }
}