import 'package:flutter/material.dart';
import '../api/api_client.dart';

class BatteryHealthPage extends StatefulWidget {
  @override
  _BatteryHealthPageState createState() => _BatteryHealthPageState();
}

class _BatteryHealthPageState extends State<BatteryHealthPage> {
  double? batteryVoltage;
  double? batteryPercentage;
  String? lastUpdated;
  bool loading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchBatteryData();
  }

  /// Fetch battery health data from the Flask API
  Future<void> _fetchBatteryData() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      // ✅ Make sure the endpoint matches the Flask route exactly
      final response = await ApiClient.dio.get("/api/v1/battery-health");

      if (response.statusCode == 200) {
        final data = response.data;

        // Validate and extract expected keys
        if (data != null &&
            data.containsKey('battery_voltage') &&
            data.containsKey('battery_percentage')) {
          setState(() {
            batteryVoltage = (data['battery_voltage'] as num?)?.toDouble();
            batteryPercentage = (data['battery_percentage'] as num?)?.toDouble();
            lastUpdated = data['datetime'] as String?;
            loading = false;
          });
        } else {
          setState(() {
            errorMessage = "Invalid data format from server.";
            loading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = "No battery health data found.";
          loading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battery Health"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildBatteryHealthView(),
    );
  }

  /// UI when an error occurs
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchBatteryData,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// UI when data loads successfully
  Widget _buildBatteryHealthView() {
    final voltageText = batteryVoltage != null
        ? "${batteryVoltage!.toStringAsFixed(2)} V"
        : "--";

    final percentageText = batteryPercentage != null
        ? "${batteryPercentage!.toStringAsFixed(1)}%"
        : "--";

    final updatedText = lastUpdated ?? "--";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getBatteryIcon(batteryPercentage ?? 0.0),
            color: _getBatteryColor(batteryPercentage ?? 0.0),
            size: 120,
          ),
          const SizedBox(height: 20),
          Text(
            "Voltage: $voltageText",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Battery Health: $percentageText",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            "Last Updated: $updatedText",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _fetchBatteryData,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  /// Icon logic
  IconData _getBatteryIcon(double percentage) {
    if (percentage > 80) return Icons.battery_full;
    if (percentage > 50) return Icons.battery_6_bar;
    if (percentage > 20) return Icons.battery_3_bar;
    return Icons.battery_alert;
  }

  /// Color logic
  Color _getBatteryColor(double percentage) {
    if (percentage > 50) return Colors.green;
    if (percentage > 20) return Colors.orange;
    return Colors.red;
  }
}
