import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/models/user_model.dart';
import 'package:fm_eaa/data/repositories/auth_repository.dart';
import 'package:fm_eaa/features/auth/presentation/pages/create_account_page.dart';
import 'package:fm_eaa/features/auth/presentation/pages/sign_in_page.dart';
import 'package:fm_eaa/features/auth/providers/auth_provider.dart';
import 'package:fm_eaa/shared/widgets/primary_button.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  String errorMessage = 'Invalid username/email or password';
  UserModel? mockUser;
  bool wasLogoutCalled = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel> signInWithPassword(String identifier, String password) async {
    if (shouldFail) {
      throw Exception(errorMessage);
    }
    return mockUser ??
        UserModel(
          id: 'user_test_1',
          username: identifier,
          email: '$identifier@example.com',
          updatedAt: DateTime(2026, 1, 1),
        );
  }

  @override
  Future<UserModel> createAccount(String username, String email, String password) async {
    if (shouldFail) {
      throw Exception(errorMessage);
    }
    return mockUser ??
        UserModel(
          id: 'user_test_2',
          username: username,
          email: email,
          updatedAt: DateTime(2026, 1, 1),
        );
  }

  @override
  Future<UserModel?> restoreSession() async {
    if (shouldFail) return null;
    return mockUser;
  }

  @override
  Future<void> logout() async {
    wasLogoutCalled = true;
  }
}

