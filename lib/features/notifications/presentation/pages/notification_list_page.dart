import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/notifications/domain/entities/notification_model.dart';
import 'package:smart_laundry_locker/features/notifications/presentation/providers/notification_provider.dart';
import 'package:smart_laundry_locker/shared/widgets/unauthenticated_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    TokenService.authState.addListener(_onAuthStateChanged);
    _scrollController.addListener(_onScroll);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    if (TokenService.authState.value && mounted) {
      context.read<NotificationProvider>().loadNotifications(refresh: true);
    }
  }

  @override
  void dispose() {
    TokenService.authState.removeListener(_onAuthStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    context.read<NotificationProvider>().markAsRead(notification.id);

    final payload = notification.dataPayload;
    if (payload == null) return;

    // TODO: Routing logic based on actionType
    // Example:
    // if (payload.actionType == 'OPEN_ORDER_DETAIL' && payload.referenceId != null) {
    //   context.push('/orders/detail', extra: payload.referenceId!);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TokenService.authState,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Thông báo'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: const UnauthenticatedPlaceholder(
              message: 'Bạn cần đăng nhập để xem thông báo',
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Thông báo'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  return IconButton(
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    onPressed: () {
                      provider.loadNotifications(refresh: true);
                    },
                  );
                },
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.unreadCount == 0 ||
                      provider.notifications.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return TextButton.icon(
                    onPressed: () {
                      provider.markAllAsRead();
                    },
                    icon: const Icon(LucideIcons.checkCheck, size: 18),
                    label: const Text('Đọc tất cả'),
                    style: TextButton.styleFrom(
                      foregroundColor: AISLShadcnTheme.navyPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null && provider.notifications.isEmpty) {
                return _buildErrorState(provider);
              }

              if (provider.notifications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadNotifications(refresh: true),
                color: AISLShadcnTheme.navyPrimary,
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: provider.notifications.length + 1,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    if (index == provider.notifications.length) {
                      if (provider.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!provider.hasMore &&
                          provider.notifications.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Đã xem hết thông báo',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        );
                      }
                      return const SizedBox(height: 32);
                    }

                    final notification = provider.notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellRing, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông báo nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Khi có thông báo mới, chúng sẽ xuất hiện ở đây',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NotificationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.serverCrash, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Lỗi kết nối',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              provider.error!,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.loadNotifications(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AISLShadcnTheme.navyPrimary,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final bool isUnread = !notification.isRead;
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Placeholder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnread ? Colors.blue.shade100 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.dataPayload?.actionType),
                color: isUnread ? Colors.blue.shade700 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 15,
                            color: isUnread
                                ? Colors.black87
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnread ? Colors.black87 : Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String? actionType) {
    if (actionType == null) return LucideIcons.bell;
    switch (actionType) {
      case 'OPEN_ORDER_DETAIL':
        return LucideIcons.package;
      case 'OPEN_PROMOTION_TAB':
        return LucideIcons.tag;
      default:
        return LucideIcons.bell;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${time.day}/${time.month}/${time.year}';
  }
}
