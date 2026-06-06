import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_laundry_locker/core/utils/currency_formatter.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_injection.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_provider.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/wallet/presentation/providers/wallet_provider.dart';

import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_injection.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../providers/courier_dispatch_provider.dart';

class CourierDashboardPage extends StatefulWidget {
  const CourierDashboardPage({super.key});

  @override
  State<CourierDashboardPage> createState() => _CourierDashboardPageState();
}

class _CourierDashboardPageState extends State<CourierDashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();
  late final GlobalKey _jobsSectionKey = GlobalKey();
  late final ProfileProvider _profileProvider;
  late final CourierDeliveryProvider _courierDeliveryProvider;
  bool _showTodayJobs = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _profileProvider = ProfileInjection.provideProfileProvider(ApiClient());
    _courierDeliveryProvider =
        CourierDeliveryInjection.provideCourierDeliveryProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _refreshDashboard();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    _profileProvider.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _profileProvider.loadProfile(),
      context.read<WalletProvider>().getWalletBalance(),
      context.read<CourierDispatchProvider>().fetchCourierStats(),
      context.read<CourierDispatchProvider>().fetchActiveOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer<CourierDispatchProvider>(
      builder: (context, provider, child) {
        final isOnline = provider.isOnline;
        final walletBalance = context.watch<WalletProvider>().balance;
        final walletVnd = CurrencyFormatter.formatVnd(walletBalance);
        final ordersToday = '${provider.completedToday}';
        final deliveringToday = '${provider.deliveringToday}';
        final courierName = _profileProvider.profile?.fullName ?? 'Courier';
        final jobs = _showTodayJobs
            ? provider.activeOrders
            : const <CourierOrder>[];

        return Scaffold(
          backgroundColor: cs.background,
          appBar: AppBar(
            backgroundColor: cs.background,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Courier Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  _HeaderStatusCard(
                    theme: theme,
                    courierName: courierName,
                    isOnline: isOnline,
                    isLoading: provider.isLoading,
                    errorText: provider.error,
                    pulse: _pulseController,
                    onToggle: provider.isLoading
                        ? null
                        : (v) => provider.toggleOnlineStatus(v),
                  ),
                  const SizedBox(height: 14),
                  _QuickStatsBar(
                    theme: theme,
                    walletVnd: walletVnd,
                    ordersToday: ordersToday,
                    deliveringToday: deliveringToday,
                    isOrdersSelected: _showTodayJobs,
                    onTapOrdersToday: () async {
                      setState(() => _showTodayJobs = !_showTodayJobs);
                      if (!_showTodayJobs) return;
                      await Future<void>.delayed(Duration.zero);
                      final ctx = _jobsSectionKey.currentContext;
                      if (ctx == null) return;
                      await Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        alignment: 0.05,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Đơn hàng hiện tại',
                    key: _jobsSectionKey,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (jobs.isEmpty)
                    _JobsEmptyState(theme: theme)
                  else
                    ...jobs.map((j) => _JobCard(theme: theme, job: j)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showVerifyCodeDialog(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text(
                        'NHẬP MÃ GỬI HÀNG',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AISLShadcnTheme.navyPrimary.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVerifyCodeDialog(BuildContext context) {
    final codeCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Nhập mã gửi hàng'),
          content: TextField(
            controller: codeCtl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập mã OTP từ khách hàng',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeCtl.text.trim();
                if (code.isEmpty) return;

                Navigator.of(ctx).pop();

                SmartDialog.show<dynamic>(
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận thực hiện'),
                    content: const Text(
                      'Hệ thống sẽ xác thực mã và mở tủ (nếu có), bạn có chắc chắn đang ở đúng vị trí không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => SmartDialog.dismiss<dynamic>(),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          SmartDialog.dismiss<dynamic>();
                          SmartDialog.showLoading<dynamic>(
                            msg: 'Đang xác thực...',
                          );

                          final success = await _courierDeliveryProvider
                              .verifyCourierCode(code);

                          SmartDialog.dismiss<dynamic>();

                          if (success) {
                            if (context.mounted) {
                              SmartDialog.showToast('Xác thực thành công!');
                              context.push(
                                '/active-delivery',
                                extra: _courierDeliveryProvider.activeOrder,
                              );
                            }
                          } else {
                            SmartDialog.showToast(
                              _courierDeliveryProvider.error ??
                                  'Xác thực thất bại',
                            );
                          }
                        },
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}

class _HeaderStatusCard extends StatelessWidget {
  final ThemeData theme;
  final String courierName;
  final bool isOnline;
  final bool isLoading;
  final String? errorText;
  final Animation<double> pulse;
  final ValueChanged<bool>? onToggle;

  const _HeaderStatusCard({
    required this.theme,
    required this.courierName,
    required this.isOnline,
    required this.isLoading,
    required this.errorText,
    required this.pulse,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final bg = isOnline ? Colors.white : cs.surfaceVariant;
    final borderColor = isOnline
        ? AISLShadcnTheme.navyPrimary.withOpacity(0.45)
        : Colors.transparent;

    final statusText = isOnline ? 'Đang hoạt động' : 'Đang nghỉ';
    final statusColor = isOnline ? const Color(0xFF16A34A) : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AISLShadcnTheme.navyPrimary.withOpacity(0.95),
                      const Color(0xFFF57C00),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AISLShadcnTheme.navyPrimary.withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    courierName.isNotEmpty
                        ? courierName.trim().substring(0, 1).toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courierName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: cs.onBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: isOnline,
                activeColor: const Color(0xFF16A34A),
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOnline)
                      AnimatedBuilder(
                        animation: pulse,
                        builder: (context, _) {
                          final v = pulse.value;
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor.withOpacity(0.45 + 0.55 * v),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(
                                    0.10 + 0.25 * v,
                                  ),
                                  blurRadius: 10 + 10 * v,
                                  spreadRadius: 1 + 1 * v,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withOpacity(0.65),
                        ),
                      ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isLoading)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOnline ? const Color(0xFF16A34A) : cs.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.20),
                ),
              ),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickStatsBar extends StatelessWidget {
  final ThemeData theme;
  final String walletVnd;
  final String ordersToday;
  final String deliveringToday;
  final bool isOrdersSelected;
  final VoidCallback onTapOrdersToday;

  const _QuickStatsBar({
    required this.theme,
    required this.walletVnd,
    required this.ordersToday,
    required this.deliveringToday,
    required this.isOrdersSelected,
    required this.onTapOrdersToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              theme: theme,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Ví của tôi',
              value: walletVnd,
            ),
          ),
          _DividerV(theme: theme),
          Expanded(
            child: _StatItem(
              theme: theme,
              icon: Icons.inventory_2_outlined,
              label: 'Đơn hôm nay',
              value: ordersToday,
              isTappable: true,
              isSelected: isOrdersSelected,
              onTap: onTapOrdersToday,
            ),
          ),
          _DividerV(theme: theme),
          Expanded(
            child: _StatItem(
              theme: theme,
              icon: Icons.local_shipping_outlined,
              label: 'Đang giao',
              value: deliveringToday,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerV extends StatelessWidget {
  final ThemeData theme;
  const _DividerV({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: cs.outlineVariant,
    );
  }
}

class _StatItem extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final bool isTappable;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatItem({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    this.isTappable = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected
                ? AISLShadcnTheme.navyPrimary.withOpacity(0.18)
                : AISLShadcnTheme.navyPrimary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AISLShadcnTheme.navyPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: cs.onBackground,
                    ),
                  ),
                  if (isTappable) ...[
                    const SizedBox(width: 6),
                    Icon(
                      isSelected
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (!isTappable) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _JobsEmptyState extends StatelessWidget {
  final ThemeData theme;
  const _JobsEmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AISLShadcnTheme.navyPrimary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delivery_dining_outlined,
              size: 44,
              color: AISLShadcnTheme.navyPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hiện không có đơn hàng nào quanh bạn.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: cs.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy giữ kết nối! Khi có đơn hàng mới, hệ thống sẽ gửi thông báo đến bạn!!!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final ThemeData theme;
  final CourierOrder job;
  const _JobCard({required this.theme, required this.job});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final code = job.orderCode.isEmpty ? '#OD' : job.orderCode;
    final status = job.status;
    final pickup = job.originName;
    final dropoff = job.destinationName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.onBackground,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AISLShadcnTheme.navyPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AISLShadcnTheme.navyPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _JobRouteRow(
            theme: theme,
            iconColor: const Color(0xFF16A34A),
            label: 'Điểm lấy',
            value: pickup,
          ),
          const SizedBox(height: 8),
          _JobRouteRow(
            theme: theme,
            iconColor: const Color(0xFFEF4444),
            label: 'Điểm giao',
            value: dropoff,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/active-delivery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AISLShadcnTheme.navyPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobRouteRow extends StatelessWidget {
  final ThemeData theme;
  final Color iconColor;
  final String label;
  final String value;

  const _JobRouteRow({
    required this.theme,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.place_outlined, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.onBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
