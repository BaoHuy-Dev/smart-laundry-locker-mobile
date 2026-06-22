import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_notification_service.dart';

import '../../helpers/test_helpers.dart';

Map<String, dynamic> _notif({int id = 1, bool read = false}) => {
  'id': id,
  'title': 'Thông báo $id',
  'body': 'Nội dung thông báo',
  'type': 'ORDER_STATUS',
  'read': read,
  'createdAt': '2026-06-22T10:00:00',
};

void main() {
  late UserNotificationService service;
  late DioAdapter adapter;

  setUp(() {
    final mock = createMockApiClient();
    adapter = mock.adapter;
    service = UserNotificationService(mock.apiClient);
  });

  group('getNotifications()', () {
    test('returns full notification list', () async {
      adapter.onGet('/api/notifications/all', (server) => server.reply(200, apiOk([
        _notif(id: 1, read: true),
        _notif(id: 2, read: false),
        _notif(id: 3, read: false),
      ])));

      final result = await service.getNotifications();

      expect(result, hasLength(3));
      expect(result.first.id, equals(1));
    });

    test('returns empty list when no notifications', () async {
      adapter.onGet('/api/notifications/all', (server) => server.reply(200, apiOk([])));

      final result = await service.getNotifications();
      expect(result, isEmpty);
    });
  });

  group('getUnread()', () {
    test('returns only unread notifications', () async {
      adapter.onGet('/api/notifications/unread', (server) => server.reply(200, apiOk([
        _notif(id: 2, read: false),
        _notif(id: 3, read: false),
      ])));

      final result = await service.getUnread();

      expect(result, hasLength(2));
      expect(result.every((n) => !n.read), isTrue);
    });
  });

  group('getUnreadCount()', () {
    test('returns integer count', () async {
      adapter.onGet('/api/notifications/unread/count', (server) => server.reply(200, apiOk(5)));

      final result = await service.getUnreadCount();
      expect(result, equals(5));
    });

    test('returns 0 when no unread', () async {
      adapter.onGet('/api/notifications/unread/count', (server) => server.reply(200, apiOk(0)));

      final result = await service.getUnreadCount();
      expect(result, equals(0));
    });
  });

  group('markAsRead()', () {
    test('completes without throwing', () async {
      adapter.onPatch('/api/notifications/1/read', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.markAsRead(1), completes);
    });
  });

  group('markAllAsRead()', () {
    test('completes without throwing', () async {
      adapter.onPatch('/api/notifications/read-all', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.markAllAsRead(), completes);
    });
  });

  group('deleteNotification()', () {
    test('completes without throwing', () async {
      adapter.onDelete('/api/notifications/1', (server) => server.reply(200, apiOk(null)));

      await expectLater(service.deleteNotification(1), completes);
    });

    test('throws NotFoundException on 404', () async {
      adapter.onDelete('/api/notifications/999', (server) => server.reply(
        404,
        apiError('Thông báo không tồn tại'),
      ));

      expect(() => service.deleteNotification(999), throwsA(isA<Exception>()));
    });
  });
}
