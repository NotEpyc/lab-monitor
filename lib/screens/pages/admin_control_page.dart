import 'package:flutter/material.dart';
import 'package:lab_monitor/widgets/modern_bottom_nav_bar.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:lab_monitor/widgets/custom_notification.dart';

// Convert to StatefulWidget to handle selection
class AdminControlPage extends StatefulWidget {
  final List<Map<String, dynamic>>? data;

  const AdminControlPage({
    Key? key, 
    this.data,
  }) : super(key: key);

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  int? selectedSystem;
  bool showSystems = false;
  List<Map<String, dynamic>> _processes = []; // Add this line to store processes

  @override
  void initState() {
    super.initState();
  }

  // Add this method to generate random processes
  void _generateProcesses() {
    final random = Random();
    _processes.clear();
    
    // Common process names
    final processList = [
      'chrome.exe', 'firefox.exe', 'spotify.exe', 'discord.exe', 
      'vscode.exe', 'explorer.exe', 'notepad.exe', 'word.exe',
      'excel.exe', 'powershell.exe', 'cmd.exe', 'python.exe',
      'malware.exe', 'unknown.exe', 'trojan.exe'
    ];

    // Generate 5-8 random processes
    int processCount = random.nextInt(4) + 5;
    for (int i = 0; i < processCount; i++) {
      _processes.add({
        'name': processList[random.nextInt(processList.length)],
        'cpu': (random.nextDouble() * 15).toStringAsFixed(1),
        'memory': (random.nextDouble() * 500).toStringAsFixed(1),
        'pid': random.nextInt(9000) + 1000,
      });
    }
  }

