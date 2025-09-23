import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String _errorMessage = "";
  String _currentBaseUrl = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentBaseUrl();
  }

  /// Load saved or default Base URL
  Future<void> _loadCurrentBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBaseUrl = prefs.getString('custom_base_url') ?? ApiClient.baseUrl;
    });
  }

  /// Function to test server connection using handshake API
  Future<void> _checkServerConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        ApiClient.handshakeUrl,
        data: {"name": ""}, // Temporary placeholder payload
      );

      if (response.statusCode == 200) {
        // ✅ Connection successful → go to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        setState(() {
          _errorMessage = "Server Offline (Error ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Server Offline";
        _isLoading = false;
      });
    }
  }

  /// Show dialog to manually set the server IP
  void _showServerSettingsDialog() {
    final baseUrlController = TextEditingController(text: _currentBaseUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          title: Row(
            children: [
              Icon(Icons.settings, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Server Settings",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: TextField(
            controller: baseUrlController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Base URL",
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purpleAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              onPressed: () async {
                final newBaseUrl = baseUrlController.text.trim();

                if (newBaseUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid Base URL")),
                  );
                  return;
                }

                // Update the APIClient with the new Base URL
                await ApiClient.updateBaseUrl(newBaseUrl);

                setState(() {
                  _currentBaseUrl = newBaseUrl;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Server URL updated successfully!")),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showServerSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌐 Logo at the top
                Image.asset(
                  'assets/images/output.png',
                  height: 120,
                ),
                SizedBox(height: 30),

                Text(
                  "Welcome to Yataki",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(221, 96, 15, 228),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                Text(
                  "Monitor your Generated Power System",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkServerConnection,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          )
                        : Text("Get Started"),
                  ),
                ),
                SizedBox(height: 20),

                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
