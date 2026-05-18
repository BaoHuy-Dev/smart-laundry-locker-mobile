import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/user/home/screens/home_screen.dart';
import '../features/user/lockers/screens/lockers_screen.dart';
import '../features/user/orders/screens/orders_screen.dart';
import '../features/user/notifications/screens/notifications_screen.dart';
import '../features/user/profile/screens/profile_screen.dart';
import '../features/partner/dashboard/screens/dashboard_screen.dart';
import '../features/partner/orders/screens/partner_orders_screen.dart';
import '../features/partner/profile/screens/partner_profile_screen.dart';

import '../features/user/orders/screens/create_order_screen.dart';
import '../features/user/orders/screens/confirm_order_screen.dart';
import '../features/user/stores/screens/stores_screen.dart';
import '../features/user/stores/screens/store_detail_screen.dart';
import '../features/user/stores/screens/favorites_screen.dart';
import '../features/user/promotions/screens/vouchers_screen.dart';

import '../core/models/user.dart';
import '../core/models/store.dart';
import '../core/models/service.dart';
import '../splash/splash_screen.dart';

/// Route name constants
class RouteNames {
  RouteNames._();

  // Auth
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';

  // User tabs
  static const String userHome = 'user-home';
  static const String userLockers = 'user-lockers';
  static const String userOrders = 'user-orders';
  static const String userNotifications = 'user-notifications';
  static const String userProfile = 'user-profile';

  // User standalone screens
  static const String createOrder = 'create-order';
  static const String confirmOrder = 'confirm-order';
  static const String vouchers = 'vouchers';
  static const String stores = 'stores';
  static const String storeDetail = 'store-detail';
  static const String favorites = 'favorites';

  // Partner tabs
  static const String partnerDashboard = 'partner-dashboard';
  static const String partnerOrders = 'partner-orders';
  static const String partnerProfile = 'partner-profile';
}

/// GoRouter configuration with auth redirection logic.
GoRouter createAppRouter(WidgetRef ref) {
  // Watch auth state to trigger redirect on login/logout
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Global redirect logic matching index.tsx
    redirect: (context, state) {
      final isGoingToSplash = state.matchedLocation == '/splash';

      // Still loading auth state
      if (authState is AsyncLoading ||
          !authState.hasValue ||
          authState.value?.isLoading == true) {
        return isGoingToSplash ? null : '/splash';
      }

      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      final role = authState.value?.role;
      final isGoingToAuth = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isGoingToAuth) {
        // User is not logged in but trying to access protected route
        return '/auth/login';
      }

      if (isAuthenticated && (isGoingToAuth || isGoingToSplash)) {
        // User is logged in but trying to access auth/splash screens
        if (role == UserRole.partner) {
          return '/partner/dashboard';
        } else {
          return '/user/home';
        }
      }

      return null; // No redirect needed
    },

    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // ─── Auth routes ───
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: RouteNames.register,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return RegisterScreen(
            idToken: params['idToken'],
            tempToken: params['tempToken'],
            method: params['method'],
          );
        },
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── User shell (bottom tabs) ───
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _UserShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/home',
                name: RouteNames.userHome,
                builder: (context, state) => const UserHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/lockers',
                name: RouteNames.userLockers,
                builder: (context, state) => const LockersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/orders',
                name: RouteNames.userOrders,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/notifications',
                name: RouteNames.userNotifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/profile',
                name: RouteNames.userProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─── Standalone User Routes (No Bottom TabBar) ───
      GoRoute(
        path: '/user/create-order',
        name: RouteNames.createOrder,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return CreateOrderScreen(
            storeId: int.tryParse(params['storeId'] ?? ''),
            storeName: params['storeName'],
            lockerId: int.tryParse(params['lockerId'] ?? ''),
            lockerName: params['lockerName'],
            boxId: int.tryParse(params['boxId'] ?? ''),
            boxNumber: params['boxNumber'],
          );
        },
      ),
      GoRoute(
        path: '/user/confirm-order',
        name: RouteNames.confirmOrder,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final category = params['selectedCategory'] == 'STORAGE'
              ? ServiceCategory.storage
              : ServiceCategory.laundry;
          final serviceIds = (params['serviceIds'] ?? '')
              .split(',')
              .map((id) => int.tryParse(id))
              .whereType<int>()
              .toList();

          return ConfirmOrderScreen(
            storeId: int.tryParse(params['storeId'] ?? '') ?? 0,
            storeName: params['storeName'] ?? '',
            lockerId: int.tryParse(params['lockerId'] ?? '') ?? 0,
            lockerName: params['lockerName'] ?? '',
            boxId: int.tryParse(params['boxId'] ?? '') ?? 0,
            boxNumber: params['boxNumber'] ?? '',
            category: category,
            serviceIds: serviceIds,
            prefilledPromoCode: params['prefilledPromoCode'],
          );
        },
      ),
      GoRoute(
        path: '/user/vouchers',
        name: RouteNames.vouchers,
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'] == 'rewards'
              ? VoucherTab.rewards
              : VoucherTab.vouchers;
          return VouchersScreen(initialTab: tab);
        },
      ),
      GoRoute(
        path: '/user/stores',
        name: RouteNames.stores,
        builder: (context, state) => const StoresScreen(),
      ),
      GoRoute(
        path: '/user/stores/:id',
        name: RouteNames.storeDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return StoreDetailScreen(
            storeId: id,
            initialStore: state.extra is Store ? state.extra as Store : null,
          );
        },
      ),
      GoRoute(
        path: '/user/favorites',
        name: RouteNames.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),

      // ─── Partner shell (bottom tabs) ───
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _PartnerShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/partner/dashboard',
                name: RouteNames.partnerDashboard,
                builder: (context, state) => const PartnerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/partner/orders',
                name: RouteNames.partnerOrders,
                builder: (context, state) => const PartnerOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/partner/profile',
                name: RouteNames.partnerProfile,
                builder: (context, state) => const PartnerProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ─── Temporary scaffolds (will be replaced in Phase 5-6) ───

class _UserShellScaffold extends StatelessWidget {
  const _UserShellScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Lockers'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class _PartnerShellScaffold extends StatelessWidget {
  const _PartnerShellScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
