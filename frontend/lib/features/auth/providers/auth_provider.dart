import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_service.dart';
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

  AuthNotifier(this._repo) : super(const AuthState()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.restoreSession();
      if (user != null) {
        state = AuthState(isAuthenticated: true, user: user);
        NotificationService().syncFcmTokenWithBackend();
      } else {
        state = const AuthState(isAuthenticated: false);
      }
    } catch (_) {
      state = const AuthState(isAuthenticated: false);
    }
  }

  Future<void> signIn(String identifier, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.signInWithPassword(identifier, password);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      NotificationService().syncFcmTokenWithBackend();
    } catch (e) {
      state = const AuthState(isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.createAccount(username, email, password);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      NotificationService().syncFcmTokenWithBackend();
    } catch (e) {
      state = const AuthState(isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await NotificationService().removeFcmTokenFromBackend();
    } catch (_) {}
    state = const AuthState(isAuthenticated: false);
    try {
      await _repo.logout();
    } catch (_) {}
  }

  Future<GoogleAuthResult> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      final result = await _repo.signInWithGoogle();
      if (!result.isNewUser && result.user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: result.user,
        );
        NotificationService().syncFcmTokenWithBackend();
      } else {
        state = const AuthState(isAuthenticated: false);
      }
      return result;
    } catch (e) {
      state = const AuthState(isAuthenticated: false);
      rethrow;
    }
  }

  Future<String?> pickGoogleEmail() async {
    return _repo.pickGoogleEmail();
  }

  void updateUser(UserModel user) {
    state = AuthState(
      isAuthenticated: true,
      user: user,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
