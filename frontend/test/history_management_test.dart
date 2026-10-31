import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/history_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/history_repository.dart';
import 'package:fm_eaa/features/history/presentation/pages/history_page.dart';
import 'package:fm_eaa/features/history/providers/history_provider.dart';

void main() {
  late AppDatabase db;
  late ItemDao itemDao;
  late HistoryRepository historyRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    itemDao = db.itemDao;
    historyRepo = HistoryRepository(apiClient: ApiClient(), database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('History Local Database & DAO Tests', () {
    test('watchHistoryByFridge and getHistoryByFridge return records correctly', () async {
      // Record an expired item
      await itemDao.recordExpiredHistory(
        id: 'hist_exp_1',
        fridgeId: 'fridge_1',
        itemName: 'Cheddar Cheese',
        quantityChanged: 1.0,
        unit: 'pack',
        byUserId: 'system',
      );

      final records = await itemDao.getHistoryByFridge('fridge_1');
      expect(records.length, 1);
      expect(records.first.itemName, 'Cheddar Cheese');
      expect(records.first.kind, 'expired');
    });

    test('Filter history by kind (consumed vs expired)', () async {
      // 1 consumed
      await itemDao.into(itemDao.itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_c1',
          fridgeId: 'fridge_1',
          itemName: 'Yogurt',
          kind: 'consumed',
          quantityChanged: 2.0,
          unit: 'cups',
          byUserId: 'user_1',
        ),
      );

      // 1 expired
      await itemDao.recordExpiredHistory(
        id: 'hist_e1',
        fridgeId: 'fridge_1',
        itemName: 'Milk',
        quantityChanged: 1.0,
        unit: 'bottle',
        byUserId: 'system',
      );

      final consumed = await itemDao.getHistoryByFridge('fridge_1', kind: 'consumed');
      expect(consumed.length, 1);
      expect(consumed.first.itemName, 'Yogurt');

      final expired = await itemDao.getHistoryByFridge('fridge_1', kind: 'expired');
      expect(expired.length, 1);
      expect(expired.first.itemName, 'Milk');
    });

    test('deleteHistoryItem removes single entry', () async {
      await itemDao.recordExpiredHistory(
        id: 'hist_del_1',
        fridgeId: 'fridge_1',
        itemName: 'Lettuce',
        quantityChanged: 1.0,
        unit: 'head',
      );

      expect((await itemDao.getHistoryByFridge('fridge_1')).length, 1);

      await itemDao.deleteHistoryItem('hist_del_1');
      expect((await itemDao.getHistoryByFridge('fridge_1')).isEmpty, true);
    });

    test('clearHistoryByFridge clears all or by kind', () async {
      await itemDao.into(itemDao.itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_c1',
          fridgeId: 'fridge_1',
          itemName: 'Apple',
          kind: 'consumed',
          quantityChanged: 1.0,
          unit: 'piece',
          byUserId: 'user_1',
        ),
      );

      await itemDao.recordExpiredHistory(
        id: 'hist_e1',
        fridgeId: 'fridge_1',
        itemName: 'Banana',
        quantityChanged: 3.0,
        unit: 'pieces',
      );

      // Clear only consumed
      await itemDao.clearHistoryByFridge('fridge_1', kind: 'consumed');
      final remaining = await itemDao.getHistoryByFridge('fridge_1');
      expect(remaining.length, 1);
      expect(remaining.first.itemName, 'Banana');

      // Clear remaining
      await itemDao.clearHistoryByFridge('fridge_1');
      expect((await itemDao.getHistoryByFridge('fridge_1')).isEmpty, true);
    });

    test('cleanOldConsumedHistory deletes consumed items older than 30 days but keeps recent', () async {
      final now = DateTime.now();

      // Older than 30 days (e.g. 35 days ago)
      await itemDao.into(itemDao.itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_old_consumed',
          fridgeId: 'fridge_1',
          itemName: 'Old Bread',
          kind: 'consumed',
          quantityChanged: 1.0,
          unit: 'loaf',
          byUserId: 'user_1',
          createdAt: Value(now.subtract(const Duration(days: 35))),
        ),
      );

      // Recent consumed (5 days ago)
      await itemDao.into(itemDao.itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_recent_consumed',
          fridgeId: 'fridge_1',
          itemName: 'Fresh Butter',
          kind: 'consumed',
          quantityChanged: 1.0,
          unit: 'pack',
          byUserId: 'user_1',
          createdAt: Value(now.subtract(const Duration(days: 5))),
        ),
      );

      // Old expired (35 days ago - should NOT be deleted because rule is for consumed auto-cleanup)
      await itemDao.into(itemDao.itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_old_expired',
          fridgeId: 'fridge_1',
          itemName: 'Old Expired Juice',
          kind: 'expired',
          quantityChanged: 1.0,
          unit: 'carton',
          byUserId: 'system',
          createdAt: Value(now.subtract(const Duration(days: 35))),
        ),
      );

      await db.cleanOldConsumedHistory();

      final remaining = await itemDao.getHistoryByFridge('fridge_1');
      final ids = remaining.map((r) => r.id).toList();

      expect(ids.contains('hist_old_consumed'), false, reason: '>30 days consumed must be purged');
      expect(ids.contains('hist_recent_consumed'), true, reason: 'Recent consumed must be kept');
      expect(ids.contains('hist_old_expired'), true, reason: 'Expired records are not auto-purged by consumed rule');
    });
  });

  group('History Repository Tests', () {
    test('seedInitialDataIfEmpty populates initial demo data only when empty', () async {
      await historyRepo.seedInitialDataIfEmpty('fridge_demo');

      final initialList = await historyRepo.getHistory('fridge_demo');
      expect(initialList.length, 5);

      // Run again - should not duplicate
      await historyRepo.seedInitialDataIfEmpty('fridge_demo');
      final secondList = await historyRepo.getHistory('fridge_demo');
      expect(secondList.length, 5);
    });
  });

  group('HistoryPage Widget Tests', () {
    testWidgets('HistoryPage renders AppBar, Tabs, 30-day banner, and list', (tester) async {
      final sampleItems = [
        HistoryModel(
          id: 'h1',
          fridgeId: 'fridge_1',
          itemName: 'Organic Milk',
          kind: 'consumed',
          quantityChanged: 1,
          quantityLeft: 1,
          unit: 'bottle',
          byUsername: 'alex.lee',
          createdAt: DateTime.now(),
        ),
        HistoryModel(
          id: 'h2',
          fridgeId: 'fridge_1',
          itemName: 'Spinach Leaves',
          kind: 'expired',
          quantityChanged: 1,
          quantityLeft: 0,
          unit: 'pack',
          byUsername: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyStreamProvider('fridge_1').overrideWith((ref) => Stream.value(sampleItems)),
          ],
          child: const MaterialApp(
            home: HistoryPage(fridgeId: 'fridge_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check AppBar
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      // Check Tabs
      expect(find.text('Consumed'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);

      // Check banner
      expect(find.text('Consumed is auto-deleted after 30 days'), findsOneWidget);

      // Check Consumed Tab Item
      expect(find.text('Organic Milk'), findsOneWidget);
      expect(find.textContaining('by @alex.lee'), findsOneWidget);

      // Switch to Expired Tab
      await tester.tap(find.text('Expired'));
      await tester.pumpAndSettle();

      // Check Expired Tab Item
      expect(find.text('Spinach Leaves'), findsOneWidget);
      expect(find.textContaining('by @system'), findsOneWidget);
    });

    testWidgets('Tapping Clear All opens confirmation dialog', (tester) async {
      final sampleItems = [
        HistoryModel(
          id: 'h1',
          fridgeId: 'fridge_1',
          itemName: 'Avocado',
          kind: 'consumed',
          quantityChanged: 2,
          quantityLeft: 0,
          unit: 'pieces',
          byUsername: 'sarah.c',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyStreamProvider('fridge_1').overrideWith((ref) => Stream.value(sampleItems)),
          ],
          child: const MaterialApp(
            home: HistoryPage(fridgeId: 'fridge_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Clear All
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Check Dialog appears
      expect(find.text('Clear All Consumed History?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}

