import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/freshness_colors.dart';
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
    // ==========================================
    // 1. ALL TAB DEFAULT OVERVIEW (Screen #9)
    // ==========================================
    ItemModel(
      id: 'item_spinach',
      fridgeId: fridgeId,
      name: 'Baby spinach',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'bag · 150 g',
      expiryDate: DateTime(now.year, now.month, now.day - 1),
      customStatus: FreshnessStatus.expired,
      customStatusText: 'Yesterday',
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
      expiryDate: DateTime(now.year, now.month, now.day + 2),
      customStatus: FreshnessStatus.useSoon,
      customStatusText: '2 days left',
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
      expiryDate: DateTime(now.year, now.month, now.day + 5),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '5 days left',
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
      expiryDate: DateTime(now.year, now.month, now.day + 7),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '7 days left',
      imagePath: 'assets/images/food_whole_milk.png',
      updatedAt: now,
    ),

    // ==========================================
    // 2. FRIDGE: PROTEINS (Image 1 Close-up)
    // ==========================================
    ItemModel(
      id: 'prot_chicken_breasts',
      fridgeId: fridgeId,
      name: 'Chicken Breasts',
      category: 'proteins',
      zone: 'fridge',
      quantity: 2,
      unit: 'pieces · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 2),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '2 days left',
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'prot_eggs',
      fridgeId: fridgeId,
      name: 'Eggs',
      category: 'proteins',
      zone: 'fridge',
      quantity: 6,
      unit: 'eggs · 1 carton',
      expiryDate: DateTime(now.year, now.month, now.day + 8),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '8 days left',
      imagePath: 'assets/images/food_eggs.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'prot_salmon_fillets',
      fridgeId: fridgeId,
      name: 'Salmon Fillets',
      category: 'proteins',
      zone: 'fridge',
      quantity: 2,
      unit: 'fillets · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 5),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '5 days left',
      imagePath: 'assets/images/food_salmon_fillets.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'prot_firm_tofu',
      fridgeId: fridgeId,
      name: 'Firm Tofu',
      category: 'proteins',
      zone: 'fridge',
      quantity: 1,
      unit: 'block · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 3),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '3 days left',
      imagePath: 'assets/images/food_firm_tofu.png',
      updatedAt: now,
    ),

    // ==========================================
    // 3. FRIDGE: VEGGIES (Image 2 Close-up)
    // ==========================================
    ItemModel(
      id: 'veg_cherry_tomatoes',
      fridgeId: fridgeId,
      name: 'Cherry Tomatoes',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'punnet · 250 g',
      expiryDate: DateTime(now.year, now.month, now.day + 10),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '10 days left',
      imagePath: 'assets/images/food_cherry_tomatoes.png',
      updatedAt: now,
    ),

    // ==========================================
    // 4. FRIDGE: BEVERAGES (Image 3 Close-up)
    // ==========================================
    ItemModel(
      id: 'bev_orange_juice',
      fridgeId: fridgeId,
      name: 'Orange Juice',
      category: 'beverages',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 750 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 3),
      customStatus: FreshnessStatus.useSoon,
      customStatusText: '3 days left',
      imagePath: 'assets/images/food_orange_juice.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'bev_cold_brew',
      fridgeId: fridgeId,
      name: 'Cold Brew Coffee',
      category: 'beverages',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 500 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 5),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '5 days left',
      imagePath: 'assets/images/food_cold_brew.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'bev_kombucha',
      fridgeId: fridgeId,
      name: 'Kombucha',
      category: 'beverages',
      zone: 'fridge',
      quantity: 2,
      unit: 'bottles · 330 ml each',
      expiryDate: DateTime(now.year, now.month, now.day + 10),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '10 days left',
      imagePath: 'assets/images/food_kombucha.png',
      updatedAt: now,
    ),

    // ==========================================
    // 5. FRIDGE: MEALS (Image 4 Close-up)
    // ==========================================
    ItemModel(
      id: 'meal_lasagna',
      fridgeId: fridgeId,
      name: 'Microwave Lasagna',
      category: 'meals',
      zone: 'fridge',
      quantity: 1,
      unit: 'tray · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day - 1),
      customStatus: FreshnessStatus.expired,
      customStatusText: 'Yesterday',
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
      unit: 'box · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 2),
      customStatus: FreshnessStatus.useSoon,
      customStatusText: '2 days left',
      imagePath: 'assets/images/food_pizza.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'meal_dumplings',
      fridgeId: fridgeId,
      name: 'Pork Dumplings',
      category: 'meals',
      zone: 'fridge',
      quantity: 1,
      unit: 'pack · 200 g',
      expiryDate: DateTime(now.year, now.month, now.day + 10),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '10 days left',
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
      unit: 'bag · 350 g',
      expiryDate: DateTime(now.year, now.month, now.day + 14),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '14 days left',
      imagePath: 'assets/images/food_nuggets.png',
      updatedAt: now,
    ),

    // ==========================================
    // 6. FRIDGE: SAUCES (Image 5 Close-up)
    // ==========================================
    ItemModel(
      id: 'sauce_soy',
      fridgeId: fridgeId,
      name: 'Soy Sauce',
      category: 'sauces',
      zone: 'fridge',
      quantity: 1,
      unit: 'bottle · 250 ml',
      expiryDate: DateTime(now.year, now.month + 6, now.day),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '6 months left',
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
      unit: 'jar · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 7),
      customStatus: FreshnessStatus.useSoon,
      customStatusText: '1 week left',
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
      expiryDate: DateTime(now.year, now.month + 3, now.day),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '3 months left',
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
      unit: 'bottle · 500 ml',
      expiryDate: DateTime(now.year + 1, now.month, now.day),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '12 months left',
      imagePath: 'assets/images/food_olive_oil.png',
      updatedAt: now,
    ),

    // ==========================================
    // 7. FREEZER ZONE ITEMS (All Categories)
    // ==========================================
    // Freezer Proteins
    ItemModel(
      id: 'fz_pork',
      fridgeId: fridgeId,
      name: 'Pork Tenderloin',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 15),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '15 days left',
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
      unit: 'fillets · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 20),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '20 days left',
      imagePath: 'assets/images/food_salmon_fillets.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_ribeye',
      fridgeId: fridgeId,
      name: 'Beef Ribeye Steak',
      category: 'proteins',
      zone: 'freezer',
      quantity: 2,
      unit: 'steaks · 600 g',
      expiryDate: DateTime(now.year, now.month, now.day + 25),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '25 days left',
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_chicken_thighs',
      fridgeId: fridgeId,
      name: 'Chicken Thighs',
      category: 'proteins',
      zone: 'freezer',
      quantity: 4,
      unit: 'pieces · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 18),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '18 days left',
      imagePath: 'assets/images/food_chicken_breasts.png',
      updatedAt: now,
    ),

    // Freezer Veggies
    ItemModel(
      id: 'fz_peas',
      fridgeId: fridgeId,
      name: 'Green Peas',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '45 days left',
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
      expiryDate: DateTime(now.year, now.month, now.day + 40),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '40 days left',
      imagePath: 'assets/images/food_cherry_tomatoes.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_berries',
      fridgeId: fridgeId,
      name: 'Frozen Mixed Berries',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '60 days left',
      imagePath: 'assets/images/food_strawberries.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_chopped_spinach',
      fridgeId: fridgeId,
      name: 'Chopped Spinach',
      category: 'veggies',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 250 g',
      expiryDate: DateTime(now.year, now.month, now.day + 35),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '35 days left',
      imagePath: 'assets/images/food_spinach.png',
      updatedAt: now,
    ),

    // Freezer Beverages
    ItemModel(
      id: 'fz_ice_coffee',
      fridgeId: fridgeId,
      name: 'Coffee Ice Cubes',
      category: 'beverages',
      zone: 'freezer',
      quantity: 1,
      unit: 'tray · 200 g',
      expiryDate: DateTime(now.year, now.month, now.day + 30),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '30 days left',
      imagePath: 'assets/images/food_cold_brew.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_smoothie',
      fridgeId: fridgeId,
      name: 'Berry Smoothie Mix',
      category: 'beverages',
      zone: 'freezer',
      quantity: 2,
      unit: 'packs · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '45 days left',
      imagePath: 'assets/images/food_kombucha.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_lemon',
      fridgeId: fridgeId,
      name: 'Lemon Juice Concentrate',
      category: 'beverages',
      zone: 'freezer',
      quantity: 1,
      unit: 'bottle · 250 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '60 days left',
      imagePath: 'assets/images/food_orange_juice.png',
      updatedAt: now,
    ),
    ItemModel(
      id: 'fz_popsicles',
      fridgeId: fridgeId,
      name: 'Popsicles',
      category: 'beverages',
      zone: 'freezer',
      quantity: 6,
      unit: 'pack · 360 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '90 days left',
      imagePath: 'assets/images/food_whole_milk.png',
      updatedAt: now,
    ),

    // Freezer Meals
    ItemModel(
      id: 'fz_pizza',
      fridgeId: fridgeId,
      name: 'Frozen Pizza',
      category: 'meals',
      zone: 'freezer',
      quantity: 1,
      unit: 'box · 400 g',
      expiryDate: DateTime(now.year, now.month, now.day + 25),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '25 days left',
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
      unit: 'pack · 200 g',
      expiryDate: DateTime(now.year, now.month, now.day + 30),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '30 days left',
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
      unit: 'tray · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 20),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '20 days left',
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
      unit: 'tub · 450 ml',
      expiryDate: DateTime(now.year, now.month, now.day + 30),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '30 days left',
      imagePath: 'assets/images/food_nuggets.png',
      updatedAt: now,
    ),

    // Freezer Sauces
    ItemModel(
      id: 'fz_pesto',
      fridgeId: fridgeId,
      name: 'Frozen Pesto Cubes',
      category: 'sauces',
      zone: 'freezer',
      quantity: 1,
      unit: 'tray · 150 g',
      expiryDate: DateTime(now.year, now.month, now.day + 60),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '60 days left',
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
      unit: 'box · 300 g',
      expiryDate: DateTime(now.year, now.month, now.day + 90),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '90 days left',
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
      expiryDate: DateTime(now.year, now.month, now.day + 45),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '45 days left',
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
      customStatus: FreshnessStatus.fresh,
      customStatusText: '75 days left',
      imagePath: 'assets/images/food_sriracha.png',
      updatedAt: now,
    ),
  ];
});

