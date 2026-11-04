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
        onError: (DioException error, handler) async {
          // If remote backend returned 404 or connection error, retry against local backend
          final requestOptions = error.requestOptions;
          final currentBase = requestOptions.baseUrl;
          if (!currentBase.contains('localhost:5001') &&
              (error.response?.statusCode == 404 ||
                  error.type == DioExceptionType.connectionError)) {
            try {
              final localOptions = requestOptions.copyWith(
                baseUrl: 'http://localhost:5001/api',
              );
              final response = await dio.fetch(localOptions);
              return handler.resolve(response);
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );
  }
}
