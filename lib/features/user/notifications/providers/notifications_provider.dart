import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/notification.dart';
import '../../../../core/services/notification_service.dart';

part 'notifications_provider.g.dart';

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  FutureOr<List<AppNotification>> build() async {
    return _fetchNotifications();
  }

  Future<List<AppNotification>> _fetchNotifications() async {
    try {
      final response = await NotificationService.getNotifications(size: 30);
      return response.data.content;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      // Update local state instead of refetching to save network
      if (state.hasValue && state.value != null) {
        final updatedList = state.value!
            .map((n) => n.copyWith(isRead: true))
            .toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    await NotificationService.markAsRead(notification.id);
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(
        state.value!
            .map(
              (item) => item.id == notification.id
                  ? item.copyWith(isRead: true)
                  : item,
            )
            .toList(),
      );
    }
  }

  Future<void> deleteNotification(AppNotification notification) async {
    await NotificationService.deleteNotification(notification.id);
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(
        state.value!.where((item) => item.id != notification.id).toList(),
      );
    }
  }

  Future<void> deleteAllNotifications() async {
    await NotificationService.deleteAllNotifications();
    state = const AsyncValue.data([]);
  }
}
