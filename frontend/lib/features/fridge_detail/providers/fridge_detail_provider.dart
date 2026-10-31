import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/item_repository.dart';

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

/// Watches items for a fridge from Drift SQLite Local Database via ItemRepository
final watchItemsInFridgeProvider = StreamProvider.family<List<ItemModel>, String>((ref, fridgeId) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchItems(fridgeId);
});

/// Raw list of all items in a fridge before filtering (combines Local DB with initial fallback)
final allFridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final streamItems = ref.watch(watchItemsInFridgeProvider(fridgeId)).value;
  if (streamItems != null && streamItems.isNotEmpty) {
    return streamItems;
  }
  return getInitialFridgeItems(fridgeId);
});

/// Dynamic filtered items connected to Drift SQLite Local DB Repository
final fridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final allItems = ref.watch(allFridgeItemsProvider(fridgeId));
  final filter = ref.watch(fridgeDetailFilterProvider);

  // If search query is present: search dynamically across all items in zone
  if (filter.searchQuery.trim().isNotEmpty) {
    final query = filter.searchQuery.trim().toLowerCase();
    return allItems.where((item) {
      return item.zone.toLowerCase() == filter.zone.toLowerCase() &&
          (item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query));
    }).toList();
  }

  final zoneItems = allItems.where((item) => item.zone.toLowerCase() == filter.zone.toLowerCase()).toList();
  final category = filter.category.toLowerCase();

  if (category == 'all') {
    // If we have live user items from DB, show all items in this zone
    final streamItems = ref.watch(watchItemsInFridgeProvider(fridgeId)).value;
    if (streamItems != null && streamItems.isNotEmpty) {
      return zoneItems;
    }
    // Overview mode matching exact Figma Screen #9 layout (4 featured items per zone)
    if (filter.zone == 'fridge') {
      const allIds = {'item_spinach', 'item_strawberries', 'item_avocados', 'item_milk'};
      return zoneItems.where((i) => allIds.contains(i.id)).toList();
    } else {
      const fzAllIds = {'fz_pork', 'fz_salmon', 'fz_pizza', 'fz_peas'};
      return zoneItems.where((i) => fzAllIds.contains(i.id)).toList();
    }
  }

  // Completely dynamic category filter without hardcoding any item IDs
  return zoneItems.where((item) => item.category.toLowerCase() == category).toList();
});

