import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/partner.dart';
import '../../../../core/services/partner_service.dart';
import '../../../auth/providers/auth_provider.dart';

class PartnerDashboardScreen extends ConsumerStatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  ConsumerState<PartnerDashboardScreen> createState() =>
      _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState
    extends ConsumerState<PartnerDashboardScreen> {
  PartnerDashboard? _dashboard;
  PartnerOrderStatistics? _statistics;
  StaffOrderSummary? _staffSummary;
  List<Order> _recentOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    PartnerDashboard? dashboard;
    PartnerOrderStatistics? statistics;
    StaffOrderSummary? staffSummary;
    var recentOrders = <Order>[];

    try {
      dashboard = (await PartnerService.getDashboard()).data;
    } catch (_) {
      // The partner dashboard endpoint can be disabled in early backends.
    }
    try {
      statistics = (await PartnerService.getOrderStatistics()).data;
    } catch (_) {
      // Detailed order statistics are optional for the dashboard UI.
    }
    try {
      staffSummary = (await PartnerService.getStaffOrderSummary()).data;
    } catch (_) {
      // Staff summary is optional; individual order fetch below is enough.
    }
    try {
      recentOrders = (await PartnerService.getOrders(
        page: 0,
        size: 5,
      )).data.content.where(_isManageable).toList();
    } catch (_) {
      // Recent orders are shown as an empty list if unavailable.
    }

    if (!mounted) return;
    setState(() {
      _dashboard = dashboard;
      _statistics = statistics;
      _staffSummary = staffSummary;
      _recentOrders = recentOrders;
      _error = dashboard == null && statistics == null && staffSummary == null
          ? 'Không thể tải tổng quan đối tác'
          : null;
      _isLoading = false;
    });
  }

  bool _isManageable(Order order) {
    return {
      OrderStatus.waiting,
      OrderStatus.collected,
      OrderStatus.processing,
      OrderStatus.ready,
      OrderStatus.returned,
    }.contains(order.status);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value?.user;
    final businessName =
        _dashboard?.businessName ?? user?.firstName ?? 'Đối tác';

    final waiting =
        _statistics?.waitingOrders ??
        _staffSummary?.waitingCount ??
        _dashboard?.pendingOrders ??
        0;
    final processing =
        _statistics?.processingOrders ?? _staffSummary?.processingCount ?? 0;
    final ready = _statistics?.readyOrders ?? _staffSummary?.readyCount ?? 0;
    final completed =
        _statistics?.completedOrders ?? _dashboard?.completedOrders ?? 0;
    final todayRevenue =
        _statistics?.todayRevenue ?? _dashboard?.todayRevenue ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tổng quan đối tác'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.go('/partner/orders'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _HeaderCard(
                    businessName: businessName,
                    dateText: formatDateText(DateTime.now().toIso8601String()),
                    revenue: todayRevenue,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _WarningBanner(message: _error!),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Tổng quan đơn hàng',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.18,
                    children: [
                      _StatCard(
                        title: 'Chờ lấy đồ',
                        value: waiting.toString(),
                        icon: Icons.pending_actions,
                        color: const Color(0xFFFF9800),
                      ),
                      _StatCard(
                        title: 'Đang xử lý',
                        value: processing.toString(),
                        icon: Icons.local_laundry_service,
                        color: const Color(0xFF9C27B0),
                      ),
                      _StatCard(
                        title: 'Sẵn sàng trả',
                        value: ready.toString(),
                        icon: Icons.done_all,
                        color: const Color(0xFF4CAF50),
                      ),
                      _StatCard(
                        title: 'Hoàn thành',
                        value: completed.toString(),
                        icon: Icons.check_circle,
                        color: const Color(0xFF2196F3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Thao tác nhanh',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.qr_code_scanner,
                          label: 'Quét mã đơn',
                          color: const Color(0xFF2196F3),
                          onTap: () => context.go('/partner/orders'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.inventory_2,
                          label: 'Lấy đồ',
                          color: const Color(0xFFFF9800),
                          onTap: () => context.go('/partner/orders'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.assignment_return,
                          label: 'Trả đồ',
                          color: const Color(0xFF4CAF50),
                          onTap: () => context.go('/partner/orders'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Đơn hàng gần đây',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/partner/orders'),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  if (_recentOrders.isEmpty)
                    const _EmptyOrders()
                  else
                    ..._recentOrders.map(_RecentOrderCard.new),
                ],
              ),
            ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.businessName,
    required this.dateText,
    required this.revenue,
  });

  final String businessName;
  final String dateText;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, $businessName',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(dateText, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(revenue),
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Doanh thu hôm nay',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(
                value,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: AppColors.primary),
        title: Text('Đơn #${order.orderCode ?? order.id}'),
        subtitle: Text(
          [
            order.senderName ?? order.receiverName ?? 'Khách hàng',
            order.lockerName ?? 'Locker ${order.lockerId}',
          ].join('\n'),
        ),
        isThreeLine: true,
        trailing: Chip(label: Text(orderStatusLabel(order.status))),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.warningColor),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('Không có đơn hàng cần xử lý ngay.')),
    );
  }
}
