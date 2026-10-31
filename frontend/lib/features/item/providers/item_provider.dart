import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/item_repository.dart';
import '../../fridge_detail/providers/fridge_detail_provider.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(apiClient: ApiClient());
});

final itemDetailProvider = Provider.family<ItemModel?, String>((ref, itemId) {
  final items = ref.watch(fridgeItemsProvider('fridge_kitchen'));
  try {
    return items.firstWhere((item) => item.id == itemId);
  } catch (_) {
    return ItemModel(
      id: itemId,
      fridgeId: 'fridge_kitchen',
      name: 'Strawberries',
      category: 'veggies',
      zone: 'fridge',
      quantity: 1,
      unit: 'punnet · 250 g',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      imagePath: 'assets/images/food_strawberries.png',
      updatedAt: DateTime.now(),
    );
  }
});
