import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class FullscreenChartPage extends StatefulWidget {
  final List<dynamic> sensorData;

  FullscreenChartPage({required this.sensorData});

  @override
  _FullscreenChartPageState createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends State<FullscreenChartPage> {
  @override
  void initState() {
    super.initState();
    // Lock to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.sensorData;

    return Scaffold(
      appBar: AppBar(title: Text("Full History Chart")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (data.length / 7).floorToDouble(), // fewer labels
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
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              // 🔋 Voltage
              LineChartBarData(
                spots: data.asMap().entries.map((e) => FlSpot(
                      e.key.toDouble(),
                      (e.value['voltage'] ?? 0).toDouble(),
                    )).toList(),
                isCurved: true,
                color: Colors.blue,
              ),
              // ⚡ Current
              LineChartBarData(
                spots: data.asMap().entries.map((e) => FlSpot(
                      e.key.toDouble(),
                      (e.value['current'] ?? 0).toDouble(),
                    )).toList(),
                isCurved: true,
                color: Colors.red,
              ),
              // 👣 Steps
              LineChartBarData(
                spots: data.asMap().entries.map((e) => FlSpot(
                      e.key.toDouble(),
                      (e.value['steps'] ?? 0).toDouble(),
                    )).toList(),
                isCurved: true,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
