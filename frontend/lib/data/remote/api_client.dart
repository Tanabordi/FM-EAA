import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized Dio API Client for communicating with the Node.js backend.
class ApiClient {
  /// Centralized API Base URL. Defaults to Render Cloud Production Backend.
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return 'https://fm-eaa-backend.onrender.com/api';
  }

  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({Dio? customDio, FlutterSecureStorage? customStorage})
      : dio = customDio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 35),
              receiveTimeout: const Duration(seconds: 35),
            )),
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
