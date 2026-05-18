import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/notification.dart';
import '../network/api_client.dart';

/// Notification Service — replaces notificationService.ts
class NotificationService {
  NotificationService._();

  static final _dio = ApiClient.instance;

  /// Get notifications for current user
  static Future<ApiResponse<PaginatedResponse<AppNotification>>>
  getNotifications({int page = 0, int size = 20, bool? unreadOnly}) async {
    final Map<String, dynamic> params = {'page': page, 'size': size};
    if (unreadOnly != null) params['unreadOnly'] = unreadOnly;

    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: params,
    );
    return ApiResponse<PaginatedResponse<AppNotification>>.fromJson(
      response.data,
      (json) => PaginatedResponse<AppNotification>.fromJson(
        json as Map<String, dynamic>,
        (item) => AppNotification.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  /// Mark all notifications as read
  static Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    final response = await _dio.put(ApiEndpoints.notificationsReadAll);
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  static Future<ApiResponse<List<AppNotification>>>
  getAllNotifications() async {
    final response = await _dio.get(ApiEndpoints.allNotifications);
    return ApiResponse<List<AppNotification>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<List<AppNotification>>>
  getUnreadNotifications() async {
    final response = await _dio.get(ApiEndpoints.unreadNotifications);
    return ApiResponse<List<AppNotification>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.unreadNotificationCount);
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<AppNotification>> markAsRead(int id) async {
    final response = await _dio.put(ApiEndpoints.notificationRead(id));
    return ApiResponse<AppNotification>.fromJson(
      response.data,
      (json) => AppNotification.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> markBatchAsRead(
    List<int> notificationIds,
  ) async {
    final response = await _dio.put(
      ApiEndpoints.notificationsReadBatch,
      data: {'notificationIds': notificationIds},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> deleteNotification(
    int id,
  ) async {
    final response = await _dio.delete(ApiEndpoints.notificationById(id));
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>>
  deleteAllNotifications() async {
    final response = await _dio.delete(ApiEndpoints.notificationsAll);
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
}
