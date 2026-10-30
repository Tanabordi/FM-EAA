import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/fridge_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/fridge_repository.dart';

class FridgesNotifier extends StateNotifier<List<FridgeModel>> {
  static final List<FridgeModel> defaultFridges = [
    FridgeModel(
      id: 'fridge_studio',
      name: 'Studio',
      description: '2nd floor',
      ownerId: 'user_1',
      memberCount: 1,
      itemCount: 0,
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

  /// Initialized with default mock data so Screen #5 Populated State (Image 10) is visible immediately.
  /// Calling clearAll() transitions to Screen #5 Empty State (Image 1).
  FridgesNotifier({bool startEmpty = false})
      : super(startEmpty ? [] : defaultFridges);

  void loadMockData() {
    state = defaultFridges;
  }

  void addFridge(String name, String description) {
    final newFridge = FridgeModel(
      id: 'fridge_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      ownerId: 'user_1',
      memberCount: 1,
      itemCount: 0,
      updatedAt: DateTime.now(),
    );
    state = [...state, newFridge];
  }

  void updateFridge(String id, String name, String description) {
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
  }

  void removeFridge(String id) {
    state = state.where((f) => f.id != id).toList();
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

final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return FridgeRepository(apiClient: ApiClient());
});

final fridgesProvider = StateNotifierProvider<FridgesNotifier, List<FridgeModel>>((ref) {
  return FridgesNotifier(startEmpty: true);
});
