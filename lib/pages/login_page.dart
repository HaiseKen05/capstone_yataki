import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

      debugPrint("📡 Login response: ${response.statusCode} ${response.data}");

      // ✅ Successful login
      if (response.statusCode == 200 && response.data["status"] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(username: _usernameController.text),
          ),
        );
      } else {
        setState(() {
          _loginResponse =
              response.data["message"] ??
              "An unexpected error occurred. Please try again.";
        });
      }
    } on DioException catch (dioError) {
      debugPrint(
        "❌ Dio error: ${dioError.response?.statusCode} - ${dioError.message}",
      );

      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;

        if (statusCode == 401) {
          // ❌ Wrong username or password
          setState(() {
            _loginResponse = "Wrong username or password. Please try again.";
          });
        } else if (statusCode == 500) {
          // ❌ Server internal error
          setState(() {
            _loginResponse = "Server error. Please try again later.";
          });
        } else {
          // ❌ Other HTTP error
          setState(() {
            _loginResponse =
                "Login failed (Error $statusCode). Please try again later.";
          });
        }
      } else {
        // ❌ Network or server unreachable
        setState(() {
          _loginResponse =
              "Unable to connect to the server. Please check your network.";
        });
      }
    } catch (e) {
      debugPrint("⚠️ Unexpected error: $e");
      setState(() {
        _loginResponse = "An unexpected error occurred. Please try again.";
      });
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
              const SizedBox(height: 60),

              // 🌐 App Logo
              Image.asset('assets/images/output.png', height: 100),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(221, 235, 235, 235),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Log in to continue monitoring your kinetic energy system",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 255, 253, 253),
                ),
              ),
              const SizedBox(height: 40),

              // 📝 Username Input
              TextField(
                controller: _usernameController,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                  ),
                  labelText: "Username",
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(221, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  hintText: "Enter your username",
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔒 Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 254, 254),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                  labelText: "Password",
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(221, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 🚀 Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: const Color.fromARGB(197, 80, 24, 170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ❗ Error message
              if (_loginResponse.isNotEmpty)
                Text(
                  _loginResponse,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
