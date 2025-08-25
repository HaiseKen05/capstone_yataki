import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'login_page.dart';
import 'sensor_data_page.dart';
import 'forecast_page.dart';

class DashboardPage extends StatefulWidget {
  final String username;

  DashboardPage({required this.username});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _forecast;
  bool _loadingForecast = true;
  String _forecastError = "";

  Future<void> _fetchForecast() async {
    try {
      final response = await ApiClient.dio.get("/forecast");
      if (response.statusCode == 200) {
        setState(() {
          _forecast = response.data;
          _loadingForecast = false;
        });
      } else {
        setState(() {
          _forecastError = "❌ Error ${response.statusCode}";
          _loadingForecast = false;
        });
      }
    } catch (e) {
      setState(() {
        _forecastError = "⚠️ Failed to load forecast: $e";
        _loadingForecast = false;
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
      appBar: AppBar(
        title: Text("Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.username} 👋",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // 🔮 Forecast Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _loadingForecast
                    ? Center(child: CircularProgressIndicator())
                    : _forecastError.isNotEmpty
                        ? Text(_forecastError)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "🔮 Forecast (${_forecast!['forecast_date']})",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text("🔋 Voltage: ${_forecast!['forecast_voltage']} V"),
                              Text("⚡ Current: ${_forecast!['forecast_current']} A"),
                              SizedBox(height: 8),
                              Text(
                                "📈 Best Voltage: ${_forecast!['best_voltage_month']} (${_forecast!['best_voltage_value']} V)",
                              ),
                              Text(
                                "📉 Best Current: ${_forecast!['best_current_month']} (${_forecast!['best_current_value']} A)",
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  child: Text("See More →"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ForecastPage()),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
              ),
            ),

            // 📡 Sensor Data
            Card(
              child: ListTile(
                leading: Icon(Icons.sensors),
                title: Text("View Sensor Data"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SensorDataPage()),
                  );
                },
              ),
            ),

            // 🚪 Logout
            Card(
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () {
                  ApiClient.cookieJar.deleteAll();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
