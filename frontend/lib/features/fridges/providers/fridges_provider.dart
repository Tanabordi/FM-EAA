import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/fridge_model.dart';
import '../../../data/repositories/fridge_repository.dart';

class FridgesNotifier extends StateNotifier<List<FridgeModel>> {
  final FridgeRepository? _repository;

  FridgesNotifier([this._repository])
      : super([
          FridgeModel(
            id: 'fridge_kitchen',
            name: 'Kitchen',
            description: '1st floor',
            ownerId: 'user_1',
            memberCount: 3,
            updatedAt: DateTime.now(),
          ),
          FridgeModel(
            id: 'fridge_studio',
            name: 'Studio',
            description: '2nd floor',
            ownerId: 'user_1',
            memberCount: 1,
            updatedAt: DateTime.now(),
          ),
        ]);

  List<FridgeModel> get currentFridges => state;

  /// Optimistic UI: Updates local state immediately, then asynchronously persists to Drift SQLite with rollback protection
  Future<void> addFridge(String name, String description, {String? userId}) async {
    final previousState = state;
    final newFridge = FridgeModel(
      id: 'fridge_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      ownerId: userId ?? 'user_1',
      memberCount: 1,
      isSynced: false, // Optimistic UI: marked not synced
      updatedAt: DateTime.now(),
    );
    state = [...state, newFridge];

    // Asynchronous local SQLite persistence with rollback protection
    try {
      await _repository?.createFridge(
        name,
        description,
        id: newFridge.id,
        ownerId: userId ?? 'user_1',
      );
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
}

final fridgesProvider = StateNotifierProvider<FridgesNotifier, List<FridgeModel>>((ref) {
  final repo = ref.watch(fridgeRepositoryProvider);
  return FridgesNotifier(repo);
});
