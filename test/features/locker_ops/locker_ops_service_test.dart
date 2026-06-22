import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late LockerOpsService service;
  late DioAdapter adapter;

  setUp(() {
    final mock = createMockDio();
    adapter = mock.adapter;
    service = LockerOpsService(dio: mock.dio);
  });

  // ── STAFF ────────────────────────────────────────────────────────────────

  group('STAFF endpoints', () {
    group('staffLockers()', () {
      test('returns list of lockers on success', () async {
        adapter.onGet('/api/staff/lockers', (server) => server.reply(200, apiOk([
          {'id': 1, 'name': 'Tủ A1', 'code': 'LA001', 'status': 'ACTIVE', 'address': '1 Đường ABC'},
          {'id': 2, 'name': 'Tủ B2', 'code': 'LB002', 'status': 'ACTIVE', 'address': '2 Đường XYZ'},
        ])));

        final result = await service.staffLockers();
        expect(result, hasLength(2));
        expect(result.first['name'], equals('Tủ A1'));
        expect(result.last['code'], equals('LB002'));
      });

      test('returns empty list when data is empty array', () async {
        adapter.onGet('/api/staff/lockers', (server) => server.reply(200, apiOk([])));

        final result = await service.staffLockers();
        expect(result, isEmpty);
      });
    });

    group('staffLayout()', () {
      test('returns layout map for a locker', () async {
        adapter.onGet('/api/staff/lockers/1/layout', (server) => server.reply(200, apiOk({
          'lockerId': 1,
          'rows': 3,
          'columns': 4,
          'boxes': [
            {'id': 101, 'boxNumber': 1, 'status': 'AVAILABLE', 'cellType': 'STANDARD'},
            {'id': 102, 'boxNumber': 2, 'status': 'OCCUPIED', 'cellType': 'XL'},
          ],
        })));

        final result = await service.staffLayout(1);
        expect(result['rows'], equals(3));
        expect(result['columns'], equals(4));
        expect((result['boxes'] as List).length, equals(2));
      });
    });

    group('staffOrders()', () {
      test('returns active orders list', () async {
        adapter.onGet('/api/staff/orders', (server) => server.reply(200, apiOk([
          {'id': 1001, 'type': 'SEND', 'status': 'STORING', 'lockerId': 1},
          {'id': 1002, 'type': 'RENTAL', 'status': 'INITIALIZED', 'lockerId': 2},
        ])));

        final result = await service.staffOrders();
        expect(result, hasLength(2));
        expect(result.first['type'], equals('SEND'));
        expect(result.last['status'], equals('INITIALIZED'));
      });
    });

    group('staffStats()', () {
      test('returns stats map', () async {
        adapter.onGet('/api/staff/lockers/stats', (server) => server.reply(200, apiOk({
          'totalLockers': 3,
          'totalBoxes': 36,
          'available': 20,
          'occupied': 12,
          'fault': 4,
        })));

        final result = await service.staffStats();
        expect(result['totalBoxes'], equals(36));
        expect(result['available'], equals(20));
        expect(result['fault'], equals(4));
      });
    });
  });

  // ── TECHNICIAN ────────────────────────────────────────────────────────────

  group('TECHNICIAN endpoints', () {
    group('techDevices()', () {
      test('returns device list with status', () async {
        adapter.onGet('/api/technician/devices', (server) => server.reply(200, apiOk([
          {'id': 1, 'deviceId': 'DEV-001', 'lockerId': 10, 'status': 'ONLINE', 'lastSeenAt': '2026-06-22T10:00:00'},
          {'id': 2, 'deviceId': 'DEV-002', 'lockerId': 11, 'status': 'OFFLINE', 'lastSeenAt': '2026-06-21T09:00:00'},
        ])));

        final result = await service.techDevices();
        expect(result, hasLength(2));
        expect(result.first['status'], equals('ONLINE'));
        expect(result.last['status'], equals('OFFLINE'));
      });

      test('returns empty list when no devices', () async {
        adapter.onGet('/api/technician/devices', (server) => server.reply(200, apiOk([])));

        final result = await service.techDevices();
        expect(result, isEmpty);
      });
    });

    group('techDeviceDetail()', () {
      test('returns device detail map', () async {
        adapter.onGet('/api/technician/devices/1', (server) => server.reply(200, apiOk({
          'id': 1,
          'deviceId': 'DEV-001',
          'lockerId': 10,
          'status': 'ONLINE',
          'model': 'RPi-4B',
          'firmwareVersion': '2.1.0',
          'lastSeenAt': '2026-06-22T10:00:00',
        })));

        final result = await service.techDeviceDetail(1);
        expect(result['deviceId'], equals('DEV-001'));
        expect(result['model'], equals('RPi-4B'));
        expect(result['status'], equals('ONLINE'));
      });
    });

    group('techDeviceLogs()', () {
      test('returns audit log entries', () async {
        adapter.onGet('/api/technician/devices/1/logs', (server) => server.reply(200, apiOk([
          {'id': 1, 'result': 'UNLOCK_SUCCESS', 'message': 'Box 3 opened', 'createdAt': '2026-06-22T09:30:00'},
          {'id': 2, 'result': 'RESTART_REQUESTED', 'message': 'Technician restart', 'createdAt': '2026-06-22T08:00:00'},
        ])));

        final result = await service.techDeviceLogs(1);
        expect(result, hasLength(2));
        expect(result.first['result'], equals('UNLOCK_SUCCESS'));
        expect(result.last['result'], equals('RESTART_REQUESTED'));
      });
    });

    group('techUpdateStatus()', () {
      test('completes without throwing on success', () async {
        adapter.onPut('/api/technician/devices/1/status', (server) => server.reply(200, apiOk({
          'id': 1,
          'status': 'OFFLINE',
          'lastSeenAt': '2026-06-22T10:05:00',
        })));

        await expectLater(service.techUpdateStatus(1, 'OFFLINE'), completes);
      });
    });

    group('techRestartDevice()', () {
      test('completes without throwing on success', () async {
        adapter.onPost('/api/technician/devices/1/restart', (server) => server.reply(200, apiOk({
          'deviceId': 'DEV-001',
          'lockerId': 10,
        })));

        await expectLater(service.techRestartDevice(1), completes);
      });
    });
  });

  // ── MAINTENANCE ───────────────────────────────────────────────────────────

  group('MAINTENANCE endpoints', () {
    test('faults() returns fault cell list', () async {
      adapter.onGet('/api/maintenance/faults', (server) => server.reply(200, apiOk([
        {'boxId': 5, 'boxNumber': 5, 'lockerId': 1, 'lockerName': 'Tủ A1', 'faultReason': 'Khóa kẹt'},
      ])));

      final result = await service.faults();
      expect(result.first['faultReason'], equals('Khóa kẹt'));
    });

    test('claimReport() returns updated report', () async {
      adapter.onPut('/api/maintenance/reports/42/claim', (server) => server.reply(200, apiOk({
        'id': 42, 'status': 'IN_PROGRESS',
      })));

      final result = await service.claimReport(42);
      expect(result['status'], equals('IN_PROGRESS'));
    });

    test('resolveReport() returns resolved report', () async {
      adapter.onPut('/api/maintenance/reports/42/resolve', (server) => server.reply(200, apiOk({
        'id': 42, 'status': 'RESOLVED',
      })));

      final result = await service.resolveReport(42);
      expect(result['status'], equals('RESOLVED'));
    });

    test('clearFault() succeeds', () async {
      adapter.onPost('/api/maintenance/boxes/5/clear-fault', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.clearFault(5), completes);
    });

    test('forceOpenBox() succeeds', () async {
      adapter.onPost('/api/maintenance/boxes/5/force-open', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.forceOpenBox(5), completes);
    });
  });

  // ── MANAGER ───────────────────────────────────────────────────────────────

  group('MANAGER endpoints', () {
    test('managerStats() returns stats list', () async {
      adapter.onGet('/api/manage/lockers/stats', (server) => server.reply(200, apiOk([
        {'lockerId': 1, 'lockerName': 'Tủ A1', 'totalBoxes': 12, 'available': 8, 'occupied': 3, 'fault': 1},
      ])));

      final result = await service.managerStats();
      expect(result.first['totalBoxes'], equals(12));
      expect(result.first['available'], equals(8));
    });

    test('managerOrders() with status filter', () async {
      adapter.onGet('/api/manage/orders', (server) => server.reply(200, apiOk([
        {'id': 200, 'type': 'SEND', 'status': 'STORING'},
      ])), queryParameters: {'status': 'STORING'});

      final result = await service.managerOrders(status: 'STORING');
      expect(result.first['status'], equals('STORING'));
    });
  });

  // ── CUSTOMER — Order flow ────────────────────────────────────────────────

  group('CUSTOMER order flow', () {
    test('myOrders() returns order list', () async {
      adapter.onGet('/api/orders/my-orders', (server) => server.reply(200, apiOk([
        {'id': 300, 'type': 'SEND', 'status': 'INITIALIZED', 'paymentStatus': 'UNPAID', 'totalPrice': 15000},
        {'id': 301, 'type': 'RENTAL', 'status': 'STORING', 'paymentStatus': 'PAID', 'totalPrice': 30000},
      ])));

      final result = await service.myOrders();
      expect(result, hasLength(2));
      expect(result.first['paymentStatus'], equals('UNPAID'));
    });

    test('confirmDrop() returns updated order', () async {
      adapter.onPut('/api/orders/300/confirm', (server) => server.reply(200, apiOk({
        'id': 300, 'status': 'STORING',
      })));

      final result = await service.confirmDrop(300);
      expect(result['status'], equals('STORING'));
    });

    test('completePickup() returns completed order', () async {
      adapter.onPut('/api/orders/300/complete', (server) => server.reply(200, apiOk({
        'id': 300, 'status': 'COMPLETED',
      })));

      final result = await service.completePickup(300);
      expect(result['status'], equals('COMPLETED'));
    });

    test('cancelOrder() succeeds', () async {
      adapter.onPut('/api/orders/300/cancel', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.cancelOrder(300), completes);
    });
  });

  // ── PAYMENT ──────────────────────────────────────────────────────────────

  group('Payment checkout', () {
    test('checkout() WALLET returns no paymentUrl', () async {
      adapter.onPost('/api/payments/checkout', (server) => server.reply(200, apiOk({
        'orderId': 300,
        'method': 'WALLET',
        'status': 'COMPLETED',
      })));

      final result = await service.checkout(300, 'WALLET');
      expect(result.containsKey('paymentUrl'), isFalse);
      expect(result['status'], equals('COMPLETED'));
    });

    test('checkout() VNPAY returns paymentUrl', () async {
      adapter.onPost('/api/payments/checkout', (server) => server.reply(200, apiOk({
        'orderId': 300,
        'method': 'VNPAY',
        'paymentUrl': 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?abc=123',
      })));

      final result = await service.checkout(300, 'VNPAY', returnUrl: 'http://localhost/callback');
      expect(result['paymentUrl'], startsWith('https://sandbox.vnpayment.vn'));
    });

    test('checkout() on 400 throws exception', () async {
      adapter.onPost('/api/payments/checkout', (server) => server.reply(400, apiError('Đơn đã được thanh toán')));

      expect(() => service.checkout(300, 'WALLET'), throwsA(isA<Exception>()));
    });
  });
}
