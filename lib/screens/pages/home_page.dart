import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _secureStorage = const FlutterSecureStorage(); // Secure storage instance
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchResourceHistory();
  }

  Future<void> _fetchResourceHistory({
    String? computerId,
    String? startTime,
    String? endTime,
    int page = 1,
    int limit = 50,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Retrieve the JWT token from secure storage
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          _errorMessage = 'No token found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // Build query parameters
      final queryParams = {
        if (computerId != null) 'computer_id': computerId,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.http(
        'localhost:8080',
        '/api/v1/resources/history',
        queryParams,
      );

      // Make the API request
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _data = List<Map<String, dynamic>>.from(responseData['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
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
    // Assuming a system is online if it has valid data
    return _data.length;
  }

  @override
  Widget build(BuildContext context) {
    final averages = _calculateAverages();
    final onlineSystems = _calculateOnlineSystems();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
          CircleAvatar(backgroundImage: AssetImage('assets/images/bg.png')),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOnlineSystemsCard(onlineSystems),
                      const SizedBox(height: 16),
                      _buildAverageGraphCard(averages),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOnlineSystemsCard(int onlineSystems) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Systems Online",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "$onlineSystems systems are currently online",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageGraphCard(Map<String, double> averages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Average Resource Usage",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black, width: 1),
                    bottom: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _data
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value['cpu']))
                        .toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: _data
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value['memory']))
                        .toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: _data
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value['network_in']))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: _data
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value['network_out']))
                        .toList(),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
