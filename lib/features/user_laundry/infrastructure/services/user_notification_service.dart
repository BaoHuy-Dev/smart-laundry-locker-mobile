import 'package:smart_laundry_locker/features/user_laundry/infrastructure/models/user_laundry_models.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserNotificationService extends UserGatewayClient {
  UserNotificationService(super.apiClient);

  Future<List<UserLaundryNotification>> getNotifications() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/notifications/all',
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryNotification.fromJson)
        .where((notification) => notification.id > 0)
        .toList();
  }

  Future<List<UserLaundryNotification>> getUnread() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/notifications/unread',
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryNotification.fromJson)
        .where((notification) => notification.id > 0)
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/notifications/unread/count',
    );
    final data = unwrap(response);
    if (data is int) return data;
    if (data is num) return data.toInt();
    return int.tryParse(data?.toString() ?? '') ?? 0;
  }

  Future<void> markAsRead(int notificationId) async {
    await apiClient.patch<Map<String, dynamic>>(
      '/api/notifications/$notificationId/read',
    );
  }

  Future<void> markAllAsRead() async {
    await apiClient.patch<Map<String, dynamic>>('/api/notifications/read-all');
  }

  Future<void> deleteNotification(int notificationId) async {
    await apiClient.delete<Map<String, dynamic>>(
      '/api/notifications/$notificationId',
    );
  }
}
