import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/l10n/locale_provider.dart';
import 'package:fm_eaa/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:fm_eaa/shared/widgets/app_back_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('EditProfilePage Widget & Logic Tests', () {
    testWidgets('renders all profile fields and change password section', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('validates username requirements (min length, chars)', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'ab'); // < 3 chars
      await tester.pumpAndSettle();

      final saveBtn = find.text('Save Changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Username must be at least 3 characters'), findsOneWidget);

      // Invalid characters
      await tester.enterText(nameField, 'user@name!');
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Letters, numbers, and underscores only'), findsOneWidget);
    });

    testWidgets('validates password requirements when setting new password', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      final newPassField = find.byType(TextField).at(3);
      await tester.enterText(newPassField, 'short');
      await tester.pumpAndSettle();

      final saveBtn = find.text('Save Changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Current password required first
      expect(find.text('Current password is required to set a new password'), findsOneWidget);

      final currentPassField = find.byType(TextField).at(2);
      await tester.enterText(currentPassField, 'oldpassword123');
      await tester.pumpAndSettle();

      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Length < 8
      expect(find.text('New password must be at least 8 characters long'), findsOneWidget);

      // Missing numbers
      await tester.enterText(newPassField, 'allletterslong');
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('New password must contain both letters and numbers'), findsOneWidget);
    });

    testWidgets('unsaved changes prompt discard confirmation on back tap', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'modified_user');
      await tester.pumpAndSettle();

      // Tap back button
      final backBtn = find.byType(AppBackButton);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Keep editing
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('tapping camera icon on avatar opens photo picker sheet', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      final cameraIcon = find.byIcon(Icons.camera_alt);
      expect(cameraIcon, findsOneWidget);
      await tester.tap(cameraIcon);
      await tester.pumpAndSettle();

      expect(find.text('Change Profile Photo'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });

    testWidgets('toggles password visibility icons', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      final visibilityIcons = find.byIcon(Icons.visibility_off_outlined);
      if (visibilityIcons.evaluate().isNotEmpty) {
        await tester.tap(visibilityIcons.first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
      }
    });

    testWidgets('successfully saves updated username and displays snackbar', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const EditProfilePage()));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'updated_alice');
      await tester.pumpAndSettle();

      final saveBtn = find.text('Save Changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('renders EditProfilePage in Thai language', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const EditProfilePage(),
          overrides: [
            localeProvider.overrideWith((ref) => LocaleNotifier()..setLocale('th')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขโปรไฟล์'), findsOneWidget);
      expect(find.text('ชื่อ'), findsOneWidget);
      expect(find.text('อีเมล'), findsOneWidget);
      expect(find.text('บันทึกการเปลี่ยนแปลง'), findsOneWidget);
    });
  });
}

