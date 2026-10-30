import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/fridge_model.dart';

class FridgesNotifier extends StateNotifier<List<FridgeModel>> {
  FridgesNotifier()
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

  void addFridge(String name, String description) {
    final newFridge = FridgeModel(
      id: 'fridge_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      ownerId: 'user_1',
      memberCount: 1,
      updatedAt: DateTime.now(),
    );
    state = [...state, newFridge];
  }

  void removeFridge(String id) {
    state = state.where((f) => f.id != id).toList();
  }
}

final fridgesProvider = StateNotifierProvider<FridgesNotifier, List<FridgeModel>>((ref) {
  return FridgesNotifier();
});

