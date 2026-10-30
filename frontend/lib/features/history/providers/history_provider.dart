import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/history_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(apiClient: ApiClient());
});

final historyItemsProvider = Provider.family<List<HistoryModel>, String>((ref, fridgeId) {
  // Mock history list for skeleton
  return [
    HistoryModel(
      id: 'hist_1',
      fridgeId: fridgeId,
      itemName: 'Fresh Milk',
      kind: 'consumed',
      quantityChanged: 1,
      quantityLeft: 1,
      unit: 'bottle',
      byUsername: 'alex.lee',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HistoryModel(
      id: 'hist_2',
      fridgeId: fridgeId,
      itemName: 'Spinach',
      kind: 'expired',
      quantityChanged: 1,
      quantityLeft: 0,
      unit: 'pack',
      byUsername: 'system',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
});

