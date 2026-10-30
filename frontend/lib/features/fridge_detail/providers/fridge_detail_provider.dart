import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';

class FridgeFilterState {
  final String category; // 'All', 'Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces'
  final String zone; // 'fridge' | 'freezer'
  final String searchQuery;

  const FridgeFilterState({
    this.category = 'All',
    this.zone = 'fridge',
    this.searchQuery = '',
  });

  FridgeFilterState copyWith({
    String? category,
    String? zone,
    String? searchQuery,
  }) {
    return FridgeFilterState(
      category: category ?? this.category,
      zone: zone ?? this.zone,
      searchQuery: searchQuery ?? this.searchQuery,
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final fridgeDetailFilterProvider =
    StateNotifierProvider<FridgeFilterNotifier, FridgeFilterState>((ref) {
  return FridgeFilterNotifier();
});

/// Raw list of all items in a fridge before filtering
final allFridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final now = DateTime.now();

  return [
    // --- FRIDGE ZONE ITEMS ---
    ItemModel(
      id: 'item_spinach',
      fridgeId: fridgeId,
      name: 'Baby spinach',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'bag · 150 g',
      expiryDate: DateTime(now.year, now.month, now.day - 1), // Yesterday (Expired)
      imagePath: 'assets/images/food_spinach.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_strawberries',
      fridgeId: fridgeId,
      name: 'Strawberries',
      category: 'veggies',
      zone: 'fridge',
      quantity: 2,
      unit: 'punnet · 250 g',
      expiryDate: DateTime(now.year, now.month, now.day + 2), // 2 days left (Use soon)
      imagePath: 'assets/images/food_strawberries.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_avocados',
      fridgeId: fridgeId,
      name: 'Avocados',
      category: 'veggies',
      zone: 'fridge',
      quantity: 2,
      unit: 'pieces',
      expiryDate: DateTime(now.year, now.month, now.day + 5), // 5 days left (Fresh)
      imagePath: 'assets/images/food_avocados.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_milk',
      fridgeId: fridgeId,
      name: 'Whole milk',
      category: 'beverages',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 1 L',
      expiryDate: DateTime(now.year, now.month, now.day + 7), // 7 days left (Fresh)
      imagePath: 'assets/images/food_milk.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_chicken',
      fridgeId: fridgeId,
      name: 'Chicken Breast',
      category: 'proteins',
      zone: 'fridge',
      quantity: 2,
      unit: 'fillets · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 3),
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_lasagna',
      fridgeId: fridgeId,
      name: 'Lasagna',
      category: 'meals',
      zone: 'fridge',
      quantity: 1,
      unit: 'portion',
      expiryDate: DateTime(now.year, now.month, now.day + 2),
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_tomato_sauce',
      fridgeId: fridgeId,
      name: 'Tomato Sauce',
      category: 'sauces',
      zone: 'fridge',
      quantity: 1,
      unit: 'jar · 350 g',
      expiryDate: DateTime(now.year, now.month, now.day + 14),
      updatedAt: now,
    ),

    // --- FREEZER ZONE ITEMS ---
    ItemModel(
      id: 'item_pork',
      fridgeId: fridgeId,
      name: 'Pork Tenderloin',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 15),
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_salmon',
      fridgeId: fridgeId,
      name: 'Salmon Fillet',
      category: 'proteins',
      zone: 'freezer',
      quantity: 2,
      unit: 'fillets',
      expiryDate: DateTime(now.year, now.month, now.day + 20),
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_icecream',
      fridgeId: fridgeId,
      name: 'Vanilla Ice Cream',
      category: 'meals',
      zone: 'freezer',
      quantity: 1,
      unit: 'tub · 450 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 30),
      updatedAt: now,
    ),
    ItemModel(
      id: 'item_peas',
      fridgeId: fridgeId,
      name: 'Green Peas',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      updatedAt: now,
    ),
  ];
});

/// Filtered items for FridgeDetailPage based on Zone, Category, and In-place Search
final fridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final filter = ref.watch(fridgeDetailFilterProvider);
  final allItems = ref.watch(allFridgeItemsProvider(fridgeId));

  final filtered = allItems.where((item) {
    final matchesZone = item.zone == filter.zone;
    final matchesCategory = filter.category == 'All' ||
        item.category.toLowerCase() == filter.category.toLowerCase();
    final matchesSearch = filter.searchQuery.trim().isEmpty ||
        item.name.toLowerCase().contains(filter.searchQuery.trim().toLowerCase());

    return matchesZone && matchesCategory && matchesSearch;
  }).toList();

  filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  return filtered;
});
