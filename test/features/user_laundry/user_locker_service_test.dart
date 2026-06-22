import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_locker_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late UserLockerService service;
  late DioAdapter adapter;

  setUp(() {
    final mock = createMockApiClient();
    adapter = mock.adapter;
    service = UserLockerService(mock.apiClient);
  });

  group('getStores()', () {
    test('returns list of stores', () async {
      adapter.onGet('/api/stores', (server) => server.reply(200, apiOk([
        {'id': 1, 'name': 'Cửa hàng A', 'address': '1 Đường ABC', 'active': true},
        {'id': 2, 'name': 'Cửa hàng B', 'address': '2 Đường XYZ', 'active': true},
      ])));

      final result = await service.getStores();

      expect(result, hasLength(2));
      expect(result.first.name, equals('Cửa hàng A'));
    });

    test('returns empty list when no stores', () async {
      adapter.onGet('/api/stores', (server) => server.reply(200, apiOk([])));

      final result = await service.getStores();
      expect(result, isEmpty);
    });
  });

  group('getLockersByStore()', () {
    test('returns lockers for a store', () async {
      adapter.onGet(
        '/api/lockers',
        (server) => server.reply(200, apiOk([
          {'id': 10, 'storeId': 1, 'code': 'LC001', 'name': 'Tủ A1', 'status': 'ACTIVE'},
          {'id': 11, 'storeId': 1, 'code': 'LC002', 'name': 'Tủ A2', 'status': 'ACTIVE'},
        ])),
        queryParameters: {'storeId': 1},
      );

      final result = await service.getLockersByStore(1);

      expect(result, hasLength(2));
      expect(result.first.code, equals('LC001'));
    });

    test('returns empty list when store has no lockers', () async {
      adapter.onGet(
        '/api/lockers',
        (server) => server.reply(200, apiOk([])),
        queryParameters: {'storeId': 99},
      );

      final result = await service.getLockersByStore(99);
      expect(result, isEmpty);
    });
  });

  group('getBoxes()', () {
    test('returns all boxes for a locker', () async {
      adapter.onGet('/api/lockers/10/boxes', (server) => server.reply(200, apiOk([
        {'id': 101, 'boxNumber': 1, 'status': 'AVAILABLE', 'cellType': 'STANDARD', 'size': 'SMALL'},
        {'id': 102, 'boxNumber': 2, 'status': 'OCCUPIED', 'cellType': 'XL', 'size': 'LARGE'},
        {'id': 103, 'boxNumber': 3, 'status': 'AVAILABLE', 'cellType': 'STANDARD', 'size': 'MEDIUM'},
      ])));

      final result = await service.getBoxes(10);

      expect(result, hasLength(3));
      expect(result.first.status, equals('AVAILABLE'));
      expect(result[1].status, equals('OCCUPIED'));
    });
  });

  group('getAvailableBoxes()', () {
    test('returns only available boxes', () async {
      adapter.onGet('/api/lockers/10/boxes/available', (server) => server.reply(200, apiOk([
        {'id': 101, 'boxNumber': 1, 'status': 'AVAILABLE', 'cellType': 'STANDARD', 'size': 'SMALL'},
        {'id': 103, 'boxNumber': 3, 'status': 'AVAILABLE', 'cellType': 'STANDARD', 'size': 'MEDIUM'},
      ])));

      final result = await service.getAvailableBoxes(10);

      expect(result, hasLength(2));
      expect(result.every((b) => b.status == 'AVAILABLE'), isTrue);
    });

    test('returns empty list when all boxes occupied', () async {
      adapter.onGet('/api/lockers/10/boxes/available', (server) => server.reply(200, apiOk([])));

      final result = await service.getAvailableBoxes(10);
      expect(result, isEmpty);
    });
  });

  group('reportLocker()', () {
    test('completes without throwing on success', () async {
      adapter.onPost('/api/lockers/10/report', (server) => server.reply(200, apiOk(null)));

      await expectLater(
        service.reportLocker(lockerId: 10, reason: 'FAULT', description: 'Khóa bị kẹt'),
        completes,
      );
    });

    test('throws on 404 when locker not found', () async {
      adapter.onPost('/api/lockers/999/report', (server) => server.reply(
        404,
        apiError('Tủ không tồn tại'),
      ));

      expect(
        () => service.reportLocker(lockerId: 999, reason: 'FAULT'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
