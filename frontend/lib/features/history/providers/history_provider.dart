import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/history_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/history_repository.dart';

/// Provider for HistoryRepository bound with AppDatabase and ApiClient
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryRepository(apiClient: ApiClient(), database: db);
});

/// Reactive Stream of all history records for a fridge
final historyStreamProvider = StreamProvider.family<List<HistoryModel>, String>((ref, fridgeId) {
  final repo = ref.watch(historyRepositoryProvider);
  // Auto-seed initial sample data if empty so initial experience matches Figma prototype
  repo.seedInitialDataIfEmpty(fridgeId);
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

  HistoryController(this._repository) : super(const AsyncData(null));

  Future<void> deleteItem(String historyId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.deleteHistoryItem(historyId));
  }

  Future<void> clearHistory(String fridgeId, {String? kind}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.clearHistory(fridgeId, kind));
  }

  Future<void> cleanOldConsumedHistory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.cleanOldConsumedHistory());
  }
}

final historyControllerProvider = StateNotifierProvider<HistoryController, AsyncValue<void>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return HistoryController(repo);
});
