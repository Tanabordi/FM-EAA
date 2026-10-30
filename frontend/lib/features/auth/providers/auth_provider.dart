import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiClient: ApiClient());
});

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;

  const AuthState({this.user, this.isAuthenticated = false, this.isLoading = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  // TODO(auth state): Implement user session restore from FlutterSecureStorage
  Future<void> signIn(String identifier, String password) async {
    state = const AuthState(isLoading: true);
    // Placeholder login state
    state = AuthState(
      isAuthenticated: true,
      user: UserModel(
        id: 'user_1',
        username: 'alex.lee',
        email: 'alex@example.com',
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

