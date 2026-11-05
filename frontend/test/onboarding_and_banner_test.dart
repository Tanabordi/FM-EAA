import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/l10n/locale_provider.dart';
import 'package:fm_eaa/features/auth/presentation/pages/onboarding_page.dart';
import 'package:fm_eaa/shared/widgets/offline_banner.dart';
import 'package:fm_eaa/sync/connectivity_watcher.dart';

class _FakeLocaleNotifier extends LocaleNotifier {
  _FakeLocaleNotifier(Locale initial) : super() {
    state = initial;
  }
}

void main() {
  group('OnboardingPage Widget Tests', () {
    testWidgets('renders onboarding elements in English', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: OnboardingPage(),
        ),
      );

      expect(find.text('Reduce Food Waste'), findsOneWidget);
      expect(find.text('Get smart alerts before your groceries expire.'), findsOneWidget);
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('renders onboarding elements in Thai', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('th'),
          supportedLocales: [Locale('en'), Locale('th')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: OnboardingPage(),
        ),
      );

      expect(find.text('ลดขยะอาหารในบ้านคุณ'), findsOneWidget);
      expect(find.text('รับการแจ้งเตือนอัจฉริยะก่อนอาหารของคุณจะหมดอายุ'), findsOneWidget);
      expect(find.text('เปิดการแจ้งเตือน'), findsOneWidget);
      expect(find.text('ข้าม'), findsOneWidget);
    });
  });

  group('OfflineBanner Widget Tests', () {
    testWidgets('hidden when online', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isOnlineProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  OfflineBanner(),
                  Text('Content Area'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });

    testWidgets('visible with Thai message when offline and locale is th', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isOnlineProvider.overrideWith((ref) => Stream.value(false)),
            localeProvider.overrideWith((ref) => _FakeLocaleNotifier(const Locale('th'))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  OfflineBanner(),
                  Text('Content Area'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.textContaining('โหมดออฟไลน์'), findsOneWidget);
    });

    testWidgets('visible with English message when offline and locale is en', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isOnlineProvider.overrideWith((ref) => Stream.value(false)),
            localeProvider.overrideWith((ref) => _FakeLocaleNotifier(const Locale('en'))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  OfflineBanner(),
                  Text('Content Area'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.textContaining('Offline mode'), findsOneWidget);
    });
  });
}
