import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/item_repository.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(apiClient: ApiClient());
});

final itemDetailProvider = Provider.family<ItemModel?, String>((ref, itemId) {
  // Mock item detail for skeleton
  return ItemModel(
    id: itemId,
    fridgeId: 'fridge_kitchen',
    name: 'Avocados',
    category: 'veggies',
    zone: 'fridge',
    quantity: 2,
    unit: 'punnet · 250 g',
    expiryDate: DateTime.now().add(const Duration(days: 2)),
    updatedAt: DateTime.now(),
  );
});

