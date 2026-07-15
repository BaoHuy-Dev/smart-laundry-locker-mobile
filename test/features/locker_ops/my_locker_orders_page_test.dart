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
}
