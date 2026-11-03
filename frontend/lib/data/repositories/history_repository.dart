import '../models/history_model.dart';
import '../remote/api_client.dart';

// TODO(repo history): Implement history fetching (consumed & expired), delete, and clear all
class HistoryRepository {
  final ApiClient apiClient;

  HistoryRepository({required this.apiClient});

  Future<List<HistoryModel>> getHistory(String fridgeId, String kind) async {
    // TODO: Query from Drift local database
    return [];
  }

  Future<void> deleteHistoryItem(String historyId) async {
    // TODO: Delete record
  }

  Future<void> clearHistory(String fridgeId, String kind) async {
    // TODO: Clear records for this fridge
  }
}

