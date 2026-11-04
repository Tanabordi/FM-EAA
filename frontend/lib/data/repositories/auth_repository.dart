import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../remote/api_client.dart';

class GoogleAuthResult {
  final bool isNewUser;
  final UserModel? user;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAuthResult({
    required this.isNewUser,
    this.user,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}

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
      final user = UserModel.fromJson(userJson);

      await apiClient.storage.write(key: 'user_id', value: user.id);
      await apiClient.storage.write(key: 'user_username', value: user.username);
      await apiClient.storage.write(key: 'user_email', value: user.email);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await logout();
        return null;
      }
      final userId = await apiClient.storage.read(key: 'user_id');
      final username = await apiClient.storage.read(key: 'user_username');
      final email = await apiClient.storage.read(key: 'user_email');
      if (userId != null && username != null && email != null) {
        return UserModel(
          id: userId,
          username: username,
          email: email,
          updatedAt: DateTime.now(),
        );
      }
      return null;
    } catch (_) {
      final userId = await apiClient.storage.read(key: 'user_id');
      final username = await apiClient.storage.read(key: 'user_username');
      final email = await apiClient.storage.read(key: 'user_email');
      if (userId != null && username != null && email != null) {
        return UserModel(
          id: userId,
          username: username,
          email: email,
          updatedAt: DateTime.now(),
        );
      }
      return null;
    }
  }

  GoogleSignIn _buildGoogleSignIn() {
    return GoogleSignIn(
      clientId: kIsWeb
          ? '516658327353-do6p38rdv13tc6k5o83g5r3va0u1be2n.apps.googleusercontent.com'
          : null,
      serverClientId: kIsWeb
          ? null
          : '516658327353-do6p38rdv13tc6k5o83g5r3va0u1be2n.apps.googleusercontent.com',
      scopes: ['email', 'openid', 'profile'],
    );
  }

  Future<GoogleAuthResult> signInWithGoogle({GoogleSignIn? googleSignInOverride}) async {
    try {
      final googleSignIn = googleSignInOverride ?? _buildGoogleSignIn();

      // Clear any cached account state to ensure the Google account chooser is displayed
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if ((idToken == null || idToken.isEmpty) && (accessToken == null || accessToken.isEmpty)) {
        throw Exception('Failed to retrieve Google authentication token. Please try again.');
      }

      final googleName = account.displayName;
      final googlePhoto = account.photoUrl;
      final response = await apiClient.dio.post(
        '/auth/google',
        data: {
          if (idToken != null && idToken.isNotEmpty) 'idToken': idToken,
          if (accessToken != null && accessToken.isNotEmpty) 'accessToken': accessToken,
          if (googleName != null && googleName.isNotEmpty)
            'displayName': googleName,
          if (googlePhoto != null && googlePhoto.isNotEmpty)
            'photoUrl': googlePhoto,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final isNewUser = data['isNewUser'] == true || data['user'] == null;

      if (isNewUser) {
        return GoogleAuthResult(
          isNewUser: true,
          email: (data['email'] as String?) ?? account.email,
          displayName: (data['displayName'] as String?) ?? account.displayName,
          photoUrl: (data['photoUrl'] as String?) ?? account.photoUrl,
        );
      }

      final token = data['token'] as String?;
      if (token != null) {
        await apiClient.storage.write(key: 'jwt_token', value: token);
      }

      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);
      await apiClient.storage.write(key: 'user_id', value: user.id);
      await apiClient.storage.write(key: 'user_username', value: user.username);
      await apiClient.storage.write(key: 'user_email', value: user.email);
      if (user.avatarUrl != null) {
        await apiClient.storage.write(key: 'user_avatar_url', value: user.avatarUrl);
      }

      return GoogleAuthResult(
        isNewUser: false,
        user: user,
        email: user.email,
        displayName: user.username,
        photoUrl: user.avatarUrl,
      );
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  Future<String?> pickGoogleEmail({GoogleSignIn? googleSignInOverride}) async {
    try {
      final googleSignIn = googleSignInOverride ?? _buildGoogleSignIn();
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      final account = await googleSignIn.signIn();
      return account?.email.trim();
    } catch (_) {
      return null;
    }
  }

  Future<String> uploadAvatar(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await apiClient.dio.post(
        '/users/me/avatar',
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      final avatarUrl = (data['avatarUrl'] ?? data['user']?['avatarUrl']) as String;
      await apiClient.storage.write(key: 'user_avatar_url', value: avatarUrl);
      return avatarUrl;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
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
      await apiClient.storage.delete(key: 'user_avatar_url');
    } catch (_) {}

    try {
      final googleSignIn = _buildGoogleSignIn();
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/verify-otp',
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
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

