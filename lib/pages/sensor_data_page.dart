import 'package:flutter/material.dart';
import '../api/api_client.dart';

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  List<dynamic> _sensorData = [];
  bool _isLoading = true;
  String _errorMessage = "";

  Future<void> _fetchSensorData() async {
    try {
      final response = await ApiClient.dio.get(
        "/sensor-data",
        queryParameters: {"page": 1, "per_page": 10},
      );

      if (response.statusCode == 200) {
        setState(() {
          _sensorData = response.data["logs"] ?? [];
          _isLoading = false;
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
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensor Data")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _sensorData.length,
                  itemBuilder: (context, index) {
                    final sensor = _sensorData[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.memory),
                        title: Text("Log ID: ${sensor['id']}"),
                        subtitle: Text(
                          "Steps: ${sensor['steps']} | "
                          "V: ${sensor['voltage']}V | "
                          "I: ${sensor['current']}A",
                        ),
                        trailing: Text(sensor['datetime'] ?? ""),
                      ),
                    );
                  },
                ),
    );
  }
}
