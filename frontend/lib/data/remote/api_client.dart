import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized Dio API Client for communicating with the Node.js backend.
class ApiClient {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:5001/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    } catch (_) {}
    return 'http://localhost:5001/api';
  }

  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({Dio? customDio, FlutterSecureStorage? customStorage})
      : dio = customDio ?? Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10))),
        storage = customStorage ?? const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await storage.read(key: 'jwt_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}
