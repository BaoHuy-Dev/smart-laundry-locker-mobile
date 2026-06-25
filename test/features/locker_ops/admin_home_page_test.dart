import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/core/network/dio_client.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/admin_home_page.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late DioAdapter adapter;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    DioClient.instance.init(baseUrl: kTestBaseUrl);
    adapter = DioAdapter(
      dio: DioClient.instance.dio,
      matcher: const UrlRequestMatcher(),
    );
    _seedAllAdminRoutes(adapter);
  });

  Widget buildApp() => const MaterialApp(home: AdminHomePage());

  // ── Smoke test ─────────────────────────────────────────────────────────────

  group('Smoke — renders without crash', () {
    testWidgets('pumps and settles without exception', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
    });

    testWidgets('shows loading indicator before data arrives', (tester) async {
      await tester.pumpWidget(buildApp());
      // First frame: still loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  // ── Header ─────────────────────────────────────────────────────────────────

  group('Header', () {
    testWidgets('shows page title', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Quản trị hệ thống'), findsOneWidget);
    });

    testWidgets('shows user + store count in subtitle after visiting those tabs', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      // Navigate to Users tab to trigger its load
      await tester.tap(find.text('Người dùng').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('người dùng'), findsOneWidget);
      // Navigate to Stores tab to trigger its load
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('cửa hàng'), findsOneWidget);
    });
  });

  // ── Tab bar ────────────────────────────────────────────────────────────────

  group('Tab bar — 5 tabs present', () {
    testWidgets('Dashboard tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tổng quan'), findsNWidgets(2)); // tab label + section header
    });

    testWidgets('Người dùng tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Người dùng'), findsWidgets);
    });

    testWidgets('Cửa hàng tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Cửa hàng'), findsWidgets);
    });

    testWidgets('Đơn hàng tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Đơn hàng'), findsOneWidget);
    });

    testWidgets('Khuyến mãi tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Khuyến mãi'), findsOneWidget);
    });
  });

  // ── Tab 0: Dashboard ───────────────────────────────────────────────────────

  group('Dashboard tab content', () {
    testWidgets('shows all 4 metric card labels', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tổng đơn'), findsOneWidget);
      expect(find.text('DT hôm nay'), findsOneWidget);
    });

    testWidgets('shows metric values from mock API', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('150'), findsOneWidget); // totalOrders
      expect(find.text('42'), findsOneWidget);  // totalUsers
      expect(find.text('7'), findsOneWidget);   // totalStores
    });

    testWidgets('shows overview section label', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tổng quan'), findsNWidgets(2)); // tab label + section header
    });

    testWidgets('shows order stats section', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Đơn theo trạng thái'), findsOneWidget);
    });
  });

  // ── Tab 1: Users ────────────────────────────────────────────────────────────

  group('Users tab content', () {
    testWidgets('shows users from API after switching tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Người dùng').first);
      await tester.pumpAndSettle();
      expect(find.text('admin@test.com'), findsOneWidget);
      expect(find.text('customer@test.com'), findsOneWidget);
    });

    testWidgets('shows role chips', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Người dùng').first);
      await tester.pumpAndSettle();
      expect(find.text('ADMIN'), findsWidgets);
      expect(find.text('CUSTOMER'), findsOneWidget);
    });

    testWidgets('tapping user card opens action bottom sheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Người dùng').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('admin@test.com'));
      await tester.pumpAndSettle();
      expect(find.text('Đổi role'), findsOneWidget);
      expect(find.text('Khoá tài khoản'), findsOneWidget);
    });

    testWidgets('bottom sheet closes on dismiss', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Người dùng').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('admin@test.com'));
      await tester.pumpAndSettle();
      // Dismiss by tapping outside
      await tester.tapAt(const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(find.text('Đổi role'), findsNothing);
    });
  });

  // ── Tab 2: Stores ───────────────────────────────────────────────────────────

  group('Stores tab content', () {
    testWidgets('shows stores from API', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      expect(find.text('Chi nhánh Quận 1'), findsOneWidget);
      expect(find.text('1 Đường ABC'), findsOneWidget);
    });

    testWidgets('shows Thêm mới button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      expect(find.text('Thêm mới'), findsOneWidget);
    });

    testWidgets('tapping Thêm mới opens create dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm mới'));
      await tester.pumpAndSettle();
      expect(find.text('Thêm cửa hàng'), findsOneWidget);
      expect(find.text('Tên cửa hàng *'), findsOneWidget);
    });

    testWidgets('create dialog has Hủy button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm mới'));
      await tester.pumpAndSettle();
      expect(find.text('Hủy'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thêm cửa hàng'), findsNothing);
    });

    testWidgets('shows status toggle buttons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      // ACTIVE store shows 'Tắt' toggle
      expect(find.text('Tắt'), findsOneWidget);
    });
  });

  // ── Tab 3: Orders ───────────────────────────────────────────────────────────

  group('Orders tab content', () {
    testWidgets('shows filter chips', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);
      expect(find.text('Đã huỷ'), findsOneWidget);
    });

    testWidgets('shows orders from API', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.text('#500 · SEND'), findsOneWidget);
    });

    testWidgets('tapping order opens status bottom sheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đơn hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#500 · SEND'));
      await tester.pumpAndSettle();
      expect(find.text('Đổi trạng thái'), findsOneWidget);
      expect(find.text('Xác nhận'), findsOneWidget);
    });
  });

  // ── Tab 4: Promotions ───────────────────────────────────────────────────────

  group('Promotions tab content', () {
    testWidgets('shows promotions from API', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khuyến mãi'));
      await tester.pumpAndSettle();
      expect(find.text('SUMMER20'), findsOneWidget);
    });

    testWidgets('shows delete icon for each promotion', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khuyến mãi'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows Thêm mới button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khuyến mãi'));
      await tester.pumpAndSettle();
      expect(find.text('Thêm mới'), findsOneWidget);
    });

    testWidgets('tapping Thêm mới opens create dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khuyến mãi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm mới'));
      await tester.pumpAndSettle();
      expect(find.text('Tạo khuyến mãi'), findsOneWidget);
      expect(find.text('Mã code *'), findsOneWidget);
    });

    testWidgets('tapping delete shows confirm dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khuyến mãi'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Xoá khuyến mãi'), findsOneWidget);
      expect(find.textContaining('"SUMMER20"'), findsOneWidget);
    });

    testWidgets('confirm dialog Hủy closes without deleting', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khuyến mãi'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá khuyến mãi'), findsNothing);
      expect(find.text('SUMMER20'), findsOneWidget); // still visible
    });
  });

  // ── Empty states ────────────────────────────────────────────────────────────

  group('Empty states — when API returns no data', () {
    // All empty-state checks run in ONE test to avoid DioClient singleton
    // ordering issues when the outer setUp has already seeded success routes.
    testWidgets('all tabs show empty states when API returns empty data', (tester) async {
      _seedEmptyAdminRoutes();
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Header still renders
      expect(find.text('Quản trị hệ thống'), findsOneWidget);

      // Users tab
      await tester.tap(find.text('Người dùng').first);
      await tester.pumpAndSettle();
      expect(find.text('Chưa có người dùng'), findsOneWidget);

      // Stores tab
      await tester.tap(find.text('Cửa hàng').first);
      await tester.pumpAndSettle();
      expect(find.text('Chưa có cửa hàng nào'), findsOneWidget);

      // Orders tab
      await tester.tap(find.text('Đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.text('Không có đơn hàng nào'), findsOneWidget);

      // Promotions tab
      await tester.tap(find.text('Khuyến mãi').first);
      await tester.pumpAndSettle();
      expect(find.text('Chưa có khuyến mãi nào'), findsOneWidget);
    });
  });
}

// ── Test data helpers ──────────────────────────────────────────────────────────

/// Replaces the DioClient singleton adapter with empty-data responses.
/// Call this BEFORE pumpWidget inside a testWidgets body to ensure it wins
/// over the adapter registered in the outer setUp.
void _seedEmptyAdminRoutes() {
  final emptyAdapter = DioAdapter(
    dio: DioClient.instance.dio,
    matcher: const UrlRequestMatcher(),
  );
  emptyAdapter.onGet('/api/admin/dashboard/overview',
      (s) => s.reply(200, apiOk({})));
  emptyAdapter.onGet('/api/admin/orders/statistics',
      (s) => s.reply(200, apiOk({})));
  emptyAdapter.onGet('/api/admin/orders/revenue',
      (s) => s.reply(200, apiOk({})));
  emptyAdapter.onGet('/api/admin/users',
      (s) => s.reply(200, apiOk([])));
  emptyAdapter.onGet('/api/admin/stores',
      (s) => s.reply(200, apiOk([])));
  emptyAdapter.onGet('/api/admin/orders',
      (s) => s.reply(200, apiOk([])));
  emptyAdapter.onGet('/api/admin/promotions',
      (s) => s.reply(200, apiOk([])));
}

void _seedAllAdminRoutes(DioAdapter adapter) {
  adapter.onGet(
    '/api/admin/dashboard/overview',
    (server) => server.reply(200, apiOk({
      'totalOrders': 150,
      'totalUsers': 42,
      'totalStores': 7,
      'totalRevenue': 9000000,
    })),
  );
  adapter.onGet(
    '/api/admin/orders/statistics',
    (server) => server.reply(200, apiOk({
      'INITIALIZED': 10,
      'STORING': 35,
      'COMPLETED': 100,
      'CANCELED': 5,
    })),
  );
  adapter.onGet(
    '/api/admin/orders/revenue',
    (server) => server.reply(200, apiOk({
      'todayRevenue': 1500000,
      'weekRevenue': 8200000,
    })),
  );
  adapter.onGet(
    '/api/admin/users',
    (server) => server.reply(200, apiOk([
      {
        'id': 1,
        'email': 'admin@test.com',
        'fullName': 'Admin User',
        'roles': ['ADMIN'],
        'status': 'ACTIVE',
      },
      {
        'id': 2,
        'email': 'customer@test.com',
        'fullName': 'Customer One',
        'roles': ['CUSTOMER'],
        'status': 'ACTIVE',
      },
    ])),
  );
  adapter.onGet(
    '/api/admin/stores',
    (server) => server.reply(200, apiOk([
      {
        'id': 1,
        'name': 'Chi nhánh Quận 1',
        'address': '1 Đường ABC',
        'phone': '0901234567',
        'status': 'ACTIVE',
      },
    ])),
  );
  adapter.onGet(
    '/api/admin/orders',
    (server) => server.reply(200, apiOk([
      {
        'id': 500,
        'orderType': 'SEND',
        'status': 'STORING',
        'customerEmail': 'customer@test.com',
        'createdAt': '2026-06-24T10:00:00',
      },
    ])),
  );
  adapter.onGet(
    '/api/admin/promotions',
    (server) => server.reply(200, apiOk([
      {
        'id': 1,
        'code': 'SUMMER20',
        'discountType': 'PERCENT',
        'discountValue': 20,
        'status': 'ACTIVE',
        'startDate': '2026-06-01T00:00:00',
        'endDate': '2026-06-30T23:59:59',
      },
    ])),
  );
}
