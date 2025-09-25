import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class FullscreenChartPage extends StatefulWidget {
  final List<dynamic> sensorData;

  const FullscreenChartPage({super.key, required this.sensorData});

  @override
  _FullscreenChartPageState createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends State<FullscreenChartPage> {
  late double minY;
  late double maxY;

  @override
  void initState() {
    super.initState();

    // Lock to landscape when page opens
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _calculateYBounds();
  }

  @override
  void dispose() {
    // Restore portrait orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Dynamically calculate the minimum and maximum Y values across all data
  void _calculateYBounds() {
    final data = widget.sensorData;

    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;

    for (var entry in data) {
      final voltage = (entry['voltage'] ?? 0).toDouble();
      final current = (entry['current'] ?? 0).toDouble();
      final steps = (entry['steps'] ?? 0).toDouble();

      minVal = [
        minVal,
        voltage,
        current,
        steps,
      ].reduce((a, b) => a < b ? a : b);

      maxVal = [
        maxVal,
        voltage,
        current,
        steps,
      ].reduce((a, b) => a > b ? a : b);
    }

    // Add padding for better visuals
    minY = (minVal - (maxVal - minVal) * 0.1).clamp(0, double.infinity);
    maxY = maxVal + (maxVal - minVal) * 0.1;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.sensorData;

    return Scaffold(
      appBar: AppBar(title: const Text("Full History Chart")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxY - minY) / 6,
                        getTitlesWidget: (value, meta) {
                          // Format numbers dynamically
                          if (value >= 100) {
                            return Text(value.toStringAsFixed(0)); // Steps
                          } else {
                            return Text(
                              value.toStringAsFixed(2),
                            ); // Voltage/Current
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (data.length / 7).floorToDouble(),
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index]['datetime'];
                            return Text(
                              DateFormat("MM/dd").format(DateTime.parse(date)),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: (maxY - minY) / 6,
                    drawVerticalLine: true,
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
                    // 🔋 Voltage (Red)
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              (e.value['voltage'] ?? 0).toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    // ⚡ Current (Blue)
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              (e.value['current'] ?? 0).toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    // 👣 Steps (Yellow)
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              (e.value['steps'] ?? 0).toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.yellow[700]!,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📍 Legend Section
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// Builds the legend below the chart
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: Colors.red, label: "Voltage"),
        const SizedBox(width: 16),
        _legendItem(color: Colors.blue, label: "Current"),
        const SizedBox(width: 16),
        _legendItem(color: Colors.yellow, label: "Steps"),
      ],
    );
  }

  /// Helper widget for individual legend items
  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
