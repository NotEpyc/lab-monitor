import 'package:flutter/material.dart';
import 'package:lab_monitor/widgets/progress_card.dart';

class CpuCard extends StatelessWidget {
  final double cpuUsage;
  
  const CpuCard({
    Key? key,
    required this.cpuUsage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressCard(
      title: "Average CPU Usage",
      value: cpuUsage,
      maxValue: 100,
      color: Colors.red,
      icon: Icons.memory,
    );
  }
}