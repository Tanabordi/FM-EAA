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

  /// Optimistic UI: Updates local state immediately, then asynchronously persists to Drift SQLite with is_synced = false
  void addFridge(String name, String description) {
    final newFridge = FridgeModel(
      id: 'fridge_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      ownerId: 'user_1',
      memberCount: 1,
      isSynced: false, // Optimistic UI: marked not synced
      updatedAt: DateTime.now(),
    );
    state = [...state, newFridge];

    // Asynchronous local SQLite persistence
    _repository?.createFridge(name, description);
  }

  /// Optimistic UI: Removes from local state immediately, then removes from Drift SQLite
  void removeFridge(String id) {
    state = state.where((f) => f.id != id).toList();
    _repository?.deleteFridge(id);
  }
}

final fridgesProvider = StateNotifierProvider<FridgesNotifier, List<FridgeModel>>((ref) {
  final repo = ref.watch(fridgeRepositoryProvider);
  return FridgesNotifier(repo);
});
