import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../core/models/notification.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return notificationsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Thông báo')),
        body: Center(
          child: Text(
            'Đã có lỗi: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (notifications) {
        final unreadCount = notifications.where((item) => !item.isRead).length;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Thông báo'),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Badge(label: Text(unreadCount.toString())),
                ],
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Đánh dấu tất cả đã đọc',
                onPressed: unreadCount == 0
                    ? null
                    : () => _runAction(
                        context,
                        () => ref
                            .read(notificationsNotifierProvider.notifier)
                            .markAllAsRead(),
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Xóa tất cả',
                onPressed: notifications.isEmpty
                    ? null
                    : () => _confirmDeleteAll(context, ref),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationsNotifierProvider.notifier).refresh(),
            child: notifications.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 160),
                      _EmptyNotifications(),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onTap: () => _runAction(
                          context,
                          () => ref
                              .read(notificationsNotifierProvider.notifier)
                              .markAsRead(notification),
                        ),
                        onDelete: () => _runAction(
                          context,
                          () => ref
                              .read(notificationsNotifierProvider.notifier)
                              .deleteNotification(notification),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo'),
        content: const Text('Bạn có chắc muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!context.mounted) return;
      await _runAction(
        context,
        () => ref
            .read(notificationsNotifierProvider.notifier)
            .deleteAllNotifications(),
      );
    }
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể cập nhật thông báo lúc này')),
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final iconInfo = _notificationIcon(notification.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? Colors.white : const Color(0xFFF8FAFC),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: iconInfo.color.withValues(alpha: 0.14),
          foregroundColor: iconInfo.color,
          child: Icon(iconInfo.icon),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.w600
                      : FontWeight.w900,
                ),
              ),
            ),
            if (!notification.isRead)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(radius: 4, backgroundColor: Colors.blue),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaChip(
                    icon: Icons.schedule,
                    label: _timeAgo(notification.createdAt),
                  ),
                  _MetaChip(
                    icon: Icons.category,
                    label: notification.type.name.toUpperCase(),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.close),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.textTheme.bodySmall),
      ],
    );
  }
}

class _NotificationIconInfo {
  const _NotificationIconInfo(this.icon, this.color);

  final IconData icon;
  final Color color;
}

_NotificationIconInfo _notificationIcon(NotificationType type) {
  return switch (type) {
    NotificationType.orderCreated => const _NotificationIconInfo(
      Icons.add_shopping_cart,
      Color(0xFF2196F3),
    ),
    NotificationType.orderConfirmed => const _NotificationIconInfo(
      Icons.check_circle,
      Color(0xFF4CAF50),
    ),
    NotificationType.orderCollected => const _NotificationIconInfo(
      Icons.local_shipping,
      Color(0xFFFF9800),
    ),
    NotificationType.orderProcessing => const _NotificationIconInfo(
      Icons.local_laundry_service,
      Color(0xFF9C27B0),
    ),
    NotificationType.orderReady => const _NotificationIconInfo(
      Icons.done_all,
      Color(0xFF4CAF50),
    ),
    NotificationType.orderReturned => const _NotificationIconInfo(
      Icons.inventory,
      Color(0xFF00BCD4),
    ),
    NotificationType.orderCompleted => const _NotificationIconInfo(
      Icons.celebration,
      Color(0xFF8BC34A),
    ),
    NotificationType.orderCanceled => const _NotificationIconInfo(
      Icons.cancel,
      Color(0xFFF44336),
    ),
    NotificationType.paymentSuccess => const _NotificationIconInfo(
      Icons.payments,
      Color(0xFF4CAF50),
    ),
    NotificationType.paymentFailed => const _NotificationIconInfo(
      Icons.payment,
      Color(0xFFF44336),
    ),
    NotificationType.system => const _NotificationIconInfo(
      Icons.campaign,
      Color(0xFFFF5722),
    ),
  };
}

String _timeAgo(String? dateText) {
  if (dateText == null || dateText.isEmpty) return '';
  final date = DateTime.tryParse(dateText);
  if (date == null) return formatDateTimeText(dateText);
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return formatDateText(dateText);
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo nào',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Thông báo về đơn hàng và khuyến mãi sẽ hiển thị tại đây'),
        ],
      ),
    );
  }
}
