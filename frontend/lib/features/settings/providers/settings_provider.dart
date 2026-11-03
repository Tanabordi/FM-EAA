import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/auth_repository.dart';

import '../../auth/providers/auth_provider.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiClient: ApiClient());
});

/// StateNotifier to manage user profile state (Screen #22 Settings & Screen #23 Edit Profile)
class UserProfileNotifier extends StateNotifier<UserModel> {
  static final UserModel defaultUser = UserModel(
    id: 'user_1',
    username: 'Alex Lee',
    email: 'alex.lee@example.com',
    avatarUrl: null,
    updatedAt: DateTime.now(),
  );

  final Ref? _ref;

  UserProfileNotifier([UserModel? initialUser, this._ref])
      : super(initialUser ?? defaultUser);

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

    // Call backend API if user is authenticated
    if (_ref != null && _ref.read(authProvider).isAuthenticated) {
      final apiClient = _ref.read(authRepositoryProvider).apiClient;
      final response = await apiClient.dio.patch(
        '/users/me',
        data: {
          'username': trimmedName,
          'email': trimmedEmail,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
          if (currentPassword != null) 'currentPassword': currentPassword,
          if (newPassword != null) 'newPassword': newPassword,
        },
      );
      if (response.data != null && response.data['user'] != null) {
        final serverUser = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
        state = serverUser;
        _ref.read(authProvider.notifier).updateUser(serverUser);
        return;
      }
    }

    // Update local state reactively
    final updated = state.copyWith(
      username: trimmedName,
      email: trimmedEmail,
      avatarUrl: avatarUrl,
      clearAvatar: clearAvatar,
      updatedAt: DateTime.now(),
    );
    state = updated;

    // Sync back to authProvider
    if (_ref != null) {
      _ref.read(authProvider.notifier).updateUser(updated);
    }
  }

  void resetToDefault() {
    state = defaultUser;
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserModel>((ref) {
  final authUser = ref.watch(authProvider.select((s) => s.user));
  return UserProfileNotifier(authUser ?? UserProfileNotifier.defaultUser, ref);
});

final settingsLoadingProvider = StateProvider<bool>((ref) => false);
