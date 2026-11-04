import 'dart:io';
import 'package:flutter/foundation.dart';
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
              connectTimeout: const Duration(seconds: 45),
              receiveTimeout: const Duration(seconds: 45),
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
          // If remote backend returned 404, connection error, or timeout, retry against local backend
          final requestOptions = error.requestOptions;
          final currentBase = requestOptions.baseUrl;
          final isLocal = currentBase.contains('localhost:5001') || currentBase.contains('10.0.2.2:5001');
          if (!isLocal &&
              (error.response?.statusCode == 404 ||
                  error.type == DioExceptionType.connectionError ||
                  error.type == DioExceptionType.connectionTimeout)) {
            try {
              final localBase = (!kIsWeb && Platform.isAndroid)
                  ? 'http://10.0.2.2:5001/api'
                  : 'http://localhost:5001/api';
              final localOptions = requestOptions.copyWith(
                baseUrl: localBase,
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
