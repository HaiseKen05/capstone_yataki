import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final CookieJar cookieJar = CookieJar();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? "http://localhost:5000",
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  )..interceptors.add(CookieManager(cookieJar));

  static String get handshakeUrl =>
      dotenv.env['HANDSHAKE_URL'] ?? "http://localhost:5000/handshake";
}
