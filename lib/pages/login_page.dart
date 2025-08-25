import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginResponse = "";

  Future<void> _login() async {
    try {
      final response = await ApiClient.dio.post(
        "/login",
        data: {
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200 &&
          response.data["status"] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(username: _usernameController.text),
          ),
        );
      } else {
        setState(() {
          _loginResponse = "❌ ${response.data['error'] ?? "Login failed"}";
        });
      }
    } catch (e) {
      setState(() => _loginResponse = "⚠️ Connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("Login"),
            ),
            SizedBox(height: 20),
            Text(
              _loginResponse,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
