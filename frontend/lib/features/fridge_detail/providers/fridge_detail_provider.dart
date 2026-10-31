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

class FridgeItemsNotifier extends StateNotifier<List<ItemModel>> {
  final String fridgeId;

  FridgeItemsNotifier(this.fridgeId) : super(_getInitialMockItems(fridgeId));

  ItemModel? _lastConsumedItem;
  int? _lastConsumedIndex;
  double? _lastConsumedAmount;
  bool? _lastFinishedAll;

  ItemModel? getItem(String id) {
    try {
      return state.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  void addItem(ItemModel item) {
    state = [item, ...state];
  }

  void updateItem(ItemModel updated) {
    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void consumeItem(String id, double amount, bool finishedAll) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = state[index];
    _lastConsumedItem = item;
    _lastConsumedIndex = index;
    _lastConsumedAmount = amount;
    _lastFinishedAll = finishedAll;

    if (finishedAll || item.quantity <= amount) {
      // Remove completely from list
      state = [
        for (int i = 0; i < state.length; i++)
          if (i != index) state[i],
      ];
    } else {
      // Decrement quantity
      final newQuantity = item.quantity - amount;
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) item.copyWith(quantity: newQuantity, updatedAt: DateTime.now()) else state[i],
      ];
    }
  }

  void undoConsume() {
    if (_lastConsumedItem == null) return;

    if (_lastFinishedAll == true || (_lastConsumedAmount != null && _lastConsumedItem!.quantity <= _lastConsumedAmount!)) {
      final idx = (_lastConsumedIndex != null && _lastConsumedIndex! <= state.length) ? _lastConsumedIndex! : state.length;
      final newList = List<ItemModel>.from(state);
      newList.insert(idx, _lastConsumedItem!);
      state = newList;
    } else if (_lastConsumedAmount != null) {
      final id = _lastConsumedItem!.id;
      state = [
        for (final item in state)
          if (item.id == id) _lastConsumedItem! else item,
      ];
    }

    _lastConsumedItem = null;
    _lastConsumedIndex = null;
    _lastConsumedAmount = null;
    _lastFinishedAll = null;
  }

