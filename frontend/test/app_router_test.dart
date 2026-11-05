import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/router/app_router.dart';

void main() {
  testWidgets('AppRouter navigates across key application routes', (tester) async {
    final container = ProviderContainer();
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('th', ''),
          ],
        ),
      ),
    );

    // Initial route should be /sign-in
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/sign-in');

    // Navigate to /onboarding
    router.go('/onboarding');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/onboarding');

    // Navigate to /create-account with query param
    router.go('/create-account?email=test%40example.com');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/create-account');

    // Navigate to /reset-password
    router.go('/reset-password');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/reset-password');

    // Navigate to /verify-otp
    router.go('/verify-otp?email=test%40example.com');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/verify-otp');

    // Navigate to /new-password
    router.go('/new-password?email=test%40example.com&otp=123456');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/new-password');

    // Navigate to /verify-reset-password
    router.go('/verify-reset-password?email=test%40example.com');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/verify-reset-password');

    // Navigate to /settings
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/settings');

    // Navigate to /settings/profile
    router.go('/settings/profile');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/settings/profile');

    // Navigate to /fridges/add
    router.go('/fridges/add');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/fridges/add');

    // Test redirect from /fridge to /fridges
    router.go('/fridge');
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, '/fridges');

    // Test redirect from /fridge/f_abc to /fridges/f_abc
    router.go('/fridge/f_abc');
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, '/fridges/f_abc');

    container.dispose();
  });
}
