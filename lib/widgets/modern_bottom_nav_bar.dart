import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lab_monitor/widgets/nav_item.dart';
import 'package:lab_monitor/screens/pages/dummy_dashboard.dart';
import 'package:lab_monitor/screens/pages/usage_analysis_page.dart';
import 'package:lab_monitor/screens/pages/admin_control_page.dart';

class ModernBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> data; // Add the data parameter

  const ModernBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.data, // Add the required parameter
  }) : super(key: key);

  @override
  State<ModernBottomNavBar> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<ModernBottomNavBar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    _navigateToPage(context, index);
  }

  void _navigateToPage(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const DummyDashboard();
        break;
      case 1:
        page = UsageAnalysisPage(data: widget.data);
        break;
      case 2:
        // Get data from current page with null safety
        final currentData = widget.data.isNotEmpty ? widget.data.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
        page = AdminControlPage(data: currentData);
        break;
      default:
        page = const DummyDashboard();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The visible container with buttons
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0), // Add top and bottom padding
                        child: NavItem(
                          icon: FontAwesomeIcons.house,
                          index: 0,
                          selectedIndex: _currentIndex,
                          onTap: (index) => _onItemTapped(context, index),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0), // Add top and bottom padding
                        child: NavItem(
                          icon: FontAwesomeIcons.chartPie,
                          index: 1,
                          selectedIndex: _currentIndex,
                          onTap: (index) => _onItemTapped(context, index),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0), // Add top and bottom padding
                        child: NavItem(
                          icon: FontAwesomeIcons.gear,
                          index: 2,
                          selectedIndex: _currentIndex,
                          onTap: (index) => _onItemTapped(context, index),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}