import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/core.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/payment.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/payment_service.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _payingOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.errorColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Không thể tải đơn hàng: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.errorColor),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(ordersNotifierProvider.notifier).refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          final activeOrders = orders
              .where(
                (order) =>
                    order.status != OrderStatus.completed &&
                    order.status != OrderStatus.canceled,
              )
              .toList();
          final completedOrders = orders
              .where((order) => order.status == OrderStatus.completed)
              .toList();
          final canceledOrders = orders
              .where((order) => order.status == OrderStatus.canceled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orders, 'Bạn chưa có đơn hàng nào'),
              _buildOrderList(activeOrders, 'Chưa có đơn hàng đang xử lý'),
              _buildOrderList(completedOrders, 'Chưa có đơn hàng hoàn thành'),
              _buildOrderList(canceledOrders, 'Chưa có đơn hàng đã hủy'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/user/lockers'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: () => ref.read(ordersNotifierProvider.notifier).refresh(),
      child: orders.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 140),
                _EmptyOrders(message: emptyMessage),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: orders[index],
                isPaying: _payingOrderId == orders[index].id,
                onDetail: () => _showOrderDetail(orders[index]),
                onTrack: () => _showTracking(orders[index]),
                onPay: () => _payMomo(orders[index]),
                onCancel: () => _cancelOrder(orders[index]),
              ),
            ),
    );
  }

  Future<void> _showOrderDetail(Order order) async {
    final detailFuture = OrderService.getOrderById(order.id);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FutureBuilder(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const SizedBox(
              height: 260,
              child: Center(child: Text('Không thể tải chi tiết đơn hàng')),
            );
          }
          return _OrderDetailSheet(order: snapshot.data!.data);
        },
      ),
    );
  }

  Future<void> _showTracking(Order order) async {
    final timelineFuture = _loadTimeline(order.id);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FutureBuilder(
        future: timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final timeline = snapshot.data;
          return _TrackingSheet(order: order, timeline: timeline);
        },
      ),
    );
  }

  Future<OrderTimelineResponse?> _loadTimeline(int orderId) async {
    try {
      return (await OrderService.getOrderTimeline(orderId)).data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _payMomo(Order order) async {
    setState(() => _payingOrderId = order.id);
    try {
      final response = await PaymentService.createPayment(
        order.id,
        PaymentMethod.momo,
      );
      final url = response.data.paymentUrl;
      if (url == null || url.isEmpty) {
        _showMessage('Đã tạo thanh toán nhưng chưa có URL');
        return;
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      _showMessage('Không thể tạo thanh toán MoMo');
    } finally {
      if (mounted) setState(() => _payingOrderId = null);
    }
  }

  Future<void> _cancelOrder(Order order) async {
    final controller = TextEditingController(text: 'Khách hàng hủy đơn');
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Lý do hủy',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.trim().isEmpty) return;

    try {
      await ref
          .read(ordersNotifierProvider.notifier)
          .cancelOrder(order.id, reason.trim());
      _showMessage('Đã hủy đơn hàng #${order.id}');
    } catch (_) {
      _showMessage('Không thể hủy đơn hàng lúc này');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isPaying,
    required this.onDetail,
    required this.onTrack,
    required this.onPay,
    required this.onCancel,
  });

  final Order order;
  final bool isPaying;
  final VoidCallback onDetail;
  final VoidCallback onTrack;
  final VoidCallback onPay;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final itemCount =
        order.orderDetails?.length ??
        order.items?.length ??
        order.services?.length ??
        0;
    final pin = order.pin ?? order.pinCode;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onDetail,
        child: Column(
          children: [
            Container(height: 4, color: color),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.orderCode ?? 'Đơn #${order.id}',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(order),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.inventory_2,
                          label: 'Tủ đồ',
                          value:
                              order.locker?.name ??
                              order.lockerName ??
                              'Locker ${order.lockerId}',
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.list,
                          label: 'Dịch vụ',
                          value: '$itemCount món',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.payments,
                          label: 'Tổng tiền',
                          value: formatCurrency(
                            order.totalPrice ?? order.totalAmount,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          icon: pin == null ? Icons.person : Icons.lock,
                          label: pin == null ? 'Người gửi' : 'Mã PIN',
                          value: pin ?? order.senderName ?? 'N/A',
                          highlight: pin != null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatDateTimeText(order.createdAt),
                        style: AppTypography.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: onDetail,
                        child: const Text('Chi tiết'),
                      ),
                      if (order.status != OrderStatus.canceled &&
                          order.type != OrderType.storage)
                        OutlinedButton(
                          onPressed: onTrack,
                          child: const Text('Theo dõi'),
                        ),
                      if (order.status != OrderStatus.canceled &&
                          order.type != OrderType.storage &&
                          _isOrderUnpaid(order))
                        FilledButton(
                          onPressed: isPaying ? null : onPay,
                          child: isPaying
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Thanh toán'),
                        ),
                      if ((order.status == OrderStatus.waiting &&
                              order.type != OrderType.storage) ||
                          order.status == OrderStatus.collected)
                        OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorColor,
                          ),
                          child: const Text('Hủy đơn'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: highlight ? AppColors.warningColor : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(label, style: AppTypography.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlight ? AppColors.warningColor : AppColors.lightText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final items = order.orderDetails ?? order.items ?? <OrderItem>[];
    final pin = order.pin ?? order.pinCode;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderCode ?? 'Đơn #${order.id}',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Chip(label: Text(_statusLabel(order))),
            ],
          ),
          const SizedBox(height: 12),
          if (pin != null && pin.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text('Mã PIN'),
                  Text(
                    pin,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.warningColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _DetailBox(
            title: 'Vị trí',
            lines: [
              order.lockerName ?? 'Locker ${order.lockerId}',
              'Box ${order.boxNumber ?? order.boxId}',
            ],
          ),
          _DetailBox(
            title: 'Thời gian',
            lines: [
              if (order.createdAt != null)
                'Tạo đơn: ${formatDateTimeText(order.createdAt)}',
              if (order.intendedReceiveAt != null)
                'Dự kiến nhận: ${formatDateTimeText(order.intendedReceiveAt)}',
              if (order.completedAt != null)
                'Hoàn thành: ${formatDateTimeText(order.completedAt)}',
            ],
          ),
          if (items.isNotEmpty) ...[
            Text(
              'Dịch vụ',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.serviceName),
                subtitle: Text('x${item.quantity}'),
                trailing: Text(formatCurrency(item.subtotal)),
              ),
            ),
          ],
          const Divider(height: 28),
          _PriceRow('Tạm tính', order.originalPrice ?? order.totalAmount),
          if ((order.discountAmount ?? order.discount ?? 0) > 0)
            _PriceRow(
              'Giảm giá',
              -(order.discountAmount ?? order.discount ?? 0),
            ),
          if ((order.extraFee ?? 0) > 0) _PriceRow('Phụ phí', order.extraFee!),
          _PriceRow(
            'Tổng cộng',
            order.totalPrice ?? order.totalAmount,
            emphasis: true,
          ),
          if (order.customerNote?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _DetailBox(title: 'Ghi chú', lines: [order.customerNote!]),
          ],
        ],
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.order, required this.timeline});

  final Order order;
  final OrderTimelineResponse? timeline;

  @override
  Widget build(BuildContext context) {
    final events = timeline?.events ?? <OrderTimelineEvent>[];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.86,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(
            'Theo dõi đơn #${order.id}',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text('Trạng thái hiện tại: ${_statusLabel(order)}'),
          const SizedBox(height: 18),
          if (events.isEmpty)
            const Center(child: Text('Chưa có dữ liệu lộ trình'))
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(event.description),
                          Text(
                            formatDateTimeText(event.timestamp),
                            style: AppTypography.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          ...lines.map((line) => Text(line)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.value, {this.emphasis = false});

  final String label;
  final double value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: emphasis ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            formatCurrency(value),
            style: TextStyle(
              color: emphasis ? AppColors.primary : null,
              fontWeight: emphasis ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(OrderStatus status) {
  return switch (status) {
    OrderStatus.initialized => const Color(0xFF2196F3),
    OrderStatus.waiting => const Color(0xFFFF9800),
    OrderStatus.collected => const Color(0xFF9C27B0),
    OrderStatus.processing => const Color(0xFFFF5722),
    OrderStatus.ready => const Color(0xFF00BCD4),
    OrderStatus.returned => const Color(0xFF4CAF50),
    OrderStatus.completed => const Color(0xFF4CAF50),
    OrderStatus.canceled => const Color(0xFF9E9E9E),
  };
}

String _statusLabel(Order order) {
  if (order.status == OrderStatus.waiting && order.type == OrderType.storage) {
    return 'Đang lưu trữ';
  }
  return orderStatusLabel(order.status);
}

bool _isOrderPaid(Order order) {
  if (order.isPaid == true) return true;
  final paymentStatus = (order.payment?['status'] ?? '')
      .toString()
      .toUpperCase();
  return {'SUCCESS', 'COMPLETED', 'PAID'}.contains(paymentStatus);
}

bool _isOrderUnpaid(Order order) {
  if (order.paymentRequired == false) return false;
  return !_isOrderPaid(order);
}
