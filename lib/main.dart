import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api/api_client.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  // Ensure Flutter engine is initialized before async code
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Initialize API Client with either saved or default URLs
  await ApiClient.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter-Flask Test',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: HomePage(),
    );
  }
}
