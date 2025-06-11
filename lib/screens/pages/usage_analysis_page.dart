import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lab_monitor/widgets/modern_bottom_nav_bar.dart';
import 'package:lab_monitor/widgets/system_usage_graph.dart';
import 'package:flutter/services.dart';

class UsageAnalysisPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const UsageAnalysisPage({Key? key, required this.data}) : super(key: key);

  @override
  State<UsageAnalysisPage> createState() => _UsageAnalysisPageState();
}

class _UsageAnalysisPageState extends State<UsageAnalysisPage> {
  late List<Map<String, dynamic>> _systems;
  late List<Map<String, dynamic>> _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
    _initializeSystems();
  }

  void _initializeSystems() {
    // Get unique systems from the current data
    final Set<String> uniqueSystemIds = _currentData
        .where((entry) => entry['computer_id'] != null)
        .map((entry) => entry['computer_id'].toString())
        .toSet();

    // Create system list from unique IDs
    _systems = uniqueSystemIds.map((id) {
      final systemNumber = id.split('-')[1];
      return {
        "id": id,
        "name": "System $systemNumber"
      };
    }).toList();

    // Sort systems by number
    _systems.sort((a, b) {
      int aNum = int.parse(a["id"].split('-')[1]);
      int bNum = int.parse(b["id"].split('-')[1]);
      return aNum.compareTo(bNum);
    });
  }

  String? _selectedSystemId;

  void _selectSystem(String systemId) {
    setState(() {
      _selectedSystemId = systemId;
    });
  }

  void _closeGraph() {
    setState(() {
      _selectedSystemId = null;
    });
  }

  List<FlSpot> _getSystemData(String systemId, String key) {
    final systemData = _currentData
        .where((entry) => entry['computer_id'] == systemId)
        .toList();

    return systemData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value[key] as double;
      return FlSpot(index, value);
    }).toList();
  }

  List<FlSpot> _getNetworkUsageData(String systemId) {
    final systemData = _currentData
        .where((entry) => entry['computer_id'] == systemId)
        .toList();

    return systemData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final networkIn = entry.value['network_in'] as double;
      final networkOut = entry.value['network_out'] as double;
      final combinedNetworkUsage = ((networkIn + networkOut) / 4);
      return FlSpot(index, combinedNetworkUsage);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: _selectedSystemId == null
          ? ModernBottomNavBar(
              selectedIndex: 1,
              data: widget.data,
            )
          : null,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Always transparent
          statusBarIconBrightness: _selectedSystemId != null
              ? Brightness.light // Light icons when graph is shown
              : Brightness.dark, // Dark icons for normal view
          systemNavigationBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
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
                          title: Text(
                            'Usage Analysis',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05,
                            ),
                          ),
                          centerTitle: true,
                        ),
                      ];
                    },
                    body: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.04,
                          screenHeight * 0.02,
                          screenWidth * 0.04,
                          screenHeight * 0.1,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _systems.length,
                          itemBuilder: (context, index) {
                            final system = _systems[index];
                            // Get latest data for this system with null check
                            final systemData = widget.data
                                .where((entry) => entry['computer_id'] == system["id"])
                                .toList();
                            
                            if (systemData.isEmpty) {
                              return const SizedBox.shrink(); // Skip systems without data
                            }

                            final latestData = systemData.first;
                            
                            return GestureDetector(
                              onTap: () => _selectSystem(system["id"]),
                              child: Container(
                                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                height: screenHeight * 0.12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: screenWidth * 0.15,
                                      height: screenWidth * 0.15,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.computer,
                                          size: screenWidth * 0.08,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.06),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            system["name"],
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            "Computer ID: ${latestData['computer_id']}",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: screenWidth * 0.05,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Graph Overlay - Moved outside SafeArea
            if (_selectedSystemId != null)
              Positioned.fill(
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.6, // Reduced from 0.65
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row containing system number and close button
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.01,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'System ${_selectedSystemId!.split('-')[1]}',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: screenWidth * 0.06,
                                        color: Colors.black87,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: _closeGraph,
                                    ),
                                  ],
                                ),
                              ),
                              // Graph with minimal padding
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.04,
                                    right: screenWidth * 0.04,
                                    bottom: screenWidth * 0.01, // Reduced from 0.02
                                  ),
                                  child: SystemUsageGraph(
                                    cpuSpots: _getSystemData(_selectedSystemId!, "cpu"),
                                    memorySpots: _getSystemData(_selectedSystemId!, "memory"),
                                    networkUsageSpots: _getNetworkUsageData(_selectedSystemId!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}