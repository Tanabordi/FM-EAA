import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../remote/api_client.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<UserModel> signInWithPassword(String identifier, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'identifier': identifier.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await apiClient.storage.write(key: 'jwt_token', value: token);
      }

      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);
      await apiClient.storage.write(key: 'user_id', value: user.id);
      await apiClient.storage.write(key: 'user_username', value: user.username);
      await apiClient.storage.write(key: 'user_email', value: user.email);

      return user;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  Future<UserModel> createAccount(String username, String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'username': username.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await apiClient.storage.write(key: 'jwt_token', value: token);
      }

      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);
      await apiClient.storage.write(key: 'user_id', value: user.id);
      await apiClient.storage.write(key: 'user_username', value: user.username);
      await apiClient.storage.write(key: 'user_email', value: user.email);

      return user;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  Future<UserModel?> restoreSession() async {
    try {
      final token = await apiClient.storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return null;

      final response = await apiClient.dio.get('/auth/me');
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    // Stubs for future extensions
    throw UnimplementedError('Google sign in is not yet enabled');
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.storage.delete(key: 'jwt_token');
      await apiClient.storage.delete(key: 'user_id');
      await apiClient.storage.delete(key: 'user_username');
      await apiClient.storage.delete(key: 'user_email');
    } catch (_) {}
  }

  Exception _parseDioError(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      final errorData = e.response!.data as Map<String, dynamic>;
      final msg = errorData['error'] ?? errorData['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        return Exception(msg.toString());
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timed out. Please try again.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception(
        'Cannot connect to backend server at ${apiClient.dio.options.baseUrl}. Please ensure the backend is running.',
      );
    }
    return Exception(e.message ?? 'An unexpected network error occurred.');
  }
}

