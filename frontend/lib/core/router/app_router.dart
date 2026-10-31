import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/fridges/presentation/pages/my_fridges_page.dart';
import '../../features/fridges/presentation/pages/add_fridge_page.dart';
import '../../features/fridge_detail/presentation/pages/fridge_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/item/presentation/pages/add_item_page.dart';
import '../../features/item/presentation/pages/item_details_page.dart';
import '../../features/item/presentation/pages/edit_item_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/family/presentation/pages/family_share_page.dart';
import '../../features/family/presentation/pages/invite_member_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/sign-in',
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return CreateAccountPage(prefilledEmail: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/fridges',
        builder: (context, state) => const MyFridgesPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddFridgePage(),
          ),
          GoRoute(
            path: ':id',
            redirect: (context, state) {
              final id = state.pathParameters['id'];
              if (id == null || id.isEmpty) return '/fridges';
              return null;
            },
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FridgeDetailPage(fridgeId: id);
            },
            routes: [
              GoRoute(
                path: 'search',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return SearchPage(fridgeId: id);
                },
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return HistoryPage(fridgeId: id);
                },
              ),
              GoRoute(
                path: 'family',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final name = state.uri.queryParameters['name'] ?? 'Kitchen';
                  return FamilySharePage(fridgeId: id, fridgeName: name);
                },
                routes: [
                  GoRoute(
                    path: 'invite',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return InviteMemberPage(fridgeId: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'items/add',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AddItemPage(fridgeId: id);
                },
              ),
              GoRoute(
                path: 'items/:itemId',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final itemId = state.pathParameters['itemId'] ?? 'default_item';
                  return ItemDetailsPage(fridgeId: id, itemId: itemId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final itemId = state.pathParameters['itemId'] ?? 'default_item';
                      return EditItemPage(fridgeId: id, itemId: itemId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const EditProfilePage(),
          ),
        ],
      ),
    ],
  );
});
