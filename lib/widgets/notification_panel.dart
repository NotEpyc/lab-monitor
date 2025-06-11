import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPanel extends StatefulWidget {
  final Function onClose;
  final Offset iconPosition; // Position of the notification icon
  final double iconSize; // Size of the notification icon

  const NotificationPanel({
    Key? key,
    required this.onClose,
    required this.iconPosition,
    required this.iconSize,
  }) : super(key: key);

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _radiusAnimation;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'High CPU Usage',
      'message': 'Comp-05 showing sustained high CPU usage (92%)',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      'isRead': false,
      'type': 'warning',
      'resolved': false,
    },
    {
      'title': 'System Update',
      'message': 'Lab systems scheduled for updates tonight at 2 PM',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'isRead': true,
      'type': 'info',
      'resolved': false,
    },
    {
      'title': 'Memory Alert',
      'message': 'Comp-12 low memory warning (5% available)',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3, minutes: 25)).toIso8601String(),
      'isRead': false,
      'type': 'critical',
      'resolved': false,
    },
    {
      'title': 'Network Connection Lost',
      'message': 'Comp-27 disconnected from the network',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'isRead': true,
      'type': 'warning',
      'resolved': true,
    },
    {
      'title': 'New System Added',
      'message': 'Comp-28 has been added to the monitoring system',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
      'isRead': true,
      'type': 'info',
      'resolved': true,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slower animation
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize _radiusAnimation here because MediaQuery is now available
    _radiusAnimation = Tween<double>(
      begin: widget.iconSize / 2, // Start from the size of the notification icon
      end: MediaQuery.of(context).size.longestSide, // Expand to cover the entire screen
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closePanel() async {
    await _animationController.reverse();
    widget.onClose();
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'critical':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Radial expansion effect
            Positioned(
              left: widget.iconPosition.dx - _radiusAnimation.value,
              top: widget.iconPosition.dy - _radiusAnimation.value,
              child: ClipOval(
                child: Container(
                  width: _radiusAnimation.value * 2,
                  height: _radiusAnimation.value * 2,
                  color: Colors.white,
                ),
              ),
            ),

            if (_radiusAnimation.value > screenWidth / 2)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.04,
                          MediaQuery.of(context).padding.top, // Start from top safe area
                          screenWidth * 0.02,
                          screenHeight * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.done_all),
                              onPressed: () {
                                setState(() {
                                  for (var notification in _notifications) {
                                    notification['isRead'] = true;
                                  }
                                });
                              },
                              iconSize: screenWidth * 0.06,
                              color: Colors.black87,
                              tooltip: 'Mark all as read',
                              padding: EdgeInsets.zero, // Remove default padding
                              constraints: BoxConstraints(
                                minWidth: screenWidth * 0.08,
                                minHeight: screenWidth * 0.08,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _closePanel,
                              iconSize: screenWidth * 0.06,
                              color: Colors.black87,
                              padding: EdgeInsets.zero, // Remove default padding
                              constraints: BoxConstraints(
                                minWidth: screenWidth * 0.08,
                                minHeight: screenWidth * 0.08,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notification list as separate cards
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _animationController.value, // Fade in/out based on animation progress
                          duration: const Duration(milliseconds: 300),
                          child: ListView.builder(
                            padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              final Color typeColor = _getTypeColor(notification["type"]);
                              final IconData typeIcon = _getTypeIcon(notification["type"]);

                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: screenHeight * 0.02), // Dynamic margin
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03), // Dynamic border radius
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      notification["resolved"] = true;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Notification type indicator
                                        Container(
                                          decoration: BoxDecoration(
                                            color: typeColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(screenWidth * 0.02), // Dynamic padding
                                          child: Icon(
                                            typeIcon,
                                            color: typeColor,
                                            size: screenWidth * 0.05, // Dynamic icon size
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.03), // Dynamic spacing

                                        // Notification content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification["message"],
                                                style: TextStyle(
                                                  fontWeight: notification["isRead"] ? FontWeight.normal : FontWeight.bold,
                                                  fontSize: screenWidth * 0.035, // Dynamic font size
                                                ),
                                              ),
                                              SizedBox(height: screenHeight * 0.01), // Dynamic spacing

                                              // Timestamp
                                              Builder(
                                                builder: (context) {
                                                  final String? timestamp = notification["timestamp"];
                                                  if (timestamp != null) {
                                                    try {
                                                      return Text(
                                                        _formatNotificationTime(DateTime.parse(timestamp)),
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: screenWidth * 0.03, // Dynamic font size
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      return const Text(
                                                        'Invalid time',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    return const Text(
                                                      'Unknown time',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}