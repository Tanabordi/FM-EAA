import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../shared/utils/environment.dart';
import '../domain/models/family_member.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(apiClient: ApiClient());
});

class FamilyMembersState {
  final List<FamilyMemberItem> members;
  final bool isLoading;
  final String? errorMessage;

  const FamilyMembersState({
    this.members = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FamilyMembersState copyWith({
    List<FamilyMemberItem>? members,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FamilyMembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FamilyMembersNotifier extends StateNotifier<FamilyMembersState> {
  final FamilyRepository _repo;
  final String fridgeId;
  Timer? _pollTimer;

  FamilyMembersNotifier(this._repo, this.fridgeId)
      : super(const FamilyMembersState(isLoading: true)) {
    loadMembers();
    _startPolling();
  }

  void _startPolling() {
    if (isTestEnvironment()) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _silentReload();
    });
  }

  Future<void> _silentReload() async {
    try {
      final list = await _repo.getMembers(fridgeId);
      state = state.copyWith(members: list);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getMembers(fridgeId);
      state = state.copyWith(members: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> removeMember(String userId) async {
    final previous = state.members;
    // Optimistic removal
    state = state.copyWith(
      members: previous.where((m) => m.id != userId).toList(),
    );
    try {
      await _repo.removeMember(fridgeId, userId);
    } catch (e) {
      // Revert if failed
      state = state.copyWith(members: previous, errorMessage: e.toString());
      rethrow;
    }
  }
}

final familyMembersProvider = StateNotifierProvider.family<
    FamilyMembersNotifier, FamilyMembersState, String>((ref, fridgeId) {
  final repo = ref.watch(familyRepositoryProvider);
  return FamilyMembersNotifier(repo, fridgeId);
});
