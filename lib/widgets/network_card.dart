import 'package:flutter/material.dart';
import 'package:lab_monitor/widgets/progress_card.dart';

class NetworkCard extends StatelessWidget {
  final double networkIn;
  final double networkOut;
  
  const NetworkCard({
    Key? key,
    required this.networkIn,
    required this.networkOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate average network usage and normalize to percentage out of 100
    double networkAverage = (networkIn + networkOut) / 2;
    double networkPercentage = (networkAverage / 200) * 100; // Convert to percentage out of 100

    return ProgressCard(
      title: "Network Usage",
      value: networkPercentage,
      maxValue: 100,
      color: Colors.orange,
      icon: Icons.network_check,
    );
  }
}