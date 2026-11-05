import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/theme/material_theme.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/history_repository.dart';
import 'package:fm_eaa/features/history/providers/history_provider.dart';
import 'package:fm_eaa/features/notifications/providers/notifications_provider.dart';
import 'package:fm_eaa/shared/widgets/user_avatar.dart';

void main() {
  group('MaterialTheme Unit Tests', () {
    test('constructs and provides light, dark, and contrast themes', () {
      const theme = MaterialTheme(TextTheme());
      expect(theme.light().brightness, Brightness.light);
      expect(theme.dark().brightness, Brightness.dark);
      expect(theme.lightMediumContrast().brightness, Brightness.light);
      expect(theme.lightHighContrast().brightness, Brightness.light);
      expect(theme.darkMediumContrast().brightness, Brightness.dark);
      expect(theme.darkHighContrast().brightness, Brightness.dark);
      expect(theme.extendedColors, isEmpty);

      const colorFamily = ColorFamily(
        color: Colors.red,
        onColor: Colors.white,
        colorContainer: Colors.pink,
        onColorContainer: Colors.black,
      );
      expect(colorFamily.color, Colors.red);

      const extended = ExtendedColor(
        seed: Colors.blue,
        value: Colors.blue,
        light: colorFamily,
        lightHighContrast: colorFamily,
        lightMediumContrast: colorFamily,
        dark: colorFamily,
        darkHighContrast: colorFamily,
        darkMediumContrast: colorFamily,
      );
      expect(extended.seed, Colors.blue);
    });
  });

  group('UserAvatar Widget Tests', () {
    testWidgets('renders fallback initials for single word name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'Tul'),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('renders fallback initials for two word name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'Tul Boon'),
          ),
        ),
      );

      expect(find.text('TB'), findsOneWidget);
    });

    testWidgets('renders question mark for empty name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: '  '),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('renders base64 data image avatar', (tester) async {
      // 1x1 transparent PNG
      const base64Png =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              name: 'Tul',
              avatarUrl: base64Png,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('falls back cleanly on invalid base64 string', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              name: 'Tul',
              avatarUrl: 'data:image/png;base64,INVALID_BASE64',
            ),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });
  });

  group('HistoryController Unit Tests', () {
    test('initial state is AsyncData', () {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = HistoryRepository(apiClient: ApiClient(), database: db);
      final controller = HistoryController(repo);
      expect(controller.state, const AsyncData<void>(null));
      db.close();
    });
  });

  group('NotificationController Unit Tests', () {
    test('initial state is AsyncData', () {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          currentNotificationUserIdProvider.overrideWithValue('u1'),
        ],
      );
      final controller = container.read(notificationControllerProvider.notifier);
      expect(controller.state, const AsyncData<void>(null));
      db.close();
      container.dispose();
    });
  });
}