/// Initial standard items for pre-population / fallback with accurate expiryDates
List<ItemModel> getInitialFridgeItems(String fridgeId) {
  final now = DateTime.now();

  return [
    // ------------------------------------------
    // FRIDGE ZONE: Veggies
    // ------------------------------------------
    ItemModel(
      id: 'item_spinach',
      fridgeId: fridgeId,
      name: 'Baby spinach',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'bag · 150 g',
      expiryDate: DateTime(now.year, now.month, now.day - 1), // Yesterday -> Expired
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
      expiryDate: DateTime(now.year, now.month, now.day + 2), // 2 days left -> Use soon
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
      expiryDate: DateTime(now.year, now.month, now.day + 5), // 5 days left -> Fresh
      imagePath: 'assets/images/food_avocados.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'veg_cherry_tomatoes',
      fridgeId: fridgeId,
      name: 'Cherry Tomatoes',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'box · 250 g',
      expiryDate: DateTime(now.year, now.month, now.day + 4), // 4 days left -> Fresh
      imagePath: 'assets/images/food_cherry_tomatoes.png',
      updatedAt: now,
    ),

    // ------------------------------------------
    // FRIDGE ZONE: Beverages
    // ------------------------------------------
    ItemModel(
      id: 'item_milk',
      fridgeId: fridgeId,
      name: 'Whole milk',
      category: 'beverages',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 1 L',
      expiryDate: DateTime(now.year, now.month, now.day + 7), // 7 days left -> Fresh
      imagePath: 'assets/images/food_whole_milk.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'bev_orange_juice',
      fridgeId: fridgeId,
      name: 'Orange Juice',
      category: 'beverages',
      zone: 'fridge',
      quantity: 1,
      unit: 'carton · 1 L',
      expiryDate: DateTime(now.year, now.month, now.day + 6),
      imagePath: 'assets/images/food_orange_juice.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'bev_cold_brew',
      fridgeId: fridgeId,
      name: 'Cold Brew Coffee',
      category: 'beverages',
      zone: 'fridge',
      quantity: 2,
      unit: 'can · 250 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 14),
      imagePath: 'assets/images/food_cold_brew.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'bev_kombucha',
      fridgeId: fridgeId,
      name: 'Kombucha',
      category: 'beverages',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 330 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 20),
      imagePath: 'assets/images/food_kombucha.png',
      updatedAt: now,
    ),

    // ------------------------------------------
    // FRIDGE ZONE: Proteins
    // ------------------------------------------
    ItemModel(
      id: 'prot_chicken',
      fridgeId: fridgeId,
      name: 'Chicken Breasts',
      category: 'proteins',
      zone: 'fridge',
      quantity: 1,
      unit: 'pack · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 3),
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'prot_eggs',
      fridgeId: fridgeId,
      name: 'Eggs',
      category: 'proteins',
      zone: 'fridge',
      quantity: 10,
      unit: 'carton',
      expiryDate: DateTime(now.year, now.month, now.day + 12),
      imagePath: 'assets/images/food_eggs.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'prot_salmon',
      fridgeId: fridgeId,
      name: 'Salmon Fillets',
      category: 'proteins',
      zone: 'fridge',
      quantity: 2,
      unit: 'fillets · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 2), // 2 days left -> Use soon
      imagePath: 'assets/images/food_salmon_fillets.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'prot_tofu',
      fridgeId: fridgeId,
      name: 'Firm Tofu',
      category: 'proteins',
      zone: 'fridge',
      quantity: 1,
      unit: 'block · 350 g',
      expiryDate: DateTime(now.year, now.month, now.day + 8),
      imagePath: 'assets/images/food_firm_tofu.png',
      updatedAt: now,
    ),

    // ------------------------------------------
    // FRIDGE ZONE: Meals
    // ------------------------------------------
    ItemModel(
      id: 'meal_lasagna',
      fridgeId: fridgeId,
      name: 'Microwave Lasagna',
      category: 'meals',
      zone: 'fridge',
      quantity: 1,
      unit: 'tray · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 9),
      imagePath: 'assets/images/food_lasagna.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'meal_pizza',
      fridgeId: fridgeId,
      name: 'Frozen Pizza',
      category: 'meals',
      zone: 'fridge',
      quantity: 1,
      unit: 'box · 380 g',
      expiryDate: DateTime(now.year, now.month, now.day + 15),
      imagePath: 'assets/images/food_pizza.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'meal_dumplings',
      fridgeId: fridgeId,
      name: 'Pork Dumplings',
      category: 'meals',
      zone: 'fridge',
      quantity: 12,
      unit: 'pack · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 10),
      imagePath: 'assets/images/food_dumplings.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'meal_nuggets',
      fridgeId: fridgeId,
      name: 'Chicken Nuggets',
      category: 'meals',
      zone: 'fridge',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 25),
      imagePath: 'assets/images/food_nuggets.png',
      updatedAt: now,
    ),

    // ------------------------------------------
    // FRIDGE ZONE: Sauces
    // ------------------------------------------
    ItemModel(
      id: 'sauce_soy',
      fridgeId: fridgeId,
      name: 'Soy Sauce',
      category: 'sauces',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 500 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      imagePath: 'assets/images/food_soy_sauce.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'sauce_mayo',
      fridgeId: fridgeId,
      name: 'Mayonnaise',
      category: 'sauces',
      zone: 'fridge',
      quantity: 1,
      unit: 'squeeze · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      imagePath: 'assets/images/food_mayo.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'sauce_sriracha',
      fridgeId: fridgeId,
      name: 'Sriracha Sauce',
      category: 'sauces',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 450 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      imagePath: 'assets/images/food_sriracha.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'sauce_olive_oil',
      fridgeId: fridgeId,
      name: 'Olive Oil',
      category: 'sauces',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 750 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 120),
      imagePath: 'assets/images/food_olive_oil.png',
      updatedAt: now,
    ),

    // ------------------------------------------
    // FREEZER ZONE
    // ------------------------------------------
    ItemModel(
      id: 'fz_pork',
      fridgeId: fridgeId,
      name: 'Pork Tenderloin',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'pack · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_salmon',
      fridgeId: fridgeId,
      name: 'Salmon Fillet',
      category: 'proteins',
      zone: 'freezer',
      quantity: 2,
      unit: 'steaks · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      imagePath: 'assets/images/food_salmon_fillets.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_beef',
      fridgeId: fridgeId,
      name: 'Beef Ribeye Steak',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'cut · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_thighs',
      fridgeId: fridgeId,
      name: 'Chicken Thighs',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'pack · 600 g',
      expiryDate: DateTime(now.year, now.month, now.day + 30),
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_peas',
      fridgeId: fridgeId,
      name: 'Green Peas',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 450 g',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      imagePath: 'assets/images/food_spinach.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_corn',
      fridgeId: fridgeId,
      name: 'Sweet Corn',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      imagePath: 'assets/images/food_spinach.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_berries',
      fridgeId: fridgeId,
      name: 'Frozen Mixed Berries',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 75),
      imagePath: 'assets/images/food_strawberries.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_spinach',
      fridgeId: fridgeId,
      name: 'Chopped Spinach',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'box · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 80),
      imagePath: 'assets/images/food_spinach.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_coffee',
      fridgeId: fridgeId,
      name: 'Coffee Ice Cubes',
      category: 'beverages',
      zone: 'freezer',
      quantity: 1,
      unit: 'tray',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      imagePath: 'assets/images/food_cold_brew.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_smoothie',
      fridgeId: fridgeId,
      name: 'Berry Smoothie Mix',
      category: 'beverages',
      zone: 'freezer',
      quantity: 1,
      unit: 'pack',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      imagePath: 'assets/images/food_strawberries.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_lemon',
      fridgeId: fridgeId,
      name: 'Lemon Juice Concentrate',
      category: 'beverages',
      zone: 'freezer',
      quantity: 1,
      unit: 'bottle',
      expiryDate: DateTime(now.year, now.month, now.day + 120),
      imagePath: 'assets/images/food_orange_juice.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_popsicles',
      fridgeId: fridgeId,
      name: 'Popsicles',
      category: 'beverages',
      zone: 'freezer',
      quantity: 4,
      unit: 'bars',
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      imagePath: 'assets/images/food_orange_juice.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_pizza',
      fridgeId: fridgeId,
      name: 'Frozen Pizza',
      category: 'meals',
      zone: 'freezer',
      quantity: 1,
      unit: 'box · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      imagePath: 'assets/images/food_pizza.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_dumplings',
      fridgeId: fridgeId,
      name: 'Pork Dumplings',
      category: 'meals',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      imagePath: 'assets/images/food_dumplings.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_lasagna',
      fridgeId: fridgeId,
      name: 'Microwave Lasagna',
      category: 'meals',
      zone: 'freezer',
      quantity: 1,
      unit: 'tray · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 75),
      imagePath: 'assets/images/food_lasagna.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_icecream',
      fridgeId: fridgeId,
      name: 'Vanilla Ice Cream',
      category: 'meals',
      zone: 'freezer',
      quantity: 1,
      unit: 'tub · 500 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 30),
      imagePath: 'assets/images/food_milk.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_pesto',
      fridgeId: fridgeId,
      name: 'Frozen Pesto Cubes',
      category: 'sauces',
      zone: 'freezer',
      quantity: 1,
      unit: 'tray',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      imagePath: 'assets/images/food_olive_oil.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_broth',
      fridgeId: fridgeId,
      name: 'Beef Bone Broth Cubes',
      category: 'sauces',
      zone: 'freezer',
      quantity: 1,
      unit: 'tray',
      expiryDate: DateTime(now.year, now.month, now.day + 120),
      imagePath: 'assets/images/food_soy_sauce.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_butter',
      fridgeId: fridgeId,
      name: 'Herb Garlic Butter',
      category: 'sauces',
      zone: 'freezer',
      quantity: 1,
      unit: 'roll · 150 g',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      imagePath: 'assets/images/food_mayo.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_paste',
      fridgeId: fridgeId,
      name: 'Chili Paste',
      category: 'sauces',
      zone: 'freezer',
      quantity: 1,
      unit: 'jar · 200 g',
      expiryDate: DateTime(now.year, now.month, now.day + 75),
      imagePath: 'assets/images/food_sriracha.png',
      updatedAt: now,
    ),
  ];
}
