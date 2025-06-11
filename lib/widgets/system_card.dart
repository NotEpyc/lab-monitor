import 'package:flutter/material.dart';
import 'package:lab_monitor/widgets/progress_card.dart';

class SystemCard extends StatelessWidget {
  final int onlineSystems;
  
  const SystemCard({
    Key? key,
    required this.onlineSystems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressCard(
      title: "Online Systems",
      value: onlineSystems.toDouble(),
      maxValue: 68,
      color: Colors.green,
      icon: Icons.computer,
      isInteger: true,
    );
  }
}