  static List<ItemModel> _getInitialMockItems(String fridgeId) {
    return [
      // 4 Main Items in Fridge zone shown in mockups (Image 2 & 5)
      ItemModel(
        id: 'item_spinach',
        fridgeId: fridgeId,
        name: 'Baby spinach',
        category: 'veggies',
        zone: 'fridge',
        quantity: 1,
        unit: 'bag · 150 g',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        imagePath: 'assets/images/food_spinach.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_strawberries',
        fridgeId: fridgeId,
        name: 'Strawberries',
        category: 'veggies',
        zone: 'fridge',
        quantity: 2,
        unit: 'punnet · 250 g',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        imagePath: 'assets/images/food_strawberries.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_avocados',
        fridgeId: fridgeId,
        name: 'Avocados',
        category: 'veggies',
        zone: 'fridge',
        quantity: 2,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        imagePath: 'assets/images/food_avocados.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_milk',
        fridgeId: fridgeId,
        name: 'Whole milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 1 L',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        imagePath: 'assets/images/food_whole_milk.png',
        updatedAt: DateTime.now(),
      ),

      // Other category items for Fridge
      ItemModel(
        id: 'item_chicken',
        fridgeId: fridgeId,
        name: 'Chicken Breasts',
        category: 'proteins',
        zone: 'fridge',
        quantity: 2,
        unit: 'pieces · 500 g',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        imagePath: 'assets/images/food_chicken_breasts.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_eggs',
        fridgeId: fridgeId,
        name: 'Eggs',
        category: 'proteins',
        zone: 'fridge',
        quantity: 10,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        imagePath: 'assets/images/food_eggs.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_salmon',
        fridgeId: fridgeId,
        name: 'Salmon Fillets',
        category: 'proteins',
        zone: 'fridge',
        quantity: 2,
        unit: 'pieces · 300 g',
        expiryDate: DateTime.now().add(const Duration(days: 4)),
        imagePath: 'assets/images/food_salmon_fillets.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_tofu',
        fridgeId: fridgeId,
        name: 'Firm Tofu',
        category: 'proteins',
        zone: 'fridge',
        quantity: 1,
        unit: 'block · 250 g',
        expiryDate: DateTime.now().add(const Duration(days: 6)),
        imagePath: 'assets/images/food_firm_tofu.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_tomatoes',
        fridgeId: fridgeId,
        name: 'Cherry Tomatoes',
        category: 'veggies',
        zone: 'fridge',
        quantity: 1,
        unit: 'punnet · 250 g',
        expiryDate: DateTime.now().add(const Duration(days: 4)),
        imagePath: 'assets/images/food_cherry_tomatoes.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_oj',
        fridgeId: fridgeId,
        name: 'Orange Juice',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 1 L',
        expiryDate: DateTime.now().add(const Duration(days: 6)),
        imagePath: 'assets/images/food_orange_juice.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_coffee',
        fridgeId: fridgeId,
        name: 'Cold Brew Coffee',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 500 mL',
        expiryDate: DateTime.now().add(const Duration(days: 8)),
        imagePath: 'assets/images/food_cold_brew.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_kombucha',
        fridgeId: fridgeId,
        name: 'Kombucha',
        category: 'beverages',
        zone: 'fridge',
        quantity: 2,
        unit: 'bottles · 330 mL',
        expiryDate: DateTime.now().add(const Duration(days: 14)),
        imagePath: 'assets/images/food_kombucha.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_lasagna',
        fridgeId: fridgeId,
        name: 'Microwave Lasagna',
        category: 'meals',
        zone: 'fridge',
        quantity: 1,
        unit: 'box · 400 g',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        imagePath: 'assets/images/food_lasagna.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_soysauce',
        fridgeId: fridgeId,
        name: 'Soy Sauce',
        category: 'sauces',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 300 mL',
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        imagePath: 'assets/images/food_soy_sauce.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_mayo',
        fridgeId: fridgeId,
        name: 'Mayonnaise',
        category: 'sauces',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 250 g',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        imagePath: 'assets/images/food_mayo.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_sriracha',
        fridgeId: fridgeId,
        name: 'Sriracha Sauce',
        category: 'sauces',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 200 mL',
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        imagePath: 'assets/images/food_sriracha.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_oliveoil',
        fridgeId: fridgeId,
        name: 'Olive Oil',
        category: 'sauces',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle · 500 mL',
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        imagePath: 'assets/images/food_olive_oil.png',
        updatedAt: DateTime.now(),
      ),

      // Freezer Items
      ItemModel(
        id: 'item_pork_freezer',
        fridgeId: fridgeId,
        name: 'Pork Tenderloin',
        category: 'proteins',
        zone: 'freezer',
        quantity: 1,
        unit: 'bag · 500 g',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        imagePath: 'assets/images/food_chicken_breasts.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_pizza_freezer',
        fridgeId: fridgeId,
        name: 'Frozen Pizza',
        category: 'meals',
        zone: 'freezer',
        quantity: 2,
        unit: 'boxes',
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        imagePath: 'assets/images/food_pizza.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_dumplings_freezer',
        fridgeId: fridgeId,
        name: 'Pork Dumplings',
        category: 'meals',
        zone: 'freezer',
        quantity: 1,
        unit: 'pack · 20 pcs',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        imagePath: 'assets/images/food_dumplings.png',
        updatedAt: DateTime.now(),
      ),
      ItemModel(
        id: 'item_nuggets_freezer',
        fridgeId: fridgeId,
        name: 'Chicken Nuggets',
        category: 'meals',
        zone: 'freezer',
        quantity: 1,
        unit: 'bag · 500 g',
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        imagePath: 'assets/images/food_nuggets.png',
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

final fridgeItemsProvider = StateNotifierProvider.family<FridgeItemsNotifier, List<ItemModel>, String>((ref, fridgeId) {
  return FridgeItemsNotifier(fridgeId);
});
