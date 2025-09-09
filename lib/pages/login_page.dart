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
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _loginResponse = "";
    });

    try {
      final response = await ApiClient.dio.post(
        "/login",
        data: {
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200 && response.data["status"] == "success") {
        // ✅ Navigate to Dashboard on successful login
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),

              // 🌐 App Logo
              Image.asset(
                'assets/images/output.png', // <-- Make sure this logo exists
                height: 100,
              ),
              SizedBox(height: 20),

              // Title
              Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(221, 235, 235, 235),
                ),
              ),
              SizedBox(height: 8),

              Text(
                "Log in to continue monitoring your kinetic energy system",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 255, 253, 253)),
              ),
              SizedBox(height: 40),

              // 📝 Username Input
              TextField(
                controller: _usernameController,
                cursorColor: Colors.blueAccent,
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255), // Make text fully visible
                  fontSize: 18, // Larger font size
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                  labelText: "Username",
                  labelStyle: TextStyle(
                    color: const Color.fromARGB(221, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  hintText: "Enter your username",
                  hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 🔒 Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: Colors.blueAccent,
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 254, 254), // Make text fully visible
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: const Color.fromARGB(221, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // 🚀 Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: const Color.fromARGB(197, 80, 24, 170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        )
                      : Text("Login", style: TextStyle(color: Colors.white)),
                ),
              ),

              SizedBox(height: 20),

              // ❗ Error message
              if (_loginResponse.isNotEmpty)
                Text(
                  _loginResponse,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