void main() {
  group('UserModel Serialization Tests', () {
    test('UserModel.fromJson parses standard lowercase format', () {
      final json = {
        'id': 'u100',
        'username': 'john_doe',
        'email': 'john@example.com',
        'avatar_url': 'https://example.com/avatar.png',
        'updated_at': '2026-03-01T12:00:00.000Z',
      };
      final user = UserModel.fromJson(json);

      expect(user.id, 'u100');
      expect(user.username, 'john_doe');
      expect(user.email, 'john@example.com');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.updatedAt.year, 2026);
    });

    test('UserModel.fromJson parses Oracle uppercase format', () {
      final json = {
        'ID': 'u200',
        'USERNAME': 'jane_doe',
        'EMAIL': 'jane@example.com',
        'AVATAR_URL': null,
        'UPDATED_AT': '2026-04-01T10:00:00.000Z',
      };
      final user = UserModel.fromJson(json);

      expect(user.id, 'u200');
      expect(user.username, 'jane_doe');
      expect(user.email, 'jane@example.com');
      expect(user.avatarUrl, isNull);
      expect(user.updatedAt.month, 4);
    });

    test('UserModel.fromJson gracefully falls back when timestamps are missing', () {
      final json = {
        'id': 'u300',
        'username': 'fallback_user',
        'email': 'fallback@example.com',
      };
      final user = UserModel.fromJson(json);

      expect(user.id, 'u300');
      expect(user.username, 'fallback_user');
      expect(user.updatedAt, isNotNull);
    });
  });

  group('AuthNotifier Unit Tests', () {
    late MockAuthRepository mockRepo;
    late AuthNotifier notifier;

    setUp(() {
      mockRepo = MockAuthRepository();
      notifier = AuthNotifier(mockRepo);
    });

    test('Initial state is not authenticated', () {
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.isLoading, isFalse);
    });

    test('signIn success updates state to authenticated', () async {
      await notifier.signIn('testuser', 'Password123!');

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.username, 'testuser');
      expect(notifier.state.isLoading, isFalse);
    });

    test('signIn failure resets authentication and rethrows error', () async {
      mockRepo.shouldFail = true;
      mockRepo.errorMessage = 'Invalid username/email or password';

      expect(
        () => notifier.signIn('wronguser', 'wrongpass'),
        throwsA(isA<Exception>()),
      );
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
    });

    test('signUp success updates state to authenticated', () async {
      await notifier.signUp('newuser', 'new@example.com', 'Secret123!');

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.username, 'newuser');
      expect(notifier.state.user?.email, 'new@example.com');
      expect(notifier.state.isLoading, isFalse);
    });

    test('signUp failure keeps isAuthenticated false and rethrows', () async {
      mockRepo.shouldFail = true;
      mockRepo.errorMessage = 'A user with this username or email already exists';

      expect(
        () => notifier.signUp('dupuser', 'dup@example.com', 'Pass123!'),
        throwsA(isA<Exception>()),
      );
      expect(notifier.state.isAuthenticated, isFalse);
    });

    test('logout clears user and updates state to unauthenticated', () async {
      await notifier.signIn('user_active', 'Pass123!');
      expect(notifier.state.isAuthenticated, isTrue);

      await notifier.logout();
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
      expect(mockRepo.wasLogoutCalled, isTrue);
    });

    test('restoreSession populates user when active token exists', () async {
      mockRepo.mockUser = UserModel(
        id: 'u_session',
        username: 'session_user',
        email: 'session@example.com',
        updatedAt: DateTime.now(),
      );

      await notifier.restoreSession();
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.id, 'u_session');
    });
  });

  group('SignInPage and CreateAccountPage Integration Widget Tests', () {
    testWidgets('SignInPage shows error when submitting empty fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SignInPage()),
          ),
        ),
      );

      // Tap Sign In button with empty fields
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pump();

      expect(find.text('Please fill in both username/email and password'), findsOneWidget);
    });

    testWidgets('SignInPage displays error message on failed login', (tester) async {
      final mockRepo = MockAuthRepository()
        ..shouldFail = true
        ..errorMessage = 'Invalid username/email or password';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SignInPage()),
          ),
        ),
      );

      // Fill in fields
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));

      await tester.enterText(textFields.at(0), 'unknown_user');
      await tester.enterText(textFields.at(1), 'wrong_pass');
      await tester.pump();

      // Tap Sign in
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pump(); // Start async call
      await tester.pump(const Duration(milliseconds: 100)); // Process SnackBar

      expect(find.text('Invalid username/email or password'), findsOneWidget);
    });

    testWidgets('CreateAccountPage validates inputs before submission', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CreateAccountPage()),
          ),
        ),
      );

      // Find Sign Up button
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pump();

      expect(find.text('Please check your input fields'), findsOneWidget);
    });

    testWidgets('CreateAccountPage locks email and hides Google Sign Up button when prefilledEmail is provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CreateAccountPage(prefilledEmail: 'user@gmail.com')),
          ),
        ),
      );

      // Email field should be prefilled with user@gmail.com
      expect(find.text('user@gmail.com'), findsOneWidget);
      // Lock icon should be visible
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      // "Sign up with Google" button should be hidden
      expect(find.text('Sign up with Google'), findsNothing);
      expect(find.text('Or'), findsNothing);
    });

    testWidgets('CreateAccountPage shows editable email and Google Sign Up button when prefilledEmail is not provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CreateAccountPage()),
          ),
        ),
      );

      // Lock icon should NOT be visible
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      // "Sign up with Google" button and "Or" divider should be visible
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
    });

    testWidgets('CreateAccountPage renders password criteria checklist', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CreateAccountPage()),
          ),
        ),
      );

      // Checklist items should be visible
      expect(
        find.text('• 3–20 characters (letters, numbers, underscores)\n• Can be changed once every 14 days'),
        findsOneWidget,
      );
      expect(find.text('At least 8 characters (8–64 characters)'), findsOneWidget);
      expect(find.text('At least 1 letter (a-z, A-Z)'), findsOneWidget);
      expect(find.text('At least 1 number (0-9)'), findsOneWidget);
    });

    testWidgets('CreateAccountPage prompts discard confirmation when user enters data and taps back', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateAccountPage(),
          ),
        ),
      );

      // Initially no discard dialog
      expect(find.text('Discard changes?'), findsNothing);

      // Enter username
      await tester.enterText(find.byType(TextField).first, 'my_username');
      await tester.pump();

      // Tap back button
      await tester.tap(find.byType(FigmaBackButton));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap 'Keep editing' -> dialog dismissed, stays on page
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Create an Account'), findsOneWidget);
    });
  });
}
