import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../core/models/partner.dart';
import '../../../../core/services/partner_service.dart';
import '../../../auth/providers/auth_provider.dart';

class PartnerProfileScreen extends ConsumerStatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  ConsumerState<PartnerProfileScreen> createState() =>
      _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends ConsumerState<PartnerProfileScreen> {
  PartnerProfile? _profile;
  PartnerOrderStatistics? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    PartnerProfile? profile;
    PartnerOrderStatistics? statistics;
    try {
      profile = (await PartnerService.getProfile()).data;
    } catch (_) {
      // Profile may be missing until the account is approved.
    }
    try {
      statistics = (await PartnerService.getOrderStatistics()).data;
    } catch (_) {
      // Statistics are optional on this tab.
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _statistics = statistics;
      _error = profile == null ? 'Không thể tải hồ sơ đối tác' : null;
      _isLoading = false;
    });
  }

  void _showPending(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title chưa có màn hình chi tiết trong Flutter')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value?.user;
    final profile = _profile;
    final businessName = profile?.businessName ?? 'Đối tác Lock.R';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Tài khoản đối tác')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ProfileHeader(
                    businessName: businessName,
                    partnerId: profile?.id,
                    status: profile?.status,
                    phone: profile?.contactPhone ?? user?.phoneNumber,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _WarningBanner(message: _error!),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.shopping_bag,
                            value: (_statistics?.totalOrders ?? 0).toString(),
                            label: 'Tổng đơn hàng',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.store,
                            value: (profile?.storeCount ?? 0).toString(),
                            label: 'Cửa hàng',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.people,
                            value: (profile?.staffCount ?? 0).toString(),
                            label: 'Nhân viên',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Thông tin cửa hàng',
                    children: [
                      _InfoTile(
                        icon: Icons.location_on,
                        title: 'Địa chỉ',
                        value: profile?.businessAddress ?? 'Chưa cập nhật',
                        onTap: () => _showPending('Địa chỉ'),
                      ),
                      _InfoTile(
                        icon: Icons.phone,
                        title: 'Số điện thoại',
                        value: profile?.contactPhone ?? 'Chưa cập nhật',
                        onTap: () => _showPending('Số điện thoại'),
                      ),
                      _InfoTile(
                        icon: Icons.email,
                        title: 'Email liên hệ',
                        value: profile?.contactEmail ?? 'Chưa cập nhật',
                        onTap: () => _showPending('Email liên hệ'),
                      ),
                      _InfoTile(
                        icon: Icons.percent,
                        title: 'Tỷ lệ chia sẻ doanh thu',
                        value: '${profile?.revenueSharePercent ?? 0}%',
                        onTap: () => _showPending('Doanh thu'),
                      ),
                      if (profile?.taxId?.isNotEmpty == true)
                        _InfoTile(
                          icon: Icons.badge,
                          title: 'Mã số thuế',
                          value: profile!.taxId!,
                          onTap: () => _showPending('Mã số thuế'),
                        ),
                    ],
                  ),
                  _Section(
                    title: 'Cài đặt',
                    children: [
                      _InfoTile(
                        icon: Icons.notifications,
                        title: 'Thông báo',
                        value: 'Quản lý thông báo đối tác',
                        onTap: () => _showPending('Thông báo'),
                      ),
                      _InfoTile(
                        icon: Icons.account_balance_wallet,
                        title: 'Ví & thanh toán',
                        value: formatCurrency(_statistics?.totalRevenue ?? 0),
                        onTap: () => _showPending('Ví & thanh toán'),
                      ),
                      _InfoTile(
                        icon: Icons.bar_chart,
                        title: 'Báo cáo & thống kê',
                        value:
                            'Tháng này ${formatCurrency(_statistics?.monthRevenue ?? 0)}',
                        onTap: () => _showPending('Báo cáo & thống kê'),
                      ),
                      _InfoTile(
                        icon: Icons.help,
                        title: 'Trợ giúp & hỗ trợ',
                        value: 'Liên hệ bộ phận hỗ trợ',
                        onTap: () => _showPending('Hỗ trợ'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Đăng xuất'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorColor,
                        side: const BorderSide(color: AppColors.errorColor),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.businessName,
    this.partnerId,
    this.status,
    this.phone,
  });

  final String businessName;
  final int? partnerId;
  final String? status;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.store, size: 48, color: Colors.white),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: _statusColor(status),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            businessName,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            partnerId == null
                ? 'Partner ID: chưa cập nhật'
                : 'Partner ID: PTN-$partnerId',
            style: const TextStyle(color: Colors.white70),
          ),
          if (phone?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(phone!, style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 12),
          Chip(
            avatar: Icon(Icons.verified, color: _statusColor(status), size: 18),
            label: Text(_statusLabel(status)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.18),
            foregroundColor: AppColors.primary,
            child: Icon(icon),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withValues(alpha: 0.18),
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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

Color _statusColor(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'APPROVED' || 'ACTIVE' => AppColors.successColor,
    'REJECTED' => AppColors.errorColor,
    _ => AppColors.warningColor,
  };
}

String _statusLabel(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'APPROVED' || 'ACTIVE' => 'Đã xác thực',
    'REJECTED' => 'Bị từ chối',
    'PENDING' => 'Chờ duyệt',
    _ => 'Chưa xác thực',
  };
}
