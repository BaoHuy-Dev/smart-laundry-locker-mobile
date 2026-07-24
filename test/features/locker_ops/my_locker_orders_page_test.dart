import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/pages/my_locker_orders_page.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

import '../../helpers/test_helpers.dart';

class _FakeLockerOpsService extends LockerOpsService {
  _FakeLockerOpsService() : super(dio: createMockDio().dio);

  @override
  Future<List<Map<String, dynamic>>> myOrders() async => [
    {
      'id': 21,
      'type': 'DRONE_DELIVERY',
      'status': 'ACCEPTED',
      'deliveryStage': 'ACCEPTED',
      'paymentStatus': 'UNPAID',
      'pinCode': '123456',
      'qrToken': 'QR-123',
      'lockerId': 5,
      'orderCode': 'ORD-21',
      'createdAt': '2026-07-15T09:00:00',
    },
  ];

  @override
  Future<Map<String, dynamic>> locker(int lockerId) async => {
    'id': lockerId,
    'name': 'Tủ demo',
  };

  @override
  Future<Map<String, dynamic>> layout(int lockerId) async => {
    'cells': [
      {'id': 5001, 'boxNumber': 1},
    ],
  };

  @override
  Future<List<Map<String, dynamic>>> myReports() async => const [];
}

class _FakeRentalExtendLockerOpsService extends LockerOpsService {
  _FakeRentalExtendLockerOpsService() : super(dio: createMockDio().dio);

  final Map<String, dynamic> _order = {
    'id': 31,
    'type': 'RENTAL',
    'status': 'STORING',
    'paymentStatus': 'PAID',
    'totalPrice': 10000,
    'pickupDeadline': '2026-07-15T12:00:00',
    'lockerId': 5,
    'sendBoxId': 5001,
    'pinCode': '654321',
    'orderCode': 'ORD-31',
    'createdAt': '2026-07-15T09:00:00',
  };

  @override
  Future<List<Map<String, dynamic>>> myOrders() async => [Map.of(_order)];

  @override
  Future<Map<String, dynamic>> locker(int lockerId) async => {
    'id': lockerId,
    'name': 'Tủ thuê',
  };

  @override
  Future<Map<String, dynamic>> layout(int lockerId) async => {
    'cells': [
      {'id': 5001, 'boxNumber': 8},
    ],
  };

  @override
  Future<Map<String, dynamic>> extendRental(int orderId, int hours) async {
    _order['paymentStatus'] = 'UNPAID';
    _order['totalPrice'] = (_order['totalPrice'] as int) + 5000 * hours;
    return Map.of(_order);
  }

  @override
  Future<List<Map<String, dynamic>>> myReports() async => const [];
}

class _FakeFaultyOrderLockerOpsService extends LockerOpsService {
  _FakeFaultyOrderLockerOpsService() : super(dio: createMockDio().dio);

  @override
  Future<List<Map<String, dynamic>>> myOrders() async => [
    {
      'id': 41,
      'type': 'SEND',
      'status': 'INITIALIZED',
      'paymentStatus': 'UNPAID',
      'totalPrice': 15000,
      'lockerId': 7,
      'sendBoxId': 7003,
      'pinCode': '888999',
      'orderCode': 'ORD-41',
      'createdAt': '2026-07-15T09:00:00',
    },
  ];

  @override
  Future<Map<String, dynamic>> locker(int lockerId) async => {
    'id': lockerId,
    'name': 'Tủ lỗi',
  };

  @override
  Future<Map<String, dynamic>> layout(int lockerId) async => {
    'cells': [
      {'id': 7003, 'boxNumber': 3},
    ],
  };

  @override
  Future<List<Map<String, dynamic>>> myReports() async => [
    {
      'id': 901,
      'boxId': 7003,
      'boxNumber': 3,
      'lockerId': 7,
      'status': 'OPEN',
      'description': 'Kẹt cửa',
    },
  ];
}

void main() {
  setUp(() {
    mockSecureStorage({
      'access_token': makeFakeJwt(sub: '99', roles: ['CUSTOMER']),
    });
  });

  testWidgets('wraps drone order header and hides unpaid credentials', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 640)),
          child: MyLockerOrdersPage(service: _FakeLockerOpsService()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.ancestor(of: find.text('Đã tiếp nhận'), matching: find.byType(Wrap)),
      findsOneWidget,
    );

    await tester.tap(find.text('Tủ demo'));
    await tester.pumpAndSettle();

    expect(find.byType(AccessCredentials), findsNothing);
  });

  testWidgets('shows pay action after extending a previously paid rental', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: MyLockerOrdersPage(
            service: _FakeRentalExtendLockerOpsService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tủ thuê'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gia hạn thuê'));
    expect(find.text('Gia hạn thuê'), findsOneWidget);
    expect(find.textContaining('Thanh toán'), findsNothing);

    await tester.ensureVisible(find.text('Gia hạn thuê'));
    await tester.tap(find.text('Gia hạn thuê'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gia hạn'));
    await tester.tap(find.text('Gia hạn'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tủ thuê'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Thanh toán'), findsOneWidget);
  });

  testWidgets(
    'shows a fault warning for an order whose box was reported faulty',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: MyLockerOrdersPage(
              service: _FakeFaultyOrderLockerOpsService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ô số 3 đã được báo lỗi.'), findsOneWidget);
      expect(find.text('Hãy hủy đơn này và đặt ô khác.'), findsOneWidget);
    },
  );
}
