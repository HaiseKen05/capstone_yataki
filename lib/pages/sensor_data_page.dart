import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_client.dart';
import 'fullscreen_chart_page.dart';

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  List<dynamic> _sensorData = [];
  bool _isLoading = true;
  String _errorMessage = "";
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Timer? _refreshTimer; // 🔹 Timer for periodic refresh

  Future<void> _fetchSensorData({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = "";
      });
    }

    try {
      final response = await ApiClient.dio.get(
        "/sensor-data",
        queryParameters: {"page": _currentPage, "per_page": 10},
      );

      if (response.statusCode == 200) {
        final logs = response.data["logs"] ?? [];

        setState(() {
          if (loadMore) {
            _sensorData.addAll(logs);
            _isLoadingMore = false;
          } else {
            _sensorData = logs;
            _isLoading = false;
          }

          if (logs.isEmpty) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _errorMessage = "❌ Server error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "⚠️ Connection failed: $e";
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSensorData();

    // 🔹 Start periodic refresh every 10 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    // 🔹 Cancel timer when widget is destroyed
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
    });
    await _fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    final recentData = _sensorData.length > 7
        ? _sensorData.sublist(_sensorData.length - 7)
        : _sensorData;

    return Scaffold(
      appBar: AppBar(
        title: Text("Sensor Data"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullscreenChartPage(sensorData: _sensorData),
                ),
              );
            },
            icon: Icon(Icons.fullscreen, color: Colors.white),
            label: Text(
              "Fullscreen Chart",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    children: [
                      if (_sensorData.isNotEmpty) ...[
                        _buildChartCard(
                          title: "Voltage Over Time",
                          color: Colors.red,
                          data: recentData,
                          dataKey: "voltage",
                          unit: "V",
                        ),
                        _buildChartCard(
                          title: "Current Over Time",
                          color: Colors.blue,
                          data: recentData,
                          dataKey: "current",
                          unit: "A",
                        ),
                        _buildChartCard(
                          title: "Steps Over Time",
                          color: Colors.yellow[700]!,
                          data: recentData,
                          dataKey: "steps",
                          unit: "steps",
                          isSteps: true,
                        ),
                      ],

                      SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Sensor Logs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _sensorData.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _sensorData.length) {
                            if (_isLoadingMore) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (_hasMore) {
                              return TextButton(
                                onPressed: () {
                                  setState(() => _currentPage++);
                                  _fetchSensorData(loadMore: true);
                                },
                                child: Text("Load More"),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }

                          final sensor = _sensorData[index];
                          String formattedDate = "";
                          if (sensor['datetime'] != null) {
                            formattedDate = DateFormat("yyyy-MM-dd HH:mm")
                                .format(DateTime.parse(sensor['datetime']));
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 6.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.analytics, color: Colors.blue),
                              title: Text(
                                "Log #${sensor['id']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text("Voltage: ${sensor['voltage']} V"),
                                  Text("Current: ${sensor['current']} A"),
                                  Text("Steps: ${sensor['steps']}"),
                                ],
                              ),
                              trailing: Text(
                                formattedDate,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  /// Builds a single chart card for a given dataset
  Widget _buildChartCard({
    required String title,
    required Color color,
    required List<dynamic> data,
    required String dataKey,
    required String unit,
    bool isSteps = false,
  }) {
    if (data.isEmpty) return SizedBox.shrink();

    // Calculate min and max dynamically
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;

    for (var point in data) {
      final value = (point[dataKey] ?? 0).toDouble();
      if (value < minVal) minVal = value;
      if (value > maxVal) maxVal = value;
    }

    // Add some padding
    final range = maxVal - minVal;
    minVal = (minVal - range * 0.1).clamp(0, double.infinity);
    maxVal = maxVal + range * 0.1;

    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minVal,
                  maxY: maxVal,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: range > 0 ? range / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            isSteps
                                ? value.toStringAsFixed(0)
                                : value.toStringAsFixed(2),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (data.length / 6).floorToDouble(),
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index]['datetime'];
                            return Text(
                              DateFormat("MM/dd").format(DateTime.parse(date)),
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: range > 0 ? range / 5 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                (e.value[dataKey] ?? 0).toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Unit: $unit",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
