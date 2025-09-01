import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ForecastPage extends StatefulWidget {
  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  Map<String, dynamic>? _forecast;
  bool _isLoading = true;
  String _errorMessage = "";

  Future<void> _fetchForecast() async {
    try {
      final response = await ApiClient.dio.get("/forecast");

      if (response.statusCode == 200) {
        setState(() {
          _forecast = response.data;
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
    _fetchForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forecast")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forecast for ${_forecast!['forecast_date']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      // Text-only forecast data
                      Text("🔋 Voltage: ${_forecast!['forecast_voltage']} V"),
                      Text("⚡ Current: ${_forecast!['forecast_current']} A"),
                      Text("📈 Best Voltage Month: ${_forecast!['best_voltage_month']} "
                          "(${_forecast!['best_voltage_value']} V)"),
                      Text("📉 Best Current Month: ${_forecast!['best_current_month']} "
                          "(${_forecast!['best_current_value']} A)"),
                    ],
                  ),
                ),
    );
  }
}
