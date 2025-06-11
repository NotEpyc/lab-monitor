import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ResourceUsageGraph extends StatelessWidget {
  final List<FlSpot> cpuAverageSpots;
  final List<FlSpot> memoryAverageSpots;
  final List<FlSpot> networkInAverageSpots;
  final List<FlSpot> networkOutAverageSpots;
  final String selectedGraph;
  final Function(String) onGraphSelected;

  const ResourceUsageGraph({
    Key? key,
    required this.cpuAverageSpots,
    required this.memoryAverageSpots,
    required this.networkInAverageSpots,
    required this.networkOutAverageSpots,
    required this.selectedGraph,
    required this.onGraphSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cpuAverageSpots.isEmpty && memoryAverageSpots.isEmpty && 
        networkInAverageSpots.isEmpty && networkOutAverageSpots.isEmpty) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    // Determine which graph to display based on the selected button
    List<FlSpot> selectedSpots;
    Color graphColor;
    String graphTitle;

    // Example logic for selecting graph data
    switch (selectedGraph) {
      case "memory":
        selectedSpots = memoryAverageSpots;
        graphColor = Colors.green;
        graphTitle = "Average Memory Usage";
        break;
      case "network_in":
        selectedSpots = networkInAverageSpots;
        graphColor = Colors.blue;
        graphTitle = "Average Network In Traffic";
        break;
      case "network_out":
        selectedSpots = networkOutAverageSpots;
        graphColor = Colors.orange;
        graphTitle = "Average Network Out Traffic";
        break;
      case "cpu":
      default:
        selectedSpots = cpuAverageSpots;
        graphColor = Colors.red;
        graphTitle = "Average CPU Usage";
        break;
    }

    // Check if selectedSpots is empty
    if (selectedSpots.isEmpty) {
      return const Center(
        child: Text(
          "No data available for the selected graph",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    // Calculate the min and max values for the y-axis
    double minY = selectedSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = selectedSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    // Add padding to avoid congestion for the top-most and bottom-most numbers
    minY = (minY / 10).floor() * 10 - 10; // Add padding below the bottom-most number
    maxY = (maxY / 10).ceil() * 10 + 10;  // Add padding above the top-most number

    // Dynamically calculate the interval to ensure a maximum of 5 or 6 numbers
    double range = maxY - minY;
    double interval = (range / 5).ceilToDouble(); // Divide range into 5 intervals
    interval = (interval / 10).ceil() * 10; // Round up to the nearest multiple of 10

    // Ensure there are no more than 6 numbers
    while ((maxY - minY) / interval > 6) {
      interval += 10; // Increase the interval to reduce the number of labels
    }

    // Adjust maxY to ensure it aligns with the interval
    maxY = minY + (interval * 5); // Ensure there are exactly 5 intervals

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons on the left side
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => onGraphSelected("cpu"),
                  icon: Icon(Icons.memory, color: selectedGraph == "cpu" ? Colors.red : Colors.grey),
                  tooltip: "CPU",
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => onGraphSelected("memory"),
                  icon: Icon(Icons.storage, color: selectedGraph == "memory" ? Colors.green : Colors.grey),
                  tooltip: "Memory",
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => onGraphSelected("network_in"),
                  icon: Icon(Icons.download, color: selectedGraph == "network_in" ? Colors.blue : Colors.grey),
                  tooltip: "Network In",
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => onGraphSelected("network_out"),
                  icon: Icon(Icons.upload, color: selectedGraph == "network_out" ? Colors.orange : Colors.grey),
                  tooltip: "Network Out",
                ),
              ],
            ),
            const SizedBox(width: 16), // Space between buttons and graph

            // Graph on the right side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    graphTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: false, // Remove grid lines
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false, // Hide numbers on the left side
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40, // Add space between graph and right title numbers
                              getTitlesWidget: (value, meta) {
                                // Only show labels at exact intervals
                                if (value % interval == 0 && value >= minY && value <= maxY) {
                                  return Container(
                                    width: 40, // Set a fixed width
                                    alignment: Alignment.centerRight, // Align text to the right
                                    child: Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54, // Match bottom title color
                                      ),
                                      textAlign: TextAlign.right, // Ensure text is right-aligned
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              interval: interval, // Use the calculated interval
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40, // Increase reservedSize to add space between graph and bottom title
                              getTitlesWidget: (value, meta) {
                                // Format the x-axis labels as time
                                
                                // Skip labels that would be outside our 5-hour window
                                if (selectedSpots.isNotEmpty) {
                                  double minX = selectedSpots.map((spot) => spot.x).reduce((a, b) => a < b ? a : b);
                                  double maxX = selectedSpots.map((spot) => spot.x).reduce((a, b) => a > b ? a : b);
                                  
                                  if (value < minX || value > maxX + 1) {
                                    return const Text('');
                                  }
                                  
                                  DateTime labelTime = DateTime.now().add(Duration(hours: value.toInt()));
                                  String formattedTime = DateFormat('h a').format(labelTime);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  );
                                }
                                
                                // Default case if selectedSpots is empty
                                DateTime labelTime = DateTime.now().add(Duration(hours: value.toInt()));
                                String formattedTime = DateFormat('h a').format(labelTime);
                                
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false, // Hide numbers above the graph
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
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchSpotThreshold: 10, // Increase touch area for better usability
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((spot) {
                                // Format the value to 2 decimal places with % sign
                                String valueText = "";
                                
                                // Add % for CPU and Memory, but not for Network traffic
                                if (selectedGraph == "cpu" || selectedGraph == "memory") {
                                  valueText = "${spot.y.toStringAsFixed(2)}%";
                                } else {
                                  valueText = "${spot.y.toStringAsFixed(2)} Mbps";
                                }
                                return LineTooltipItem(
                                  valueText,
                                  TextStyle(
                                    color: graphColor,
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
                                  color: graphColor,
                                  strokeWidth: 2,
                                  dashArray: [3, 3],
                                ),
                                FlDotData(
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 6, // Slightly larger when touched
                                      color: Colors.white,
                                      strokeWidth: 3,
                                      strokeColor: graphColor,
                                    );
                                  },
                                ),
                              );
                            }).toList();
                          },
                        ),
                        clipData: FlClipData.all(), // Important: Clip content to the chart area
                        lineBarsData: [
                          LineChartBarData(
                            spots: selectedSpots,
                            isCurved: true,
                            color: graphColor,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: graphColor.withOpacity(0.1),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white, // White fill for hollow appearance
                                  strokeWidth: 2,
                                  strokeColor: graphColor, // Border color matching the line
                                );
                              },
                            ),
                          ),
                        ],
                        minY: minY, // Set the minimum y-axis value
                        maxY: maxY, // Set the maximum y-axis value
                        minX: selectedSpots.isEmpty ? 0 : selectedSpots.map((spot) => spot.x).reduce((a, b) => a < b ? a : b),
                        maxX: selectedSpots.isEmpty ? 1 : selectedSpots.map((spot) => spot.x).reduce((a, b) => a > b ? a : b) + 1, // Add +1 to include next hour
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}