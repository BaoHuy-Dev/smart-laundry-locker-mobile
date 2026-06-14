import 'package:smart_laundry_locker/core/routing/main_navigation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:smart_laundry_locker/features/auth/presentation/pages/login_screen.dart';
import 'package:smart_laundry_locker/features/auth/presentation/pages/otp_page.dart';
import 'package:smart_laundry_locker/features/auth/presentation/pages/splash_screen.dart';
import 'package:smart_laundry_locker/features/home/presentation/pages/home_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/locker_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/locker_map_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/locker_action_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/locker_otp_page.dart';
import 'package:smart_laundry_locker/features/delegations/presentation/pages/authorized_opening_page.dart';
import 'package:smart_laundry_locker/features/delegations/presentation/pages/my_delegations_page.dart';
import 'package:smart_laundry_locker/features/delegations/presentation/providers/delegation_injection.dart';
import 'package:smart_laundry_locker/features/maintenance/presentation/pages/create_report_page.dart';
import 'package:smart_laundry_locker/features/maintenance/presentation/pages/report_list_page.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:smart_laundry_locker/features/profile/domain/entities/user_profile.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/policy_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/profile_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/profile_detail_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/courier_detail_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/face_verify_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/face_registration_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/security_page.dart';
import 'package:smart_laundry_locker/features/subscription/presentation/pages/plans_page.dart';
import 'package:smart_laundry_locker/features/transactions/presentation/pages/transactions_page.dart';
import 'package:smart_laundry_locker/features/transactions/presentation/pages/top_up_page.dart';
import 'package:smart_laundry_locker/core/presentation/pages/qr_scanner_page.dart';
import 'package:smart_laundry_locker/core/presentation/pages/directions_map_page.dart';
import 'package:smart_laundry_locker/features/notifications/presentation/pages/notification_list_page.dart';
import 'package:smart_laundry_locker/features/vouchers/presentation/pages/my_vouchers_page.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_laundry_locker/features/courier_dispatch/presentation/pages/courier_dashboard_page.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/pages/active_delivery_page.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/params/logistics_success_load_params.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/pages/send_package_payment_page.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/pages/shipping_success_page.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/pages/courier_map_screen.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/pages/active_order_details_page.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/orders/presentation/pages/customer/customer_order_detail_page.dart';
import 'package:smart_laundry_locker/features/user_laundry/presentation/pages/user_laundry_order_page.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/manager_home_page.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/maintenance_home_page.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/send_parcel_page.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/rent_locker_page.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/my_locker_orders_page.dart';
import 'package:smart_laundry_locker/features/stores/domain/entities/store.dart';
import 'package:smart_laundry_locker/features/stores/presentation/pages/stores_page.dart';
import 'package:smart_laundry_locker/features/stores/presentation/pages/store_detail_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String lockers = '/lockers';
  static const String lockerMap = '/locker-map';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String profileDetail = '/profile/detail';
  static const String editProfile = '/profile/edit';
  static const String courierDetail = '/profile/courier-detail';
  static const String security = '/profile/security';
  static const String plans = '/profile/plans';
  static const String transactions = '/transactions';
  static const String topUp = '/top-up';
  static const String policy = '/policy';
  static const String lockerOtp = '/locker-otp';
  static const String createReport = '/maintenance/create-report';
  static const String myReports = '/maintenance/my-reports';
  static const String qrScan = '/qr-scan';
  static const String notifications = '/notifications';
  static const String courierDashboard = '/courier-dashboard';
  static const String activeDelivery = '/active-delivery';
  static const String faceVerify = '/auth/face-verify';
  static const String sendPackagePayment = '/send-package-payment';
  static const String shippingSuccess = '/shipping-success';
  static const String authorizedOpening = '/authorized-opening';
  static const String courierMap = '/courier-map';
  static const String activeOrderDetails = '/active-order-details';
  static const String faceRegistration = '/profile/face-registration';
  static const String orderDetail = '/orders/detail';
  static const String myDelegations = '/my-delegations';
  static const String myVouchers = '/my-vouchers';
  static const String userLaundryOrder = '/user/laundry-order';
  static const String managerHome = '/manager';
  static const String maintenanceHome = '/maintenance-home';
  static const String sendParcel = '/locker/send-parcel';
  static const String rentLocker = '/locker/rent';
  static const String myLockerOrders = '/locker/my-orders';
  static const String stores = '/stores';
  static const String storeDetail = '/stores/detail';
  static const String directions = '/directions';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    observers: [FlutterSmartDialog.observer],
    refreshListenable: TokenService.authState,
    redirect: (context, state) {
      final isLoggedIn = TokenService.authState.value;
      final location = state.matchedLocation;

      final isProtectedRoute = location == transactions || location == topUp;

      if (!isLoggedIn && isProtectedRoute) {
        return onboarding;
      }

      return null;
    },
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final Map<String, dynamic>? params =
              state.extra as Map<String, dynamic>?;
          return OtpPage(
            phoneNumber: params?['phoneNumber'] as String?,
            email: params?['email'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/profile/detail',
        name: 'profile_detail',
        builder: (context, state) => const ProfileDetailPage(),
      ),
      GoRoute(
        path: courierDetail,
        name: 'courier_detail',
        builder: (context, state) {
          final userId = state.extra as String?;
          return CourierDetailPage(userId: userId);
        },
      ),
      GoRoute(
        path: editProfile,
        name: 'edit_profile',
        builder: (context, state) {
          final extra = state.extra;
          final profile = extra is UserProfile ? extra : null;
          return EditProfilePage(profile: profile);
        },
      ),
      GoRoute(
        path: security,
        name: 'security',
        builder: (context, state) => const SecurityPage(),
      ),
      GoRoute(
        path: plans,
        name: 'plans',
        builder: (context, state) => const PlansPage(),
      ),
      GoRoute(
        path: lockerMap,
        builder: (context, state) => const LockerMapPage(),
      ),
      GoRoute(
        path: userLaundryOrder,
        name: 'user_laundry_order',
        builder: (context, state) {
          final map = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          return UserLaundryOrderPage(
            initialLockerId: map?['initialLockerId'] as int?,
            locationName: map?['locationName'] as String?,
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationWrapper(child: child);
        },
        routes: [
          GoRoute(path: home, builder: (context, state) => const HomePage()),
          GoRoute(
            path: lockers,
            builder: (context, state) => const LockerPage(),
          ),
          GoRoute(
            // Bottom-nav "Đơn hàng" shows the customer's real locker orders
            // (locker_ops). The legacy OrderPage hit the old /orders/me API and
            // is no longer wired to the current backend.
            path: orders,
            builder: (context, state) => const MyLockerOrdersPage(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: sendPackagePayment,
        name: 'send_package_payment',
        builder: (context, state) {
          final extra = state.extra;
          final map = extra is Map<String, dynamic> ? extra : null;
          return SendPackagePaymentPage(
            dispatchId: (map?['dispatchId'] as String?) ?? '',
            recipientName: (map?['recipientName'] as String?) ?? '',
            recipientPhone: (map?['recipientPhone'] as String?) ?? '',
            feeAmountVnd: (map?['feeAmountVnd'] as int?) ?? 35000,
            dispatchStatus: map?['dispatchStatus'] as String?,
          );
        },
      ),
      GoRoute(
        path: shippingSuccess,
        name: 'shipping_success',
        builder: (context, state) {
          final extra = state.extra;
          final loadParams = extra is LogisticsSuccessLoadParams ? extra : null;
          return ShippingSuccessPage(loadParams: loadParams);
        },
      ),
      GoRoute(
        path: orderDetail,
        name: 'order_detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Order) {
            return CustomerOrderDetailPage(orderId: extra.id, order: extra);
          }
          final qp = state.uri.queryParameters;
          final orderId =
              (extra is String ? extra : null) ?? qp['orderId'] ?? '';
          return CustomerOrderDetailPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/locker-action',
        name: 'locker_action',
        builder: (context, state) {
          final qp = state.uri.queryParameters;
          final extra = state.extra;
          final extraMap = extra is Map<String, dynamic> ? extra : null;

          final actionStr = (extraMap?['action'] as String?) ?? qp['action'];
          final LockerAction action = switch (actionStr?.toLowerCase()) {
            'rent' => LockerAction.rent,
            'send' => LockerAction.send,
            _ => (extra is LockerAction) ? extra : LockerAction.send,
          };

          final int initialStep =
              int.tryParse(
                (extraMap?['step']?.toString() ?? qp['step'] ?? ''),
              ) ??
              0;
          return LockerActionPage(
            action: action,
            initialStep: initialStep.clamp(0, 3),
            initialLocationId:
                (extraMap?['locationId'] as String?) ?? qp['locationId'],
            initialCabinetId:
                (extraMap?['cabinetId'] as String?) ?? qp['cabinetId'],
            initialSizeId: (extraMap?['sizeId'] as String?) ?? qp['sizeId'],
          );
        },
      ),
      GoRoute(
        path: lockerOtp,
        name: 'locker_otp',
        builder: (context, state) => const LockerOtpPage(),
      ),
      GoRoute(
        path: transactions,
        name: 'transactions',
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: topUp,
        name: 'top_up',
        builder: (context, state) => const TopUpPage(),
      ),
      GoRoute(
        path: policy,
        builder: (context, state) {
          final Map<String, dynamic>? params =
              state.extra as Map<String, dynamic>?;
          if (params == null ||
              !params.containsKey('title') ||
              !params.containsKey('assetPath')) {
            return const PolicyPage(
              title: 'Chính sách',
              assetPath: 'assets/markdown/privacy_policy.md',
            );
          }
          return PolicyPage(
            title: params['title'] as String,
            assetPath: params['assetPath'] as String,
          );
        },
      ),
      GoRoute(
        path: createReport,
        name: 'create_report',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return CreateReportPage(
            lockerId: params['lockerId'] as String,
            cabinetId: params['cabinetId'] as String,
            lockerName: params['lockerName'] as String?,
            cabinetName: params['cabinetName'] as String?,
          );
        },
      ),
      GoRoute(
        path: myReports,
        name: 'my_reports',
        builder: (context, state) => const ReportListPage(),
      ),
      GoRoute(
        path: qrScan,
        name: 'qr_scan',
        builder: (context, state) => const QrScannerPage(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationListPage(),
      ),
      GoRoute(
        path: courierDashboard,
        name: 'courier_dashboard',
        builder: (context, state) => const CourierDashboardPage(),
      ),
      GoRoute(
        path: faceVerify,
        builder: (context, state) => const FaceVerifyPage(),
      ),
      GoRoute(
        path: faceRegistration,
        name: 'face_registration',
        builder: (context, state) => const FaceRegistrationPage(),
      ),
      GoRoute(
        path: activeDelivery,
        name: 'active_delivery',
        builder: (context, state) {
          final initialOrder = (state.extra is CourierAcceptResponse)
              ? state.extra as CourierAcceptResponse
              : null;

          if (initialOrder != null) {
            final provider = context.read<CourierDeliveryProvider>();
            provider.updateActiveOrder(initialOrder);
          }

          return const ActiveDeliveryPage();
        },
      ),
      GoRoute(
        path: authorizedOpening,
        name: 'authorized_opening',
        builder: (context, state) {
          final Map<String, dynamic>? params =
              state.extra as Map<String, dynamic>?;
          return ChangeNotifierProvider(
            create: (_) =>
                DelegationInjection.provideDelegationProvider(ApiClient()),
            child: AuthorizedOpeningPage(
              orderId: params?['orderId'] as String?,
              orderCode: params?['orderCode'] as String?,
              lockerId: params?['lockerId'] as String?,
              accessCode: params?['accessCode'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: courierMap,
        name: 'courier_map',
        builder: (context, state) {
          final position = (state.extra is Position)
              ? state.extra as Position
              : null;
          return CourierMapScreen(initialPosition: position);
        },
      ),
      GoRoute(
        path: activeOrderDetails,
        name: 'active_order_details',
        builder: (context, state) {
          final courierOrder = state.extra as CourierOrder;
          return ActiveOrderDetailsPage(courierOrder: courierOrder);
        },
      ),
      GoRoute(
        path: myDelegations,
        name: 'my_delegations',
        builder: (context, state) => const MyDelegationsPage(),
      ),
      GoRoute(
        path: managerHome,
        name: 'manager_home',
        builder: (context, state) => const ManagerHomePage(),
      ),
      GoRoute(
        path: maintenanceHome,
        name: 'maintenance_home',
        builder: (context, state) => const MaintenanceHomePage(),
      ),
      GoRoute(
        path: sendParcel,
        name: 'send_parcel',
        builder: (context, state) {
          final map = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          return SendParcelPage(
            initialLockerId: map?['initialLockerId'] as int?,
            locationName: map?['locationName'] as String?,
          );
        },
      ),
      GoRoute(
        path: rentLocker,
        name: 'rent_locker',
        builder: (context, state) {
          final map = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          return RentLockerPage(
            initialLockerId: map?['initialLockerId'] as int?,
            locationName: map?['locationName'] as String?,
          );
        },
      ),
      GoRoute(
        path: myLockerOrders,
        name: 'my_locker_orders',
        builder: (context, state) => const MyLockerOrdersPage(),
      ),
      GoRoute(
        path: myVouchers,
        name: 'my_vouchers',
        builder: (context, state) => const MyVouchersPage(),
      ),
      GoRoute(
        path: stores,
        name: 'stores',
        builder: (context, state) => const StoresPage(),
      ),
      GoRoute(
        path: storeDetail,
        name: 'store_detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Store) {
            return StoreDetailPage(store: extra);
          }
          final id = int.tryParse(
            extra is String ? extra : (state.uri.queryParameters['id'] ?? ''),
          );
          if (id != null) {
            return StoreDetailPage(storeId: id);
          }
          return const StoresPage();
        },
      ),
      GoRoute(
        path: directions,
        name: 'directions',
        builder: (context, state) {
          final extra = state.extra;
          final map = extra is Map<String, dynamic>
              ? extra
              : const <String, dynamic>{};
          final lat = (map['lat'] as num?)?.toDouble();
          final lng = (map['lng'] as num?)?.toDouble();
          if (lat == null || lng == null) {
            return const Scaffold(
              body: Center(child: Text('Thiếu toạ độ điểm đến.')),
            );
          }
          return DirectionsMapPage(
            destination: LatLng(lat, lng),
            title: (map['title'] as String?) ?? 'Điểm đến',
            subtitle: map['subtitle'] as String?,
          );
        },
      ),
    ],
  );
}
