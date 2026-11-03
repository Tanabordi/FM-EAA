import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized Dio API Client for communicating with the Node.js backend.
class ApiClient {
  static const String baseUrl = 'http://localhost:5000/api';
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
          // TODO(auth token): Attach Bearer token from secure storage
          final token = await storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // TODO(error handling): Handle 401 Unauthorized token refresh
          return handler.next(error);
        },
      ),
    );
  }
}