  // Add this method at the class level
  void _showEndProcessDialog(BuildContext context, Map<String, dynamic> process) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
          ),
          child: AlertDialog(
            title: Text('End Process'),
            content: Text('Are you sure you want to end ${process['name']}?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _processes.remove(process);
                  });
                  _showCustomNotification('${process['name']} has been terminated');
                },
                child: Text('End Process'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method to handle system shutdown
  void _handleSystemShutdown(int systemNumber) {
    if (widget.data == null) return;

    setState(() {
      // Remove system data
      widget.data!.removeWhere((item) => 
        item['computer_id'] != null && 
        item['computer_id'].toString().toLowerCase() == 'comp-$systemNumber'.toLowerCase()
      );
      
      // Reset selection
      selectedSystem = null;
      _processes.clear();
    });
  }

  // Add this method to handle system restart
  void _handleSystemRestart(int systemNumber) {
    setState(() {
      selectedSystem = null;
      _processes.clear();
    });
  }

  // Update the _systemExists method
  bool _systemExists(int systemNumber) {
    if (widget.data == null || widget.data!.isEmpty) return false;
    
    return widget.data!.any((item) => 
      item['computer_id'] != null && 
      item['computer_id'].toString().toLowerCase() == 'comp-$systemNumber'.toLowerCase()
    );
  }

  // Add this method to _AdminControlPageState class
  void _showCustomNotification(String message) {
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => CustomNotification(
        message: message,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Add these methods to _AdminControlPageState class
  void _handleShutdownAll() {
    if (widget.data == null) return;
    setState(() {
      widget.data!.clear();
      selectedSystem = null;
      _processes.clear();
    });
    _showCustomNotification('All systems have been shut down');
  }

  void _handleRestartAll() {
    setState(() {
      selectedSystem = null;
      _processes.clear();
    });
    _showCustomNotification('All systems are restarting');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        if (showSystems) {
          setState(() {
            showSystems = false;
            selectedSystem = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.04,
                  screenHeight * 0.02,
                  screenWidth * 0.04,
                  bottomPadding + 80,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Page Title
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        bottom: screenHeight * 0.02,
                      ),
                      child: Text(
                        'Admin Control',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Add this widget before the System Status Section in the SliverChildListDelegate
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.01), // Reduced from 0.02
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Text(
                              'System Control',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              screenWidth * 0.04,
                              0,
                              screenWidth * 0.04,
                              screenWidth * 0.04,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.black.withOpacity(0.5),
                                        useSafeArea: false,
                                        builder: (context) => AlertDialog(
                                          title: Text('Shutdown All Systems'),
                                          content: Text('Are you sure you want to shutdown all systems?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _handleShutdownAll();
                                              },
                                              child: Text('Shutdown All'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015,
                                        horizontal: screenWidth * 0.04,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.power_settings_new_rounded,
                                            color: Colors.red,
                                            size: screenWidth * 0.05,
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            'Shutdown All',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.black.withOpacity(0.5),
                                        useSafeArea: false,
                                        builder: (context) => AlertDialog(
                                          title: Text('Restart All Systems'),
                                          content: Text('Are you sure you want to restart all systems?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _handleRestartAll();
                                              },
                                              child: Text('Restart All'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015,
                                        horizontal: screenWidth * 0.04,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.restart_alt_rounded,
                                            color: Colors.blue,
                                            size: screenWidth * 0.05,
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            'Restart All',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // System Status Section with Dropdown
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: screenWidth * 0.92, // Changed from 0.8 to match other cards
                        constraints: BoxConstraints(
                          minHeight: screenHeight * 0.08,
                          maxHeight: showSystems ? screenHeight * 0.6 : screenHeight * 0.08,
                        ),
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01), // Reduced from 0.02
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.04,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  showSystems = !showSystems;
                                  if (!showSystems) {
                                    selectedSystem = null;
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed from center to spaceBetween
                                children: [
                                  Text(
                                    selectedSystem != null ? 'System $selectedSystem' : 'Select System',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    showSystems ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                    size: screenWidth * 0.06,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                            if (showSystems) ...[
                              Flexible(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.04),
                                    child: Wrap(
                                      spacing: screenWidth * 0.03,
                                      runSpacing: screenWidth * 0.03,
                                      alignment: WrapAlignment.center,
                                      children: List.generate(
                                        68,
                                        (index) => InkWell(
                                          onTap: _systemExists(index + 1) ? () => _selectSystem(index + 1) : null, // Disable tap for non-existent systems
                                          child: Container(
                                            width: (screenWidth * 0.82 - (5 * screenWidth * 0.03)) / 6, // Adjusted for new width
                                            height: (screenWidth * 0.82 - (5 * screenWidth * 0.03)) / 6, // Adjusted for new width
                                            decoration: BoxDecoration(
                                              color: selectedSystem == index + 1
                                                  ? Colors.blue.withOpacity(0.1)
                                                  : _systemExists(index + 1)
                                                      ? Colors.green.withOpacity(0.1)
                                                      : Colors.red.withOpacity(0.05), // Lighter red for unavailable systems
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: selectedSystem == index + 1
                                                    ? Colors.blue
                                                    : _systemExists(index + 1)
                                                        ? Colors.green.withOpacity(0.5)
                                                        : Colors.red.withOpacity(0.3), // Lighter border for unavailable systems
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: selectedSystem == index + 1
                                                      ? Colors.blue
                                                      : _systemExists(index + 1)
                                                          ? Colors.green
                                                          : Colors.red.withOpacity(0.5), // Lighter text for unavailable systems
                                                  fontWeight: selectedSystem == index + 1
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Add process cards when system is selected
                    if (selectedSystem != null) ...[
                      SizedBox(height: screenHeight * 0.01), // Reduced from 0.02
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  useSafeArea: false,
                                  builder: (context) => AlertDialog(
                                    title: Text('Shutdown System'),
                                    content: Text('Are you sure you want to shutdown System $selectedSystem?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          final systemNumber = selectedSystem;
                                          _handleSystemShutdown(selectedSystem!);
                                          _showCustomNotification('System $systemNumber has been shut down');
                                        },
                                        child: Text('Shutdown'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.04,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.power_settings_new_rounded,
                                      color: Colors.red,
                                      size: screenWidth * 0.05,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      'Shutdown',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  useSafeArea: false,
                                  builder: (context) => AlertDialog(
                                    title: Text('Restart System'),
                                    content: Text('Are you sure you want to restart System $selectedSystem?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          final systemNumber = selectedSystem;
                                          _handleSystemRestart(selectedSystem!);
                                          _showCustomNotification('System $systemNumber is restarting');
                                        },
                                        child: Text('Restart'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.04,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restart_alt_rounded,
                                      color: Colors.blue,
                                      size: screenWidth * 0.05,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      'Restart',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01), // Reduced from 0.02
                      Container(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005), // Reduced from 0.01
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Text(
                                'System $selectedSystem Processes',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ..._processes.asMap().entries.map((entry) {
                              final process = entry.value;
                              final isLast = entry.key == _processes.length - 1;
                              
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // Show confirmation dialog
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('End Process'),
                                          content: Text('Are you sure you want to end ${process['name']}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _processes.remove(process);
                                                });
                                                _showCustomNotification('${process['name']} has been terminated');
                                              },
                                              child: Text('End Process'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(screenWidth * 0.04),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  process['name'],
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                    color: process['name'].toLowerCase().contains('malware') ||
                                                           process['name'].toLowerCase().contains('suspicious') ||
                                                           process['name'].toLowerCase().contains('trojan')
                                                        ? Colors.red
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: screenHeight * 0.01),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'CPU: ${process['cpu']}%',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.035,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    SizedBox(width: screenWidth * 0.08),
                                                    Text(
                                                      'Memory: ${process['memory']} MB',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.035,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.08), // Increased space before button
                                          GestureDetector( // Changed to GestureDetector
                                            onTap: () => _showEndProcessDialog(context, process),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.all(screenWidth * 0.02),
                                              child: Icon(
                                                Icons.stop_circle_outlined, // Changed to stop_rounded
                                                size: screenWidth * 0.05,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (!isLast) Divider(
                                    height: 1,
                                    color: Colors.grey[200],
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ModernBottomNavBar(
          selectedIndex: 2,
          data: widget.data ?? [], // Provide empty list as fallback
        ),
      ),
    );
  }

  // Update the _selectSystem method to check system existence
  void _selectSystem(int system) {
    if (!_systemExists(system)) return; // Don't select if system doesn't exist

    setState(() {
      selectedSystem = system;
      showSystems = false;
      _generateProcesses();
    });
  }
}