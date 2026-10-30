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
    // 2. PROTEINS (Image 1 Close-up)
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
    // 3. VEGGIES (Image 2 Close-up)
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
    // 4. BEVERAGES (Image 3 Close-up)
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
    // 5. MEALS (Image 4 Close-up)
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
    // 6. SAUCES (Image 5 Close-up)
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
    // 7. FREEZER ZONE ITEMS
    // ==========================================
    ItemModel(
      id: 'item_pork',
      fridgeId: fridgeId,
      name: 'Pork Tenderloin',
      category: 'proteins',
      zone: 'freezer',
      quantity: 1,
      unit: 'bag · 500 g',
      expiryDate: DateTime(now.year, now.month, now.day + 15),
      customStatus: FreshnessStatus.fresh,
      customStatusText: '15 days left',
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
      customStatus: FreshnessStatus.fresh,
      customStatusText: '20 days left',
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
      customStatus: FreshnessStatus.fresh,
      customStatusText: '30 days left',
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
      customStatus: FreshnessStatus.fresh,
      customStatusText: '45 days left',
      updatedAt: now,
    ),
  ];
});

/// Filtered items for FridgeDetailPage matching exact Figma mockup screens #9 & category clicks
final fridgeItemsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final filter = ref.watch(fridgeDetailFilterProvider);
  final allItems = ref.watch(allFridgeItemsProvider(fridgeId));

  // If in freezer zone
  if (filter.zone == 'freezer') {
    return allItems.where((item) => item.zone == 'freezer').toList();
  }

  // If search query is present
  if (filter.searchQuery.trim().isNotEmpty) {
    return allItems
        .where((item) =>
            item.zone == 'fridge' &&
            item.name.toLowerCase().contains(filter.searchQuery.trim().toLowerCase()))
        .toList();
  }

  // Exact Figma Mockup items per category click
  switch (filter.category.toLowerCase()) {
    case 'proteins':
      return allItems.where((i) => i.category == 'proteins' && i.zone == 'fridge').toList();

    case 'veggies':
      // Matches Image 2: Baby spinach, Strawberries, Avocados, Cherry Tomatoes
      final vegIds = {'item_spinach', 'item_strawberries', 'item_avocados', 'veg_cherry_tomatoes'};
      return allItems.where((i) => vegIds.contains(i.id)).toList();

    case 'beverages':
      // Matches Image 3: Whole Milk, Orange Juice, Cold Brew Coffee, Kombucha
      final bevIds = {'item_milk', 'bev_orange_juice', 'bev_cold_brew', 'bev_kombucha'};
      return allItems.where((i) => bevIds.contains(i.id)).toList();

    case 'meals':
      // Matches Image 4: Microwave Lasagna, Frozen Pizza, Pork Dumplings, Chicken Nuggets
      final mealIds = {'meal_lasagna', 'meal_pizza', 'meal_dumplings', 'meal_nuggets'};
      return allItems.where((i) => mealIds.contains(i.id)).toList();

    case 'sauces':
      // Matches Image 5: Soy Sauce, Mayonnaise, Sriracha Sauce, Olive Oil
      final sauceIds = {'sauce_soy', 'sauce_mayo', 'sauce_sriracha', 'sauce_olive_oil'};
      return allItems.where((i) => sauceIds.contains(i.id)).toList();

    case 'all':
    default:
      // Matches Screen #9 default: Baby spinach, Strawberries, Avocados, Whole milk
      final allIds = {'item_spinach', 'item_strawberries', 'item_avocados', 'item_milk'};
      return allItems.where((i) => allIds.contains(i.id)).toList();
  }
});
