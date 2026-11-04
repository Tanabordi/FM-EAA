import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/history_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/history_repository.dart';
import '../../fridge_detail/providers/fridge_detail_provider.dart';
import '../../fridges/providers/fridges_provider.dart';

/// Provider for HistoryRepository bound with AppDatabase and ApiClient
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryRepository(apiClient: ApiClient(), database: db);
});

/// Reactive Stream of all history records for a fridge
final historyStreamProvider = StreamProvider.family<List<HistoryModel>, String>((ref, fridgeId) {
  final repo = ref.watch(historyRepositoryProvider);
  // Fetch real history from backend API and sync with local Drift SQLite
  repo.fetchHistoryFromApi(fridgeId);
  return repo.watchHistory(fridgeId);
});

/// Convenience provider returning current list of history models
final historyItemsProvider = Provider.family<List<HistoryModel>, String>((ref, fridgeId) {
  final asyncValue = ref.watch(historyStreamProvider(fridgeId));
  return asyncValue.value ?? const [];
});

/// State controller for performing actions on history (delete single, clear all, clean old)
class HistoryController extends StateNotifier<AsyncValue<void>> {
  final HistoryRepository _repository;
  final Ref? _ref;

  HistoryController(this._repository, [this._ref]) : super(const AsyncData(null));

  Future<void> deleteItem(String historyId, {String? fridgeId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteHistoryItem(historyId, fridgeId: fridgeId);
      if (fridgeId != null && _ref != null) {
        try {
          _ref!.read(fridgeItemsProvider(fridgeId).notifier).loadItems();
          _ref!.read(fridgesProvider.notifier).loadFridges();
        } catch (_) {}
      }
    });
  }

  Future<void> clearHistory(String fridgeId, {String? kind}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.clearHistory(fridgeId, kind);
      if (_ref != null) {
        try {
          _ref!.read(fridgeItemsProvider(fridgeId).notifier).loadItems();
          _ref!.read(fridgesProvider.notifier).loadFridges();
        } catch (_) {}
      }
    });
  }

  Future<void> cleanOldConsumedHistory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.cleanOldConsumedHistory());
  }
}

final historyControllerProvider = StateNotifierProvider<HistoryController, AsyncValue<void>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return HistoryController(repo, ref);
});
