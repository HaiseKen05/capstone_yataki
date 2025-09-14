import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'login_page.dart';
import 'sensor_data_page.dart';

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
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: Text("Dashboard"),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchForecast,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Welcome Section
              Text(
                "Welcome, ${widget.username} 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Here's an overview of your system today",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 20),

              // 🔮 Forecast Section
              _buildForecastCard(),

              SizedBox(height: 20),

              // 📡 Navigation Section
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),

              // View Sensor Data
              _buildQuickAction(
                icon: Icons.sensors,
                title: "View Sensor Data",
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SensorDataPage()),
                  );
                },
              ),

              SizedBox(height: 10),

              // Battery Health
              _buildQuickAction(
                icon: Icons.battery_full,
                title: "Battery Health",
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BatteryHealthPage()),
                  );
                },
              ),

              SizedBox(height: 10),

              // Logout
              _buildQuickAction(
                icon: Icons.logout,
                title: "Logout",
                color: Colors.redAccent,
                onTap: () {
                  ApiClient.cookieJar.deleteAll();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🌤 Forecast UI
  Widget _buildForecastCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingForecast
            ? Center(child: CircularProgressIndicator())
            : _forecastError.isNotEmpty
                ? Center(
                    child: Text(
                      _forecastError,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Today's Forecast",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Date: ${_forecast!['forecast_date']}",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildForecastMetric(
                            icon: Icons.battery_charging_full,
                            label: "Voltage",
                            value: "${_forecast!['forecast_voltage']} V",
                            color: Colors.blueAccent,
                          ),
                          _buildForecastMetric(
                            icon: Icons.flash_on,
                            label: "Current",
                            value: "${_forecast!['forecast_current']} A",
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  // Forecast Metric Widget
  Widget _buildForecastMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.white70)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ⚡ Quick Action Widget
  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

// =========================
// Battery Health Page
// =========================
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
      final response = await ApiClient.dio.get("/battery-health");
      
      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          batteryVoltage = (data['battery_voltage'] as num).toDouble();
          batteryPercentage = (data['battery_percentage'] as num).toDouble();
          loading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = "No battery data found.";
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
