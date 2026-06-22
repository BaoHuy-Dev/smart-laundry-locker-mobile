import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_order_service.dart';

import '../../helpers/test_helpers.dart';

// Minimal order fixture reused across tests
Map<String, dynamic> _order({
  int id = 1,
  String type = 'SEND',
  String status = 'INITIALIZED',
}) => {
  'id': id,
  'type': type,
  'status': status,
  'paymentStatus': 'UNPAID',
  'totalPrice': 20000,
  'storeId': 1,
  'lockerId': 1,
  'userId': 1,
};

void main() {
  late UserOrderService service;
  late DioAdapter adapter;

  setUp(() {
    // createPayment/createLaundryOrder call currentUserId() → needs JWT in storage
    final mock = createAuthenticatedApiClient();
    adapter = mock.adapter;
    service = UserOrderService(mock.apiClient);
  });

  group('getMyOrders()', () {
    test('returns list of orders', () async {
      adapter.onGet('/api/orders/my-orders', (server) => server.reply(200, apiOk([
        _order(id: 1, type: 'SEND', status: 'INITIALIZED'),
        _order(id: 2, type: 'RENTAL', status: 'STORING'),
      ])));

      final result = await service.getMyOrders();

      expect(result, hasLength(2));
      expect(result.first.type, equals('SEND'));
      expect(result.last.status, equals('STORING'));
    });

    test('filters by status query param', () async {
      adapter.onGet(
        '/api/orders/my-orders',
        (server) => server.reply(200, apiOk([_order(status: 'COMPLETED')])),
        queryParameters: {'page': 0, 'size': 20, 'status': 'COMPLETED'},
      );

      final result = await service.getMyOrders(status: 'COMPLETED');

      expect(result.first.status, equals('COMPLETED'));
    });

    test('returns empty list when no orders', () async {
      adapter.onGet('/api/orders/my-orders', (server) => server.reply(200, apiOk([])));

      final result = await service.getMyOrders();
      expect(result, isEmpty);
    });
  });

  group('getOrder()', () {
    test('returns a single order by id', () async {
      adapter.onGet('/api/orders/42', (server) => server.reply(200, apiOk(_order(id: 42))));

      final result = await service.getOrder(42);

      expect(result.id, equals(42));
    });

    test('throws NotFoundException on 404', () async {
      adapter.onGet('/api/orders/999', (server) => server.reply(
        404,
        apiError('Đơn hàng không tồn tại'),
      ));

      expect(() => service.getOrder(999), throwsA(isA<Exception>()));
    });
  });

  group('getOrderStatus()', () {
    test('returns status-only order object', () async {
      adapter.onGet('/api/orders/1/status', (server) => server.reply(200, apiOk(
        _order(id: 1, status: 'STORING'),
      )));

      final result = await service.getOrderStatus(1);
      expect(result.status, equals('STORING'));
    });
  });

  group('createLaundryOrder()', () {
    test('creates order and returns new order object', () async {
      adapter.onPost('/api/orders', (server) => server.reply(200, apiOk(
        _order(id: 10, type: 'LAUNDRY', status: 'INITIALIZED'),
      )));

      final result = await service.createLaundryOrder(
        storeId: 1,
        lockerId: 1,
        sendBoxId: 5,
        serviceCategory: 'WASHING',
        serviceIds: [1, 2],
      );

      expect(result.id, equals(10));
      expect(result.type, equals('LAUNDRY'));
    });
  });

  group('confirmOrder()', () {
    test('returns confirmed order', () async {
      adapter.onPost('/api/orders/1/confirm', (server) => server.reply(200, apiOk(
        _order(id: 1, status: 'CONFIRMED'),
      )));

      final result = await service.confirmOrder(1);
      expect(result.status, equals('CONFIRMED'));
    });
  });

  group('cancelOrder()', () {
    test('returns cancelled order', () async {
      adapter.onPost('/api/orders/1/cancel', (server) => server.reply(200, apiOk(
        _order(id: 1, status: 'CANCELLED'),
      )));

      final result = await service.cancelOrder(1, reason: 'Thay đổi kế hoạch');
      expect(result.status, equals('CANCELLED'));
    });

    test('throws when order already completed (400)', () async {
      adapter.onPost('/api/orders/1/cancel', (server) => server.reply(
        400,
        apiError('Không thể hủy đơn đã hoàn thành'),
      ));

      expect(
        () => service.cancelOrder(1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
