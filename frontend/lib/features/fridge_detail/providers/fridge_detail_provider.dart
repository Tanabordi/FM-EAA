import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';

class FridgeFilterState {
  final String category; // 'All', 'Proteins', etc.
  final String zone; // 'fridge' | 'freezer'

  const FridgeFilterState({this.category = 'All', this.zone = 'fridge'});

  FridgeFilterState copyWith({String? category, String? zone}) {
    return FridgeFilterState(
      category: category ?? this.category,
      zone: zone ?? this.zone,
    );
  }
}

class FridgeFilterNotifier extends StateNotifier<FridgeFilterState> {
  FridgeFilterNotifier() : super(const FridgeFilterState());

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setZone(String zone) {
    state = state.copyWith(zone: zone);
  }
}

final fridgeDetailFilterProvider = StateNotifierProvider<FridgeFilterNotifier, FridgeFilterState>((ref) {
  return FridgeFilterNotifier();
});

final fridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final filter = ref.watch(fridgeDetailFilterProvider);

  // Mock list for skeleton
  final allItems = [
    ItemModel(
      id: 'item_1',
      fridgeId: fridgeId,
      name: 'Pork Tenderloin',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    ItemModel(
      id: 'item_2',
      fridgeId: fridgeId,
      name: 'Fresh Milk',
      category: 'beverages',
      zone: 'fridge',
      quantity: 2,
      unit: 'bottles',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    ItemModel(
      id: 'item_3',
      fridgeId: fridgeId,
      name: 'Cabbage',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'head',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  return allItems.where((item) {
    final matchesZone = item.zone == filter.zone;
    final matchesCategory = filter.category == 'All' || item.category.toLowerCase() == filter.category.toLowerCase();
    return matchesZone && matchesCategory;
  }).toList();
});

