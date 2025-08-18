import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flask Test',
      theme: ThemeData.dark(),
      home: PingPage(),
    );
  }
}

class PingPage extends StatefulWidget {
  @override
  _PingPageState createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  String _response = "Press button to ping server";

  Future<void> _pingServer() async {
    try {
      final url = Uri.parse("http://192.168.254.109:5000/ping");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _response = data["message"];
        });
      } else {
        setState(() {
          _response = "Error: ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Failed to connect: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ping Flask Server")),
      body: Center(child: Text(_response)),
      floatingActionButton: FloatingActionButton(
        onPressed: _pingServer,
        child: Icon(Icons.send),
      ),
    );
  }
}
