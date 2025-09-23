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
  static const _handshakeUrlKey = 'custom_handshake_url';

  /// Initialize Dio with either saved URL or fallback to .env
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final baseUrl =
        prefs.getString(_baseUrlKey) ?? dotenv.env['BASE_URL'] ?? "http://localhost:5000/api/v1";

    final handshakeUrl =
        prefs.getString(_handshakeUrlKey) ?? dotenv.env['HANDSHAKE_URL'] ?? "http://localhost:5000/handshake";

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    );

    _currentHandshakeUrl = handshakeUrl;
  }

  static String _currentHandshakeUrl = "http://localhost:5000/handshake";

  static String get handshakeUrl => _currentHandshakeUrl;

  /// Update the server URLs dynamically at runtime
  static Future<void> updateServerUrls({
    required String baseUrl,
    required String handshakeUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_baseUrlKey, baseUrl);
    await prefs.setString(_handshakeUrlKey, handshakeUrl);

    dio.options.baseUrl = baseUrl;
    _currentHandshakeUrl = handshakeUrl;
  }
}
