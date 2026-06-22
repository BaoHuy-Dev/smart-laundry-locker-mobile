import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_payment_service.dart';

import '../../helpers/test_helpers.dart';

Map<String, dynamic> _payment({int id = 1, String method = 'WALLET', String status = 'COMPLETED'}) => {
  'id': id,
  'orderId': 100,
  'userId': 1,
  'amount': 30000.0,
  'method': method,
  'status': status,
  'createdAt': '2026-06-22T10:00:00',
};

void main() {
  late UserPaymentService service;
  late DioAdapter adapter;

  setUp(() {
    // createPayment calls currentUserId() — needs authenticated JWT
    final mock = createAuthenticatedApiClient();
    adapter = mock.adapter;
    service = UserPaymentService(mock.apiClient);
  });

  group('createPayment()', () {
    test('creates WALLET payment and returns payment object', () async {
      adapter.onPost('/api/payments', (server) => server.reply(200, apiOk(
        _payment(id: 1, method: 'WALLET', status: 'COMPLETED'),
      )));

      final result = await service.createPayment(
        orderId: 100,
        amount: 30000.0,
        method: 'WALLET',
      );

      expect(result.id, equals(1));
      expect(result.method, equals('WALLET'));
      expect(result.status, equals('COMPLETED'));
    });

    test('creates VNPAY payment and returns pending payment', () async {
      adapter.onPost('/api/payments', (server) => server.reply(200, apiOk(
        _payment(id: 2, method: 'VNPAY', status: 'PENDING'),
      )));

      final result = await service.createPayment(
        orderId: 100,
        amount: 30000.0,
        method: 'VNPAY',
        bankCode: 'NCB',
        language: 'vn',
      );

      expect(result.method, equals('VNPAY'));
      expect(result.status, equals('PENDING'));
    });

    test('throws on insufficient wallet balance (400)', () async {
      adapter.onPost('/api/payments', (server) => server.reply(
        400,
        apiError('Số dư ví không đủ'),
      ));

      expect(
        () => service.createPayment(orderId: 100, amount: 999999.0),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getPaymentsByOrder()', () {
    test('returns payment history for an order', () async {
      adapter.onGet('/api/payments/order/100', (server) => server.reply(200, apiOk([
        _payment(id: 1, method: 'WALLET', status: 'COMPLETED'),
        _payment(id: 2, method: 'VNPAY', status: 'FAILED'),
      ])));

      final result = await service.getPaymentsByOrder(100);

      expect(result, hasLength(2));
      expect(result.first.status, equals('COMPLETED'));
      expect(result.last.status, equals('FAILED'));
    });

    test('returns empty list when order has no payments', () async {
      adapter.onGet('/api/payments/order/100', (server) => server.reply(200, apiOk([])));

      final result = await service.getPaymentsByOrder(100);
      expect(result, isEmpty);
    });

    test('throws NotFoundException when order not found (404)', () async {
      adapter.onGet('/api/payments/order/999', (server) => server.reply(
        404,
        apiError('Đơn hàng không tồn tại'),
      ));

      expect(() => service.getPaymentsByOrder(999), throwsA(isA<Exception>()));
    });
  });
}
