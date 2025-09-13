import 'package:flutter/material.dart';
import '../api/api_client.dart';

class BatteryHealthPage extends StatefulWidget {
  @override
  _BatteryHealthPageState createState() => _BatteryHealthPageState();
}

class _BatteryHealthPageState extends State<BatteryHealthPage> {
  double? batteryVoltage;
  double batteryPercentage = 0.0;
  bool loading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchBatteryData();
  }

  Future<void> _fetchBatteryData() async {
    try {
      final response = await ApiClient.dio.get("/api/v1/voltage-reading");
      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data'].isNotEmpty) {
          // Get the latest voltage value
          double latestVoltage = data['data'].last.toDouble();

          setState(() {
            batteryVoltage = latestVoltage;
            batteryPercentage = _calculateBatteryPercentage(latestVoltage);
            loading = false;
          });
        } else {
          setState(() {
            errorMessage = "No battery data available.";
            loading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode}";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: $e";
        loading = false;
      });
    }
  }

  double _calculateBatteryPercentage(double voltage) {
    // Assuming Li-ion battery with range 3.0V (0%) - 4.2V (100%)
    const double minVoltage = 3.0;
    const double maxVoltage = 4.2;

    if (voltage <= minVoltage) return 0.0;
    if (voltage >= maxVoltage) return 100.0;

    return ((voltage - minVoltage) / (maxVoltage - minVoltage)) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Battery Health"),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getBatteryIcon(batteryPercentage),
                        color: _getBatteryColor(batteryPercentage),
                        size: 120,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Voltage: ${batteryVoltage?.toStringAsFixed(2)} V",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Battery Health: ${batteryPercentage.toStringAsFixed(1)}%",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _fetchBatteryData,
                        icon: Icon(Icons.refresh),
                        label: Text("Refresh"),
                      ),
                    ],
                  ),
                ),
    );
  }

  IconData _getBatteryIcon(double percentage) {
    if (percentage > 80) return Icons.battery_full;
    if (percentage > 50) return Icons.battery_6_bar;
    if (percentage > 20) return Icons.battery_3_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(double percentage) {
    if (percentage > 50) return Colors.green;
    if (percentage > 20) return Colors.orange;
    return Colors.red;
  }
}
