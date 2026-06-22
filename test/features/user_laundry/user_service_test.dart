import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late UserService service;
  late DioAdapter adapter;

  setUp(() {
    final mock = createMockApiClient();
    adapter = mock.adapter;
    service = UserService(mock.apiClient);
  });

  group('getProfile()', () {
    test('returns user profile map', () async {
      adapter.onGet('/api/user/profile', (server) => server.reply(200, apiOk({
        'id': 1,
        'email': 'user@example.com',
        'firstName': 'Bao',
        'lastName': 'Huy',
        'phoneNumber': '0901234567',
        'roles': ['CUSTOMER'],
        'walletBalance': 50000.0,
      })));

      final result = await service.getProfile();

      expect(result['email'], equals('user@example.com'));
      expect(result['firstName'], equals('Bao'));
      expect(result['walletBalance'], equals(50000.0));
    });

    test('throws AuthenticationException on 401', () async {
      adapter.onGet('/api/user/profile', (server) => server.reply(
        401,
        apiError('Unauthorized'),
      ));

      expect(() => service.getProfile(), throwsA(isA<Exception>()));
    });
  });

  group('updateProfile()', () {
    test('returns updated profile map', () async {
      adapter.onPut('/api/user/profile', (server) => server.reply(200, apiOk({
        'id': 1,
        'email': 'user@example.com',
        'firstName': 'Bao Updated',
        'lastName': 'Huy',
        'phoneNumber': '0901234567',
      })));

      final result = await service.updateProfile({
        'firstName': 'Bao Updated',
        'phoneNumber': '0901234567',
      });

      expect(result['firstName'], equals('Bao Updated'));
    });
  });

  group('getStatistics()', () {
    test('returns stats map', () async {
      adapter.onGet('/api/user/me/statistics', (server) => server.reply(200, apiOk({
        'totalOrders': 12,
        'completedOrders': 10,
        'totalSpent': 350000.0,
        'loyaltyPoints': 210,
      })));

      final result = await service.getStatistics();

      expect(result['totalOrders'], equals(12));
      expect(result['completedOrders'], equals(10));
      expect(result['totalSpent'], equals(350000.0));
    });
  });

  group('updateFcmToken()', () {
    test('completes without throwing', () async {
      adapter.onPost('/api/user/fcm-token', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.updateFcmToken('fcm_token_xyz'), completes);
    });
  });

  group('changePassword()', () {
    test('completes on success', () async {
      adapter.onPut('/api/user/password', (server) => server.reply(200, apiOk(null)));

      await expectLater(
        service.changePassword(oldPassword: 'oldPass123', newPassword: 'newPass456'),
        completes,
      );
    });

    test('throws on wrong old password (400)', () async {
      adapter.onPut('/api/user/password', (server) => server.reply(
        400,
        apiError('Mật khẩu cũ không đúng'),
      ));

      expect(
        () => service.changePassword(oldPassword: 'wrong', newPassword: 'new'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
