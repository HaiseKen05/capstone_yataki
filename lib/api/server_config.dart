import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static const String _serverUrlKey = 'server_url';

  // Save URL
  static Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }

  // Load URL
  static Future<String?> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey);
  }

  // Fallback if no URL is set
  static Future<String> getServerUrlOrDefault() async {
    final url = await getServerUrl();
    return url ?? "http://<<YOUR SERVER'S IP>>:5000"; // default
  }
}