/// Filtered items for FridgeDetailPage matching exact Figma mockup screens #9 & category clicks for both Fridge and Freezer
final fridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final filter = ref.watch(fridgeDetailFilterProvider);
  final allItems = ref.watch(allFridgeItemsProvider(fridgeId));

  // If search query is present
  if (filter.searchQuery.trim().isNotEmpty) {
    return allItems
        .where((item) =>
            item.zone == filter.zone &&
            item.name.toLowerCase().contains(filter.searchQuery.trim().toLowerCase()))
        .toList();
  }

  final zoneItems = allItems.where((item) => item.zone == filter.zone).toList();

  // Handle category filtering
  switch (filter.category.toLowerCase()) {
    case 'proteins':
      return zoneItems.where((i) => i.category == 'proteins').toList();

    case 'veggies':
      if (filter.zone == 'fridge') {
        final vegIds = {'item_spinach', 'item_strawberries', 'item_avocados', 'veg_cherry_tomatoes'};
        return zoneItems.where((i) => vegIds.contains(i.id)).toList();
      }
      return zoneItems.where((i) => i.category == 'veggies').toList();

    case 'beverages':
      if (filter.zone == 'fridge') {
        final bevIds = {'item_milk', 'bev_orange_juice', 'bev_cold_brew', 'bev_kombucha'};
        return zoneItems.where((i) => bevIds.contains(i.id)).toList();
      }
      return zoneItems.where((i) => i.category == 'beverages').toList();

    case 'meals':
      if (filter.zone == 'fridge') {
        final mealIds = {'meal_lasagna', 'meal_pizza', 'meal_dumplings', 'meal_nuggets'};
        return zoneItems.where((i) => mealIds.contains(i.id)).toList();
      }
      return zoneItems.where((i) => i.category == 'meals').toList();

    case 'sauces':
      if (filter.zone == 'fridge') {
        final sauceIds = {'sauce_soy', 'sauce_mayo', 'sauce_sriracha', 'sauce_olive_oil'};
        return zoneItems.where((i) => sauceIds.contains(i.id)).toList();
      }
      return zoneItems.where((i) => i.category == 'sauces').toList();

    case 'all':
    default:
      if (filter.zone == 'fridge') {
        final allIds = {'item_spinach', 'item_strawberries', 'item_avocados', 'item_milk'};
        return zoneItems.where((i) => allIds.contains(i.id)).toList();
      } else {
        // Freezer default All overview: 4 items
        final fzAllIds = {'fz_pork', 'fz_salmon', 'fz_pizza', 'fz_peas'};
        return zoneItems.where((i) => fzAllIds.contains(i.id)).toList();
      }
  }
});
