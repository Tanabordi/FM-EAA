import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/freshness_colors.dart';
import '../../../data/models/item_model.dart';
import '../../fridge_detail/providers/fridge_detail_provider.dart';

/// Search query provider defaulting to empty string before user searches
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider.family<List<ItemModel>, String>((ref, fridgeId) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return [];

  final allItems = ref.watch(allFridgeItemsProvider(fridgeId));
  return allItems.where((item) {
    // Exclude expired items from search results (moved to History > Expired)
    if (item.status == FreshnessStatus.expired) return false;

    return item.name.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query);
  }).toList();
});
