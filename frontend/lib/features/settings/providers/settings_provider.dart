import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/auth_repository.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiClient: ApiClient());
});

/// StateNotifier to manage user profile state (Screen #22 Settings & Screen #23 Edit Profile)
class UserProfileNotifier extends StateNotifier<UserModel> {
  final AuthRepository? _authRepository;

  static final UserModel defaultUser = UserModel(
    id: 'user_1',
    username: 'Alex Lee',
    email: 'alex.lee@example.com',
    avatarUrl: null,
    updatedAt: DateTime.now(),
  );

  UserProfileNotifier([this._authRepository]) : super(defaultUser);

  /// Update user profile details with validation
  Future<void> updateProfile({
    required String name,
    required String email,
    String? avatarUrl,
    bool clearAvatar = false,
    String? currentPassword,
    String? newPassword,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw ArgumentError('Invalid email format');
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw ArgumentError('Current password is required to set a new password');
      }
      if (newPassword.length < 8) {
        throw ArgumentError('New password must be at least 8 characters long');
      }
    }

    // Update local state reactively
    state = state.copyWith(
      username: trimmedName,
      email: trimmedEmail,
      avatarUrl: avatarUrl,
      clearAvatar: clearAvatar,
      updatedAt: DateTime.now(),
    );
  }

  void resetToDefault() {
    state = defaultUser;
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserModel>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return UserProfileNotifier(authRepo);
});

final settingsLoadingProvider = StateProvider<bool>((ref) => false);
