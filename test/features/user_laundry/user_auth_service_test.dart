import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_auth_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late UserAuthService service;
  late DioAdapter adapter;

  setUp(() {
    final mock = createMockApiClient();
    adapter = mock.adapter;
    service = UserAuthService(mock.apiClient);
  });

  group('login()', () {
    test('saves tokens and returns user data on success', () async {
      adapter.onPost('/api/auth/login', (server) => server.reply(200, apiOk({
        'accessToken': makeFakeJwt(),
        'refreshToken': 'refresh_token_abc',
        'userId': 1,
        'email': 'test@example.com',
        'roles': ['CUSTOMER'],
      })));

      final result = await service.login(
        identifier: 'test@example.com',
        password: 'password123',
      );

      expect(result['email'], equals('test@example.com'));
      expect(result['roles'], contains('CUSTOMER'));
      expect(result['accessToken'], isNotNull);
    });

    test('throws on invalid credentials (401)', () async {
      adapter.onPost('/api/auth/login', (server) => server.reply(
        401,
        apiError('Sai email hoặc mật khẩu'),
      ));

      expect(
        () => service.login(identifier: 'bad@test.com', password: 'wrong'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('register()', () {
    test('returns new user data on success', () async {
      adapter.onPost('/api/auth/register', (server) => server.reply(200, apiOk({
        'userId': 2,
        'email': 'new@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'roles': ['CUSTOMER'],
      })));

      final result = await service.register(
        userId: 2,
        password: 'password123',
        email: 'new@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      expect(result['email'], equals('new@example.com'));
      expect(result['roles'], contains('CUSTOMER'));
    });

    test('throws ValidationException on duplicate email (400)', () async {
      adapter.onPost('/api/auth/register', (server) => server.reply(
        400,
        apiError('Email đã được sử dụng'),
      ));

      expect(
        () => service.register(userId: 2, password: 'pw', email: 'dup@test.com'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('email OTP flow', () {
    test('sendEmailOtp() completes without throwing', () async {
      adapter.onPost('/api/auth/email/send-otp', (server) => server.reply(200, apiOk(null)));

      await expectLater(
        service.sendEmailOtp('test@example.com'),
        completes,
      );
    });

    test('verifyEmailOtp() returns tempToken on success', () async {
      adapter.onPost('/api/auth/email/verify-otp', (server) => server.reply(200, apiOk({
        'tempToken': 'temp_abc123',
        'email': 'test@example.com',
      })));

      final result = await service.verifyEmailOtp(
        email: 'test@example.com',
        otp: '123456',
      );

      expect(result['tempToken'], equals('temp_abc123'));
    });

    test('verifyEmailOtp() throws on wrong OTP (400)', () async {
      adapter.onPost('/api/auth/email/verify-otp', (server) => server.reply(
        400,
        apiError('OTP không hợp lệ hoặc đã hết hạn'),
      ));

      expect(
        () => service.verifyEmailOtp(email: 'test@example.com', otp: '000000'),
        throwsA(isA<Exception>()),
      );
    });

    test('completeEmailRegistration() saves tokens and returns user', () async {
      adapter.onPost('/api/auth/email/complete-registration', (server) => server.reply(200, apiOk({
        'accessToken': makeFakeJwt(),
        'refreshToken': 'refresh_xyz',
        'userId': 3,
        'email': 'complete@example.com',
        'roles': ['CUSTOMER'],
      })));

      final result = await service.completeEmailRegistration(
        tempToken: 'temp_abc123',
        password: 'newPassword123',
        firstName: 'Bao',
        lastName: 'Huy',
      );

      expect(result['email'], equals('complete@example.com'));
    });
  });

  group('logout()', () {
    test('completes even if server returns error (clears local tokens)', () async {
      adapter.onPost('/api/auth/logout', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.logout(), completes);
    });
  });
}
