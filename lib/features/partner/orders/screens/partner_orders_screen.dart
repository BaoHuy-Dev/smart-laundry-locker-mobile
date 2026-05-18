import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/partner_service.dart';

enum _PartnerOrderAction { collect, process, ready, returnToLocker }

class PartnerOrdersScreen extends ConsumerStatefulWidget {
  const PartnerOrdersScreen({super.key});

  @override
  ConsumerState<PartnerOrdersScreen> createState() =>
      _PartnerOrdersScreenState();
}

class _PartnerOrdersScreenState extends ConsumerState<PartnerOrdersScreen> {
  final _searchController = TextEditingController();

  OrderStatus? _selectedStatus;
  List<Order> _orders = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  int? _actionOrderId;
  String? _error;

  static const _manageableStatuses = {
    OrderStatus.waiting,
    OrderStatus.collected,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.returned,
  };

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    setState(() {
      _error = null;
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await PartnerService.getOrders(page: 0, size: 50);
      final orders = response.data.content
          .where((order) => _manageableStatuses.contains(order.status))
          .toList();
      if (mounted) setState(() => _orders = orders);
    } catch (_) {
      if (mounted) {
        setState(() {
          _orders = [];
          _error = 'Không thể tải danh sách đơn hàng đối tác';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  List<Order> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();
    return _orders.where((order) {
      if (_selectedStatus != null && order.status != _selectedStatus) {
        return false;
      }
      if (query.isEmpty) return true;
      return order.id.toString().contains(query) ||
          (order.orderCode ?? '').toLowerCase().contains(query) ||
          (order.pin ?? '').toLowerCase().contains(query) ||
          (order.pinCode ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleAction(Order order, _PartnerOrderAction action) async {
    if (action == _PartnerOrderAction.returnToLocker) {
      await _returnOrder(order);
      return;
    }

    final actionLabel = _nextAction(order.status)?.label ?? 'cập nhật';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn $actionLabel đơn hàng #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _runOrderAction(order, action);
  }

  Future<void> _returnOrder(Order order) async {
    final controller = TextEditingController();
    final boxId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trả đồ cho khách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn #${order.id} - PIN: ${order.pin ?? order.pinCode ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mã box trả đồ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text.trim())),
            child: const Text('Xác nhận trả đồ'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (boxId == null) return;
    await _runOrderAction(order, _PartnerOrderAction.returnToLocker, boxId);
  }

  Future<void> _runOrderAction(
    Order order,
    _PartnerOrderAction action, [
    int? returnBoxId,
  ]) async {
    setState(() => _actionOrderId = order.id);
    try {
      final response = switch (action) {
        _PartnerOrderAction.collect => await OrderService.collectOrder(
          order.id,
        ),
        _PartnerOrderAction.process => await OrderService.processOrder(
          order.id,
        ),
        _PartnerOrderAction.ready => await OrderService.markReady(order.id),
        _PartnerOrderAction.returnToLocker => await OrderService.returnOrder(
          order.id,
          returnBoxId!,
        ),
      };

      final updated = response.data;
      setState(() {
        _orders = _orders
            .map((current) => current.id == updated.id ? updated : current)
            .toList();
      });
      _showMessage('Đã cập nhật đơn hàng #${order.id}');
    } catch (_) {
      _showMessage('Thao tác thất bại. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _actionOrderId = null);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _showMessage('Chưa tích hợp quét mã trên Flutter'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo mã đơn hoặc PIN...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                _FilterBar(
                  selectedStatus: _selectedStatus,
                  onChanged: (status) =>
                      setState(() => _selectedStatus = status),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _ErrorBanner(message: _error!),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _loadOrders(refresh: true),
                    child: orders.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 140),
                              _EmptyOrders(),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                            itemCount:
                                orders.length +
                                (_isRefreshing && orders.isNotEmpty ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= orders.length) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: LinearProgressIndicator(),
                                );
                              }
                              final order = orders[index];
                              return _PartnerOrderCard(
                                order: order,
                                isActionLoading: _actionOrderId == order.id,
                                onAction: (action) =>
                                    _handleAction(order, action),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusFilter {
  const _StatusFilter(this.label, this.status);

  final String label;
  final OrderStatus? status;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selectedStatus, required this.onChanged});

  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onChanged;

  static const filters = [
    _StatusFilter('Tất cả', null),
    _StatusFilter('Chờ lấy', OrderStatus.waiting),
    _StatusFilter('Đã lấy', OrderStatus.collected),
    _StatusFilter('Đang xử lý', OrderStatus.processing),
    _StatusFilter('Sẵn sàng', OrderStatus.ready),
    _StatusFilter('Đã trả', OrderStatus.returned),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: selectedStatus == filter.status,
                    onSelected: (_) => onChanged(filter.status),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _PartnerOrderCard extends StatelessWidget {
  const _PartnerOrderCard({
    required this.order,
    required this.isActionLoading,
    required this.onAction,
  });

  final Order order;
  final bool isActionLoading;
  final ValueChanged<_PartnerOrderAction> onAction;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(order.status);
    final nextAction = _nextAction(order.status);
    final items = order.items ?? order.orderDetails ?? <OrderItem>[];
    final pin = order.pin ?? order.pinCode;
    final boxNumber =
        order.boxNumber ??
        order.receiveBoxNumber ??
        order.sendBoxNumber ??
        order.boxId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn #${order.orderCode ?? order.id}',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (pin?.isNotEmpty == true)
                        Text(
                          'PIN: $pin',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo.backgroundColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: TextStyle(
                      color: statusInfo.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _MetaItem(
                  icon: Icons.inventory_2,
                  text:
                      '${order.lockerName ?? 'Locker ${order.lockerId}'} - Box $boxNumber',
                ),
                if (order.createdAt != null)
                  _MetaItem(
                    icon: Icons.schedule,
                    text: formatDateTimeText(order.createdAt),
                  ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Chi tiết dịch vụ',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map(_OrderItemRow.new),
            ],
            const Divider(height: 24),
            Row(
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  formatCurrency(order.totalPrice ?? order.totalAmount),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            _Timeline(order: order),
            if (nextAction != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: isActionLoading
                    ? null
                    : () => onAction(nextAction.action),
                icon: isActionLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(nextAction.icon),
                label: Text(nextAction.label),
                style: FilledButton.styleFrom(
                  backgroundColor: statusInfo.color,
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Text(text, style: AppTypography.textTheme.bodySmall),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow(this.item);

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(item.serviceName)),
          Text('x${item.quantity}'),
          const SizedBox(width: 12),
          Text(formatCurrency(item.subtotal)),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final events = <String>[
      if (order.confirmedAt != null)
        'Xác nhận: ${formatDateTimeText(order.confirmedAt)}',
      if (order.collectedAt != null)
        'Lấy đồ: ${formatDateTimeText(order.collectedAt)}',
      if (order.processedAt != null)
        'Xử lý: ${formatDateTimeText(order.processedAt)}',
      if (order.readyAt != null)
        'Sẵn sàng: ${formatDateTimeText(order.readyAt)}',
      if (order.returnedAt != null)
        'Đã trả: ${formatDateTimeText(order.returnedAt)}',
    ];
    if (events.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: events
            .map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event,
                        style: AppTypography.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo(this.label, this.color, this.backgroundColor);

  final String label;
  final Color color;
  final Color backgroundColor;
}

class _NextAction {
  const _NextAction(this.label, this.action, this.icon);

  final String label;
  final _PartnerOrderAction action;
  final IconData icon;
}

_StatusInfo _statusInfo(OrderStatus status) {
  return switch (status) {
    OrderStatus.waiting => const _StatusInfo(
      'Chờ lấy',
      Color(0xFFFF9800),
      Color(0xFFFFF3E0),
    ),
    OrderStatus.collected => const _StatusInfo(
      'Đã lấy',
      Color(0xFF2196F3),
      Color(0xFFE3F2FD),
    ),
    OrderStatus.processing => const _StatusInfo(
      'Đang xử lý',
      Color(0xFF9C27B0),
      Color(0xFFF3E5F5),
    ),
    OrderStatus.ready => const _StatusInfo(
      'Sẵn sàng',
      Color(0xFF4CAF50),
      Color(0xFFE8F5E9),
    ),
    OrderStatus.returned => const _StatusInfo(
      'Đã trả',
      Color(0xFF00BCD4),
      Color(0xFFE0F7FA),
    ),
    OrderStatus.completed => const _StatusInfo(
      'Hoàn thành',
      Color(0xFF8BC34A),
      Color(0xFFF1F8E9),
    ),
    OrderStatus.canceled => const _StatusInfo(
      'Đã hủy',
      Color(0xFFF44336),
      Color(0xFFFFEBEE),
    ),
    OrderStatus.initialized => const _StatusInfo(
      'Khởi tạo',
      Color(0xFF607D8B),
      Color(0xFFECEFF1),
    ),
  };
}

_NextAction? _nextAction(OrderStatus status) {
  return switch (status) {
    OrderStatus.waiting => const _NextAction(
      'Lấy đồ',
      _PartnerOrderAction.collect,
      Icons.inventory_2,
    ),
    OrderStatus.collected => const _NextAction(
      'Bắt đầu xử lý',
      _PartnerOrderAction.process,
      Icons.local_laundry_service,
    ),
    OrderStatus.processing => const _NextAction(
      'Đánh dấu sẵn sàng',
      _PartnerOrderAction.ready,
      Icons.done_all,
    ),
    OrderStatus.ready => const _NextAction(
      'Trả đồ',
      _PartnerOrderAction.returnToLocker,
      Icons.assignment_return,
    ),
    _ => null,
  };
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.errorColor)),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('Không có đơn hàng nào'),
          const SizedBox(height: 4),
          const Text('Đơn hàng cần xử lý sẽ hiển thị tại đây'),
        ],
      ),
    );
  }
}
