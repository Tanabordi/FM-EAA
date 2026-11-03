import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/l10n/locale_provider.dart';
import 'package:fm_eaa/core/theme/app_theme.dart';
import 'package:fm_eaa/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:fm_eaa/features/settings/presentation/pages/settings_page.dart';
import 'package:fm_eaa/features/settings/presentation/widgets/logout_dialog.dart';
import 'package:fm_eaa/features/settings/providers/settings_provider.dart';

void main() {
  group('UserProfileNotifier Unit Tests', () {
    test('Initial user state has default name and email', () {
      final notifier = UserProfileNotifier();
      expect(notifier.state.username, 'Alex Lee');
      expect(notifier.state.email, 'alex.lee@example.com');
      expect(notifier.state.id, 'user_1');
    });

    test('updateProfile updates username and email reactively', () async {
      final notifier = UserProfileNotifier();
      await notifier.updateProfile(
        name: 'John Doe',
        email: 'john.doe@test.com',
      );

      expect(notifier.state.username, 'John Doe');
      expect(notifier.state.email, 'john.doe@test.com');
    });

    test('updateProfile throws ArgumentError when name is empty', () async {
      final notifier = UserProfileNotifier();
      expect(
        () => notifier.updateProfile(name: '', email: 'valid@email.com'),
        throwsArgumentError,
      );
    });

    test('updateProfile throws ArgumentError when email is invalid', () async {
      final notifier = UserProfileNotifier();
      expect(
        () => notifier.updateProfile(name: 'Valid Name', email: 'invalid-email'),
        throwsArgumentError,
      );
    });

    test('updateProfile throws ArgumentError when new password is too short (< 8 chars)', () async {
      final notifier = UserProfileNotifier();
      expect(
        () => notifier.updateProfile(
          name: 'Valid Name',
          email: 'valid@email.com',
          currentPassword: 'current_pass',
          newPassword: '123',
        ),
        throwsArgumentError,
      );
    });

    test('updateProfile throws ArgumentError when new password given without current password', () async {
      final notifier = UserProfileNotifier();
      expect(
        () => notifier.updateProfile(
          name: 'Valid Name',
          email: 'valid@email.com',
          newPassword: 'new_password_8chars',
        ),
        throwsArgumentError,
      );
    });

    test('resetToDefault restores original state', () async {
      final notifier = UserProfileNotifier();
      await notifier.updateProfile(name: 'Changed Name', email: 'changed@email.com');
      notifier.resetToDefault();
      expect(notifier.state.username, 'Alex Lee');
      expect(notifier.state.email, 'alex.lee@example.com');
    });
  });

  group('LocaleNotifier & ThemeModeNotifier Unit Tests', () {
    test('LocaleNotifier setLocale and toggleLocale work correctly', () {
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, 'en');

      notifier.setLocale('th');
      expect(notifier.state.languageCode, 'th');

      notifier.toggleLocale();
      expect(notifier.state.languageCode, 'en');
    });

    test('ThemeModeNotifier setThemeMode and toggleTheme work correctly', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, ThemeMode.light);

      notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      notifier.toggleTheme();
      expect(notifier.state, ThemeMode.light);
    });
  });

  group('SettingsPage (Screen #22) Widget Tests', () {
    testWidgets('Renders Profile, Preferences, and Log out button without constraint errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Settings'), findsOneWidget);

      // Verify Profile Card
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Alex Lee'), findsOneWidget);
      expect(find.text('alex.lee@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Verify Preferences Card
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('TH'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Verify Log out Button
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('Tapping Language segment updates locale state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially 'en'
      expect(container.read(localeProvider).languageCode, 'en');

      // Tap 'TH'
      await tester.tap(find.text('TH'));
      await tester.pumpAndSettle();

      expect(container.read(localeProvider).languageCode, 'th');
    });

    testWidgets('Tapping Theme segment updates theme mode state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially ThemeMode.light
      expect(container.read(themeModeProvider), ThemeMode.light);

      // Tap 'Dark'
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('Tapping Log out button opens LogoutDialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Log out button
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      // Verify dialog is opened
      expect(find.byType(LogoutDialog), findsOneWidget);
      expect(find.text('Are you sure you want to log out of your account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('EditProfilePage (Screen #23) Widget Tests', () {
    testWidgets('Pre-fills user name and email fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const EditProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify prefilled text
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Alex Lee'), findsOneWidget);
      expect(find.text('alex.lee@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Validates required fields (empty name and invalid email)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const EditProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Clear name and enter invalid email
      await tester.enterText(find.byType(TextField).at(0), '');
      await tester.enterText(find.byType(TextField).at(1), 'invalid_email');

      // Scroll to and tap Save Changes
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify error messages
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Validates password constraints when new password is short', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const EditProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter short new password
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(2), 'old_pass');
      await tester.enterText(textFields.at(3), '123');

      // Scroll to and tap Save Changes
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('New password must be at least 8 characters long'), findsOneWidget);
    });

    testWidgets('Saves valid profile changes and updates state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Update name and email
      await tester.enterText(find.byType(TextField).at(0), 'Alexander Great');
      await tester.enterText(find.byType(TextField).at(1), 'alexander@test.com');

      // Scroll to and tap Save Changes
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(container.read(userProfileProvider).username, 'Alexander Great');
      expect(container.read(userProfileProvider).email, 'alexander@test.com');
      expect(find.byType(EditProfilePage), findsNothing);
    });

    testWidgets('Shows discard dialog when back button is pressed with unsaved changes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Change name to create unsaved changes
      await tester.enterText(find.byType(TextField).at(0), 'Changed Name');
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);

      // Tap Keep editing
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('Tapping Discard successfully exits EditProfilePage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);

      // Change name to create unsaved changes
      await tester.enterText(find.byType(TextField).at(0), 'Changed Name');
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Discard')); // Tap Discard
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('LogoutDialog (Screen #24) Widget Tests', () {
    testWidgets('Displays confirmation dialog and cancels cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: LogoutDialog(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Log out'), findsNWidgets(2)); // Title and button
      expect(find.text('Are you sure you want to log out of your account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}

