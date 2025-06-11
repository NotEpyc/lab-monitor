import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:lab_monitor/widgets/system_card.dart';
import 'package:lab_monitor/widgets/cpu_card.dart';
import 'package:lab_monitor/widgets/memory_card.dart';
import 'package:lab_monitor/widgets/network_card.dart';
import 'package:lab_monitor/widgets/resource_usage_graph.dart';
import 'package:lab_monitor/screens/pages/profile_page.dart';
import 'package:lab_monitor/widgets/modern_bottom_nav_bar.dart';
import 'package:lab_monitor/widgets/notification_panel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DummyDashboard extends StatefulWidget {
  const DummyDashboard({super.key});

  @override
  _DummyDashboardState createState() => _DummyDashboardState();
}

class _DummyDashboardState extends State<DummyDashboard> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _data = [];
  String _selectedGraph = "cpu";
  bool _showNotifications = false;
  Offset _iconPosition = Offset.zero; // Position of the notification icon
  final GlobalKey _iconKey = GlobalKey(); // Key to get the icon's position

  List<FlSpot> cpuAverageSpots = [];
  List<FlSpot> memoryAverageSpots = [];
  List<FlSpot> networkInAverageSpots = [];
  List<FlSpot> networkOutAverageSpots = [];

  final _secureStorage = const FlutterSecureStorage();
  String _profileImage = 'assets/images/pfp.png';

  @override
  void initState() {
    super.initState();
    _loadDummyData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final email = await _secureStorage.read(key: 'email');
    if (email != null) {
      setState(() {
        switch (email.toLowerCase()) {
          case 'ericrikku@gmail.com':
            _profileImage = 'assets/images/eric.png';
            break;
          case 'jeejofarhan@gmail.com':
            _profileImage = 'assets/images/farhan.jpg';
            break;
          case 'ashwinantonynelson@gmail.com':
            _profileImage = 'assets/images/ashwin.jpg';
            case 'rittodavid@gmail.com':
            _profileImage = 'assets/images/david.jpg';
            break;
          default:
            _profileImage = 'assets/images/pfp.png';
        }
      });
    }
  }

  Future<void> _loadDummyData() async {
    if (!mounted) return; // Add early check for mounted state
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Generate 48 random system numbers between 1 and 68
      Random random = Random();
      Set<int> usedNumbers = {};
      List<Map<String, dynamic>> systems = [];

      while (systems.length < 48) {
        int systemNumber = random.nextInt(68) + 1; // Random number between 1 and 68
        if (!usedNumbers.contains(systemNumber)) {
          usedNumbers.add(systemNumber);
          systems.add({"computer_id": "comp-$systemNumber"});
        }
      }

      // Sort systems by number for consistent display
      systems.sort((a, b) {
        int aNum = int.parse(a["computer_id"].split('-')[1]);
        int bNum = int.parse(b["computer_id"].split('-')[1]);
        return aNum.compareTo(bNum);
      });

      int idCounter = 1;
      DateTime startTime = DateTime.parse("2025-03-21T10:00:00Z");

      List<Map<String, dynamic>> newData = [];

      for (var system in systems) {
        for (int i = 0; i < 5; i++) {
          newData.add({
            "id": idCounter.toString(),
            "computer_id": system["computer_id"],
            "cpu": double.parse((30.0 + random.nextDouble() * 70.0).toStringAsFixed(2)),
            "memory": double.parse((40.0 + random.nextDouble() * 60.0).toStringAsFixed(2)),
            "network_in": double.parse((50.0 + random.nextDouble() * 150.0).toStringAsFixed(2)),
            "network_out": double.parse((30.0 + random.nextDouble() * 170.0).toStringAsFixed(2)),
            "timestamp": startTime.subtract(Duration(hours: i)).toIso8601String(),
          });
          idCounter++;
        }
      }

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;
      
      setState(() {
        _data = newData;
        _isLoading = false;
        // Prepare graph data immediately after setting the data
        _prepareGraphData();
      });
    } catch (e) {
      // Check if the widget is still mounted before calling setState
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, double> _calculateAverages() {
    if (_data.isEmpty) return {};

    double totalCpu = 0, totalMemory = 0, totalNetworkIn = 0, totalNetworkOut = 0;
    for (var entry in _data) {
      totalCpu += entry['cpu'];
      totalMemory += entry['memory'];
      totalNetworkIn += entry['network_in'];
      totalNetworkOut += entry['network_out'];
    }

    final count = _data.length;
    return {
      'cpu': totalCpu / count,
      'memory': totalMemory / count,
      'network_in': totalNetworkIn / count,
      'network_out': totalNetworkOut / count,
    };
  }

  int _calculateOnlineSystems() {
    // Use a Set to collect unique computer IDs
    final uniqueComputerIds = <String>{};
    for (var entry in _data) {
      uniqueComputerIds.add(entry['computer_id']);
    }
    return uniqueComputerIds.length; // Return the count of unique computer IDs
  }

  void _prepareGraphData() {
    if (_data.isEmpty) return;

    // Clear existing data
    cpuAverageSpots.clear();
    memoryAverageSpots.clear();
    networkInAverageSpots.clear();
    networkOutAverageSpots.clear();

    // Parse timestamps and normalize them to hours since the start time
    DateTime startTime = DateTime.parse(_data.first['timestamp']);

    // Group data by timestamp and calculate averages
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var entry in _data) {
      String timestamp = entry['timestamp'];
      if (!groupedData.containsKey(timestamp)) {
        groupedData[timestamp] = [];
      }
      groupedData[timestamp]!.add(entry);
    }

    // Sort timestamps to get the most recent ones
    List<String> sortedTimestamps = groupedData.keys.toList();
    sortedTimestamps.sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a))); // Sort newest first
    
    // Limit to only the 4 most recent timestamps (to make room for the 5th "next hour" spot)
    if (sortedTimestamps.length > 4) {
      sortedTimestamps = sortedTimestamps.sublist(0, 4);
    }

    // Process the data points for the limited timestamps
    for (String timestamp in sortedTimestamps) {
      var entries = groupedData[timestamp]!;
      DateTime timestampDate = DateTime.parse(timestamp);
      double xValue = timestampDate.difference(startTime).inHours.toDouble();

      // Calculate averages for this timestamp
      double avgCpu = entries.map((e) => e['cpu']).reduce((a, b) => a + b) / entries.length;
      double avgMemory = entries.map((e) => e['memory']).reduce((a, b) => a + b) / entries.length;
      double avgNetworkIn = entries.map((e) => e['network_in']).reduce((a, b) => a + b) / entries.length;
      double avgNetworkOut = entries.map((e) => e['network_out']).reduce((a, b) => a + b) / entries.length;

      // Round to 2 decimal places
      avgCpu = double.parse(avgCpu.toStringAsFixed(2));
      avgMemory = double.parse(avgMemory.toStringAsFixed(2));
      avgNetworkIn = double.parse(avgNetworkIn.toStringAsFixed(2));
      avgNetworkOut = double.parse(avgNetworkOut.toStringAsFixed(2));

      // Add average points to the respective lists
      cpuAverageSpots.add(FlSpot(xValue, avgCpu));
      memoryAverageSpots.add(FlSpot(xValue, avgMemory));
      networkInAverageSpots.add(FlSpot(xValue, avgNetworkIn));
      networkOutAverageSpots.add(FlSpot(xValue, avgNetworkOut));
    }

    // Sort spots by x value to ensure proper ordering
    cpuAverageSpots.sort((a, b) => a.x.compareTo(b.x));
    memoryAverageSpots.sort((a, b) => a.x.compareTo(b.x));
    networkInAverageSpots.sort((a, b) => a.x.compareTo(b.x));
    networkOutAverageSpots.sort((a, b) => a.x.compareTo(b.x));
  }

  void _toggleNotifications() {
    final RenderBox renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    setState(() {
      _iconPosition = position;
      _showNotifications = !_showNotifications;
    });
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final averages = _calculateAverages();
  final onlineSystems = _calculateOnlineSystems();

  return Scaffold(
    backgroundColor: Colors.white,
    extendBody: true,
    extendBodyBehindAppBar: true, // Add this line
    body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: SafeArea(
        bottom: false, // Add this line
        child: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    floating: true,
                    snap: false,
                    pinned: false,
                    leadingWidth: screenWidth * 0.16, // Adjust leading width dynamically
                    leading: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.04), // Adjusted left padding to match the cards below
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfilePage()),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.045, // Reduced from 0.06
                          height: screenWidth * 0.045, // Reduced from 0.06
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Ensures the container is circular
                            image: DecorationImage(
                              image: AssetImage(_profileImage), // Use the dynamic profile image
                              fit: BoxFit.cover, // Ensures the image fits perfectly
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: _toggleNotifications,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              key: _iconKey, // Assign the key to the notification icon
                              color: Colors.black,
                              size: screenWidth * 0.07, // Dynamic icon size
                            ),
                            // Notification badge
                            Positioned(
                              top: screenHeight * 0.02, // Adjust badge position dynamically
                              right: 0,
                              child: Container(
                                width: screenWidth * 0.02, // Dynamic badge size
                                height: screenWidth * 0.02,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Dynamic spacing between actions
                    ],
                    title: Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05, // Dynamic font size
                      ),
                    ),
                    centerTitle: true, // Center the title
                  ),
                ];
              },
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SystemCard(onlineSystems: onlineSystems),
                                SizedBox(height: screenHeight * 0.02),
                                CpuCard(cpuUsage: averages['cpu'] ?? 0),
                                SizedBox(height: screenHeight * 0.02),
                                MemoryCard(memoryUsage: averages['memory'] ?? 0),
                                SizedBox(height: screenHeight * 0.02),
                                NetworkCard(
                                  networkIn: averages['network_in'] ?? 0,
                                  networkOut: averages['network_out'] ?? 0,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ResourceUsageGraph(
                                  cpuAverageSpots: cpuAverageSpots,
                                  memoryAverageSpots: memoryAverageSpots,
                                  networkInAverageSpots: networkInAverageSpots,
                                  networkOutAverageSpots: networkOutAverageSpots,
                                  selectedGraph: _selectedGraph,
                                  onGraphSelected: (graph) {
                                    setState(() {
                                      _selectedGraph = graph; // Only update the selected graph
                                    });
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.1), // Add padding to avoid overlap
                              ],
                            ),
                          ),
                        ),
            ),

            // Show notification panel when needed
            if (_showNotifications)
              NotificationPanel(
                onClose: () {
                  setState(() {
                    _showNotifications = false;
                  });
                },
                iconPosition: _iconPosition,
                iconSize: screenWidth * 0.06, // Size of the notification icon
              ),
          ],
        ),
      ),
    ),

    // Conditionally render the navigation bar
    bottomNavigationBar: _showNotifications
        ? null // Hide the navigation bar when notifications are open
        : ModernBottomNavBar(
            selectedIndex: 0,
            data: _data, // Pass the initialized _data
          ),
  );
}
}