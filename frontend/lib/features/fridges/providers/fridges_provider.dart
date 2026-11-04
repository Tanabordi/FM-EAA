import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/fridge_model.dart';
import '../../../data/repositories/fridge_repository.dart';
import '../../../shared/utils/environment.dart';

class FridgesNotifier extends StateNotifier<List<FridgeModel>> {
  final FridgeRepository? _repository;
  Timer? _pollingTimer;

  static final List<FridgeModel> defaultFridges = [
    FridgeModel(
      id: 'fridge_studio',
      name: 'Studio',
      description: '2nd floor',
      ownerId: 'user_1',
      memberCount: 1,
      itemCount: 35,
      updatedAt: DateTime.now(),
    ),
    FridgeModel(
      id: 'fridge_kitchen',
      name: 'Kitchen',
      description: '1st floor',
      ownerId: 'user_1',
      memberCount: 2,
      itemCount: 35,
      updatedAt: DateTime.now(),
    ),
  ];

  FridgesNotifier([this._repository, bool? startEmpty])
      : super((startEmpty ?? (_repository != null)) ? [] : defaultFridges) {
    if (_repository != null) {
      loadFridges();
      _startPolling();
    }
  }

  void _startPolling() {
    if (isTestEnvironment()) return;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      loadFridges();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadFridges() async {
    try {
      final fridges = await _repository?.getFridges();
      if (fridges != null) {
        state = fridges;
      }
    } catch (_) {}
  }

  void loadMockData() {
    state = defaultFridges;
  }

  List<FridgeModel> get currentFridges => state;

  /// Creates fridge via repository (Cloud DB + local Drift) and updates state
  Future<void> addFridge(String name, String description, {String? userId}) async {
    final previousState = state;
    try {
      if (_repository != null) {
        final created = await _repository.createFridge(
          name,
          description,
          ownerId: userId ?? 'user_1',
        );
        state = [...state.where((f) => f.id != created.id), created];
      } else {
        final newFridge = FridgeModel(
          id: 'fridge_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          description: description,
          ownerId: userId ?? 'user_1',
          updatedAt: DateTime.now(),
        );
        state = [...state, newFridge];
      }
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateFridge(String id, String name, String description) async {
    final previousState = state;
    state = [
      for (final f in state)
        if (f.id == id)
          f.copyWith(
            name: name,
            description: description,
            updatedAt: DateTime.now(),
            isSynced: false,
          )
        else
          f
    ];
    try {
      await _repository?.updateFridge(id, name, description);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  /// Optimistic UI: Removes from local state immediately, then removes from Drift SQLite with rollback protection
  Future<void> removeFridge(String id) async {
    final previousState = state;
    state = state.where((f) => f.id != id).toList();
    try {
      await _repository?.deleteFridge(id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> leaveFridge(String id, String? userId) async {
    final previousState = state;
    state = state.where((f) => f.id != id).toList();
    try {
      if (userId != null && userId.isNotEmpty) {
        await _repository?.leaveFridge(id, userId);
      } else {
        await _repository?.deleteFridge(id);
      }
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  void clearAll() {
    state = [];
  }

  void updateItemCount(String id, int count) {
    state = [
      for (final f in state)
        if (f.id == id)
          f.copyWith(itemCount: count, updatedAt: DateTime.now())
        else
          f
    ];
  }
}

final fridgesProvider = StateNotifierProvider<FridgesNotifier, List<FridgeModel>>((ref) {
  final repo = ref.watch(fridgeRepositoryProvider);
  return FridgesNotifier(repo, true);
});
