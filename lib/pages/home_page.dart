// Adding changes to home page soon

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _response = "Press the button to test connection";

  Future<void> _testConnection() async {
    try {
      final dio = Dio();
      final response = await dio.post(
        ApiClient.handshakeUrl,
        data: {"name": "Keith"},
      );

      if (response.statusCode == 200) {
        setState(() => _response = response.data["message"]);
      } else {
        setState(() => _response = "❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _response = "⚠️ Connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_response, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testConnection,
              child: Text("Test Connection"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              child: Text("Go to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
