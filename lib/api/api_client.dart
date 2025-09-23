import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final CookieJar cookieJar = CookieJar();
  static final Dio dio = Dio()
    ..interceptors.add(CookieManager(cookieJar));

  static const _baseUrlKey = 'custom_base_url';

  static String _currentBaseUrl = "http://<Change this to your local Server IP Address>/api/v1";

  /// The handshake URL is automatically derived from the base URL
  static String get handshakeUrl {
    // Example: baseUrl = http://192.168.1.50:5000/api/v1
    // handshakeUrl becomes http://192.168.1.50:5000/handshake
    final uri = Uri.parse(_currentBaseUrl);
    return "${uri.scheme}://${uri.host}:${uri.port}/handshake";
  }

  /// Initialize Dio with either saved URL or fallback to .env
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Get saved base URL or fallback to .env
    _currentBaseUrl = prefs.getString(_baseUrlKey) ??
        dotenv.env['BASE_URL'] ??
        "http://localhost:5000/api/v1";

    // Configure Dio instance
    dio.options = BaseOptions(
      baseUrl: _currentBaseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    );
  }

  /// Update the base URL dynamically at runtime
  static Future<void> updateBaseUrl(String newBaseUrl) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_baseUrlKey, newBaseUrl);

    _currentBaseUrl = newBaseUrl;
    dio.options.baseUrl = _currentBaseUrl;
  }

  /// Get the current base URL
  static String get baseUrl => _currentBaseUrl;
}
