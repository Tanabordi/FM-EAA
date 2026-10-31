import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';

export '../../../data/repositories/item_repository.dart' show itemRepositoryProvider;

final itemDetailProvider = Provider.family<ItemModel?, String>((ref, itemId) {
  // Mock item detail for skeleton or load from DB
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
