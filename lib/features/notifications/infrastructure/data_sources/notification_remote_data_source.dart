import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/notifications/domain/entities/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  Future<void> registerDeviceToken({
    required String token,
    required String deviceType,
    required String deviceId,
  }) async {
    await _apiClient.post<dynamic>(
      '/users/notifications/device-tokens',
      data: {'token': token, 'deviceType': deviceType, 'deviceId': deviceId},
    );
  }

  Future<void> unregisterDeviceToken(String token) async {
    await _apiClient.delete<dynamic>(
      '/users/notifications/device-tokens',
      data: {'token': token},
    );
  }

  Future<NotificationListResponse> getNotifications({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );

    return NotificationListResponse.fromJson(
      response.data?['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/notifications/unread-count',
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data?['unreadCount'] as int? ?? 0;
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch<dynamic>(
      '/users/notifications/$notificationId/read',
    );
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put<dynamic>('/users/notifications/read-all');
  }
}
