import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String _errorMessage = "";

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
        // ❌ Server responded but with error
        setState(() {
          _errorMessage = "Server Offline (Error ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      // ⚠️ Network failure or server unreachable
      setState(() {
        _errorMessage = "Server Offline";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌐 Logo at the top
                Image.asset(
                  'assets/images/output.png', // <-- Make sure you have a logo in assets
                  height: 120,
                ),
                SizedBox(height: 30),

                // App title or welcome message
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
                  style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 255, 255, 255)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // 🚀 "Get Started" button
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

                // ❗ Error message if server offline
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
