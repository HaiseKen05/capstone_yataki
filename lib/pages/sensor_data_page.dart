import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_client.dart';
import 'fullscreen_chart_page.dart'; // ⬅️ New page import

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
      appBar: AppBar(title: Text("Sensor Data")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    children: [
                      // 📊 Compact Chart (last 7 entries)
                      if (_sensorData.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FullscreenChartPage(sensorData: _sensorData),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 250,
                                child: LineChart(
                                  LineChartData(
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                            if (index >= 0 &&
                                                index < recentData.length) {
                                              final date =
                                                  recentData[index]['datetime'];
                                              return Text(
                                                DateFormat("MM/dd").format(
                                                    DateTime.parse(date)),
                                                style: TextStyle(fontSize: 10),
                                              );
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(show: true),
                                    borderData: FlBorderData(show: true),
                                    lineBarsData: [
                                      // 🔋 Voltage
                                      LineChartBarData(
                                        spots: recentData
                                            .asMap()
                                            .entries
                                            .map((e) => FlSpot(
                                                  e.key.toDouble(),
                                                  (e.value['voltage'] ?? 0)
                                                      .toDouble(),
                                                ))
                                            .toList(),
                                        isCurved: true,
                                        color: Colors.blue,
                                        dotData: FlDotData(show: false),
                                      ),
                                      // ⚡ Current
                                      LineChartBarData(
                                        spots: recentData
                                            .asMap()
                                            .entries
                                            .map((e) => FlSpot(
                                                  e.key.toDouble(),
                                                  (e.value['current'] ?? 0)
                                                      .toDouble(),
                                                ))
                                            .toList(),
                                        isCurved: true,
                                        color: Colors.red,
                                        dotData: FlDotData(show: false),
                                      ),
                                      // 👣 Steps
                                      LineChartBarData(
                                        spots: recentData
                                            .asMap()
                                            .entries
                                            .map((e) => FlSpot(
                                                  e.key.toDouble(),
                                                  (e.value['steps'] ?? 0)
                                                      .toDouble(),
                                                ))
                                            .toList(),
                                        isCurved: true,
                                        color: Colors.green,
                                        dotData: FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 📜 Sensor Data Logs
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
                            child: ListTile(
                              leading: Icon(Icons.memory),
                              title: Text("Log ID: ${sensor['id']}"),
                              subtitle: Text(
                                "Steps: ${sensor['steps']} | "
                                "V: ${sensor['voltage']}V | "
                                "I: ${sensor['current']}A",
                              ),
                              trailing: Text(formattedDate),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
