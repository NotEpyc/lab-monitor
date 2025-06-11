import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For formatting time
import 'legend_item.dart'; // Add this import

class SystemUsageGraph extends StatefulWidget {
  final List<FlSpot> cpuSpots;
  final List<FlSpot> memorySpots;
  final List<FlSpot> networkUsageSpots;

  const SystemUsageGraph({
    Key? key,
    required this.cpuSpots,
    required this.memorySpots,
    required this.networkUsageSpots,
  }) : super(key: key);

  @override
  State<SystemUsageGraph> createState() => _SystemUsageGraphState();
}

class _SystemUsageGraphState extends State<SystemUsageGraph> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<FlSpot> filterDataPoints(List<FlSpot> spots) {
    final now = DateTime.now();
    final maxX = 3.0; // End of the graph (current hour)

    // Filter out points beyond the current hour
    return spots.where((spot) {
      final hour = now.subtract(Duration(hours: (maxX - spot.x).toInt()));
      return hour.isBefore(now.add(const Duration(minutes: 1))); // Include only up to the current hour
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Set the size of the graph to be square (1:1 aspect ratio)
    final graphSize = screenWidth * 0.8; // Adjust size as needed

    // Combine all spots to calculate minY and maxY dynamically (removed unused variable)

    double minY = 0;  // Always start at 0
    double maxY = 100;  // Always end at 100

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Existing graph SizedBox
          SizedBox(
            width: graphSize,
            height: graphSize * 0.9, // Reduced slightly to make room for legend
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: graphSize * 0.1,
                          getTitlesWidget: (value, meta) {
                            // Only show values at intervals of 20 from 0 to 100
                            if (value >= 0 && value <= 100 && value % 20 == 0) {
                              return Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  fontSize: graphSize * 0.03,
                                  color: Colors.black54,
                                ),
                              );
                            }
                            return const Text('');
                          },
                          interval: 20, // Fixed interval of 20
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide right titles
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 15, // Reduced from 20
                          getTitlesWidget: (value, meta) {
                            final now = DateTime.now();
                            final minX = 0.0; // Start of the graph (4 hours ago)
                            final maxX = 4.0; // Include the next hour in the bottom title

                            if (value < minX || value > maxX) {
                              return const Text(''); // Leave blank for out-of-range values
                            }

                            final hour = now.subtract(Duration(hours: (3 - value).toInt()));
                            final formattedTime = DateFormat('h a').format(hour);

                            return Padding(
                              padding: const EdgeInsets.only(top: 2.0), // Reduced from 5.0
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: graphSize * 0.025, // Slightly smaller font
                                  color: Colors.black54,
                                  fontStyle: FontStyle.normal, // Italic for next hour
                                ),
                              ),
                            );
                          },
                          interval: 1, // Ensure each value corresponds to a unique hour
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide top titles
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    gridData: FlGridData(
                      show: false, // Disable grid lines
                    ),
                    lineBarsData: [
                      // CPU Line (Darkest shade)
                      LineChartBarData(
                        spots: widget.cpuSpots.map((spot) {
                          return FlSpot(spot.x, spot.y * _animation.value);
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 0, 102, 255),  // Dark Blue
                            const Color.fromARGB(255, 0, 102, 255).withOpacity(0.7),
                          ],
                        ),
                        barWidth: graphSize * 0.005,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 0, 102, 255).withOpacity(0.3),
                              const Color.fromARGB(255, 0, 102, 255).withOpacity(0.0),
                            ],
                          ),
                        ),
                        dotData: FlDotData(show: false),
                      ),
                      // Memory Line (Medium shade)
                      LineChartBarData(
                        spots: widget.memorySpots.map((spot) {
                          return FlSpot(spot.x, spot.y * _animation.value);
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 0, 61, 122),  // Medium Blue
                            const Color.fromARGB(255, 0, 61, 122).withOpacity(0.7),
                          ],
                        ),
                        barWidth: graphSize * 0.005,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 0, 61, 122).withOpacity(0.3),
                              const Color.fromARGB(255, 0, 61, 122).withOpacity(0.0),
                            ],
                          ),
                        ),
                        dotData: FlDotData(show: false),
                      ),
                      // Network Usage Line (Lightest shade)
                      LineChartBarData(
                        spots: widget.networkUsageSpots.map((spot) {
                          return FlSpot(spot.x, spot.y * _animation.value);
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 100, 175, 237),  // Light Blue
                            const Color.fromARGB(255, 100, 175, 237).withOpacity(0.7),
                          ],
                        ),
                        barWidth: graphSize * 0.005,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 100, 175, 237).withOpacity(0.3),
                              const Color.fromARGB(255, 100, 175, 237).withOpacity(0.0),
                            ],
                          ),
                        ),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    minY: minY, // Set the minimum y-axis value
                    maxY: maxY, // Set the maximum y-axis value
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchSpotThreshold: 10, // Increase touch area for better usability
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toStringAsFixed(2)}%', // Format the value
                              TextStyle(
                                color: spot.bar.gradient?.colors.first ?? Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: barData.gradient?.colors.first ?? Colors.black,
                              strokeWidth: 2,
                              dashArray: [3, 3],
                            ),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6, // Hollow dot radius
                                  color: Colors.white, // Inner color
                                  strokeWidth: 3,
                                  strokeColor: barData.gradient?.colors.first ?? Colors.black, // Border color
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Legend
          Padding(
            padding: EdgeInsets.only(top: graphSize * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(
                  color: const Color.fromARGB(255, 0, 102, 255),
                  label: 'CPU Usage',
                  graphSize: graphSize,
                ),
                SizedBox(width: graphSize * 0.04),
                LegendItem(
                  color: const Color.fromARGB(255, 0, 61, 122),
                  label: 'Memory Usage',
                  graphSize: graphSize,
                ),
                SizedBox(width: graphSize * 0.04),
                LegendItem(
                  color: const Color.fromARGB(255, 100, 175, 237),
                  label: 'Network Usage',
                  graphSize: graphSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}