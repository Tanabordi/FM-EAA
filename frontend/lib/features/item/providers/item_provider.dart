import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/item_model.dart';
import '../../fridge_detail/providers/fridge_detail_provider.dart';

export '../../../data/repositories/item_repository.dart' show itemRepositoryProvider;

final itemDetailProvider = Provider.family<ItemModel?, String>((ref, itemId) {
  final items = ref.watch(fridgeItemsProvider('fridge_kitchen'));
  try {
    return items.firstWhere((item) => item.id == itemId);
  } catch (_) {
    return null;
  }
});
