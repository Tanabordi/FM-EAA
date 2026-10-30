import '../models/user_model.dart';
import '../remote/api_client.dart';

// TODO(repo auth): Implement actual login/register API calls and JWT storage
class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<UserModel> signInWithPassword(String identifier, String password) async {
    // TODO: POST /api/auth/login
    throw UnimplementedError();
  }

  Future<UserModel> createAccount(String username, String email, String password) async {
    // TODO: POST /api/auth/register
    throw UnimplementedError();
  }

  Future<UserModel> signInWithGoogle() async {
    // TODO: GoogleSignIn SDK + POST /api/auth/google
    throw UnimplementedError();
  }

  Future<void> sendPasswordReset(String email) async {
    // TODO: POST /api/auth/forgot-password
    throw UnimplementedError();
  }

  Future<void> logout() async {
    // TODO: Clear token from FlutterSecureStorage
  }
}

