import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/partner.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/locker_service.dart';
import '../../../../core/services/loyalty_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/partner_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  User? _profile;
  LoyaltySummary? _loyalty;
  PartnerProfile? _partnerProfile;
  Map<String, dynamic>? _userStats;
  int _totalOrders = 0;
  int _activeOrders = 0;
  int _completedOrders = 0;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
    });

    User? profile;
    LoyaltySummary? loyalty;
    PartnerProfile? partnerProfile;
    Map<String, dynamic>? userStats;
    var totalOrders = 0;
    var activeOrders = 0;
    var completedOrders = 0;

    try {
      profile = (await UserService.getProfile()).data;
    } catch (_) {
      profile = ref.read(authNotifierProvider).value?.user;
    }
    try {
      final orders = (await OrderService.getOrders(size: 50)).data.content;
      totalOrders = orders.length;
      completedOrders = orders
          .where((order) => order.status == OrderStatus.completed)
          .length;
      activeOrders = orders
          .where(
            (order) =>
                order.status != OrderStatus.completed &&
                order.status != OrderStatus.canceled,
          )
          .length;
    } catch (_) {
      // Order stats are optional.
    }
    try {
      userStats = (await UserService.getUserStatistics()).data;
    } catch (_) {
      // Older backends may not expose user statistics.
    }
    try {
      loyalty = (await LoyaltyService.getLoyaltySummary()).data;
    } catch (_) {
      // Loyalty may not exist for a new account.
    }
    try {
      partnerProfile = (await PartnerService.getProfile()).data;
    } catch (_) {
      // A normal user may not be registered as partner.
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loyalty = loyalty;
      _partnerProfile = partnerProfile;
      _userStats = userStats;
      _totalOrders = totalOrders;
      _activeOrders = activeOrders;
      _completedOrders = completedOrders;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _editProfile(User user) async {
    final firstNameController = TextEditingController(
      text: user.firstName ?? '',
    );
    final lastNameController = TextEditingController(text: user.lastName ?? '');
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final emailController = TextEditingController(text: user.email ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật hồ sơ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(firstNameController, 'Tên'),
              _dialogField(lastNameController, 'Họ'),
              _dialogField(phoneController, 'Số điện thoại'),
              _dialogField(emailController, 'Email'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop({
              'firstName': firstNameController.text.trim(),
              'lastName': lastNameController.text.trim(),
              'phoneNumber': phoneController.text.trim(),
              'email': emailController.text.trim(),
            }),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    if (result == null) return;

    try {
      final updated = (await UserService.updateProfile(result)).data;
      if (!mounted) return;
      setState(() => _profile = updated);
      await ref.read(authNotifierProvider.notifier).refreshUser();
      _showMessage('Cập nhật hồ sơ thành công');
    } catch (_) {
      _showMessage('Không thể cập nhật hồ sơ');
    }
  }

  Future<void> _updateAvatar() async {
    final controller = TextEditingController(
      text: _avatarUrl(_currentUser) ?? '',
    );
    final imageUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật ảnh đại diện'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Đường dẫn hình ảnh',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      final updated = (await UserService.updateAvatar(imageUrl)).data;
      if (!mounted) return;
      setState(() => _profile = updated);
      await ref.read(authNotifierProvider.notifier).refreshUser();
      _showMessage('Cập nhật ảnh đại diện thành công');
    } catch (_) {
      _showMessage('Không thể cập nhật ảnh đại diện');
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                currentController,
                'Mật khẩu hiện tại',
                obscure: true,
              ),
              _dialogField(newController, 'Mật khẩu mới', obscure: true),
              _dialogField(
                confirmController,
                'Xác nhận mật khẩu',
                obscure: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop({
              'currentPassword': currentController.text,
              'newPassword': newController.text,
              'confirmPassword': confirmController.text,
            }),
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    if (data == null) return;
    if ((data['newPassword'] ?? '').length < 6 ||
        data['newPassword'] != data['confirmPassword']) {
      _showMessage('Mật khẩu mới không hợp lệ hoặc không khớp');
      return;
    }

    try {
      await UserService.changePassword(data);
      _showMessage('Đổi mật khẩu thành công');
    } catch (_) {
      _showMessage('Không thể đổi mật khẩu');
    }
  }

  Future<void> _registerPartner() async {
    final businessNameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController(
      text: _currentUser?.phoneNumber ?? '',
    );
    final registrationController = TextEditingController();
    final taxController = TextEditingController();

    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng ký đối tác'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(businessNameController, 'Tên doanh nghiệp *'),
              _dialogField(addressController, 'Địa chỉ kinh doanh *'),
              _dialogField(phoneController, 'Số điện thoại liên hệ *'),
              _dialogField(registrationController, 'Số đăng ký kinh doanh'),
              _dialogField(taxController, 'Mã số thuế'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop({
              'businessName': businessNameController.text.trim(),
              'businessAddress': addressController.text.trim(),
              'contactPhone': phoneController.text.trim(),
              'businessRegistrationNumber': registrationController.text.trim(),
              'taxId': taxController.text.trim(),
            }),
            child: const Text('Gửi đăng ký'),
          ),
        ],
      ),
    );

    businessNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    registrationController.dispose();
    taxController.dispose();
    if (data == null) return;
    if ((data['businessName'] as String).isEmpty ||
        (data['businessAddress'] as String).isEmpty ||
        (data['contactPhone'] as String).isEmpty) {
      _showMessage('Vui lòng điền các thông tin bắt buộc');
      return;
    }

    try {
      final profile = (await PartnerService.registerPartner(data)).data;
      if (!mounted) return;
      setState(() => _partnerProfile = profile);
      _showMessage('Đăng ký đối tác thành công, vui lòng chờ phê duyệt');
    } catch (_) {
      _showMessage('Không thể đăng ký đối tác lúc này');
    }
  }

  Future<void> _showComplaints() async {
    await _showMapListSheet(
      title: 'Khiếu nại của tôi',
      future: OrderService.getMyComplaints().then((value) => value.data),
      emptyMessage: 'Bạn chưa có khiếu nại nào',
    );
  }

  Future<void> _showLockerReports() async {
    await _showMapListSheet(
      title: 'Báo cáo tủ của tôi',
      future: LockerService.getMyReports().then((value) => value.data),
      emptyMessage: 'Bạn chưa có báo cáo tủ nào',
    );
  }

  Future<void> _showMapListSheet({
    required String title,
    required Future<List<Map<String, dynamic>>> future,
    required String emptyMessage,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final items = snapshot.data ?? [];
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            maxChildSize: 0.9,
            minChildSize: 0.35,
            builder: (context, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(emptyMessage),
                    ),
                  )
                else
                  ...items.map(
                    (item) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.report_problem),
                        title: Text(
                          (item['type'] ?? item['lockerName'] ?? 'Báo cáo')
                              .toString(),
                        ),
                        subtitle: Text(
                          (item['description'] ??
                                  item['issue'] ??
                                  item['status'] ??
                                  '')
                              .toString(),
                        ),
                        trailing: item['status'] == null
                            ? null
                            : Chip(label: Text(item['status'].toString())),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  User? get _currentUser =>
      _profile ?? ref.read(authNotifierProvider).value?.user;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = _profile ?? authState.value?.user;
    final displayName = _displayName(user);
    final avatarUrl = _avatarUrl(user);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Tài khoản')),
      body: _isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(refresh: true),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ProfileHeader(
                    displayName: displayName,
                    subtitle: user?.email ?? user?.phoneNumber ?? '',
                    avatarUrl: avatarUrl,
                    role: user?.role,
                    onEditAvatar: _updateAvatar,
                  ),
                  if (_isRefreshing) const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Hoạt động của tôi'),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.45,
                          children: [
                            _StatTile(
                              icon: Icons.local_laundry_service,
                              value: _statValue(
                                'totalLaundryOrders',
                                _completedOrders,
                              ),
                              label: 'Giặt đồ',
                              color: const Color(0xFF1976D2),
                            ),
                            _StatTile(
                              icon: Icons.inventory_2,
                              value: _statValue(
                                'totalStorageOrders',
                                _activeOrders,
                              ),
                              label: 'Gửi đồ',
                              color: const Color(0xFFFF9800),
                            ),
                            _StatTile(
                              icon: Icons.receipt_long,
                              value: _totalOrders.toString(),
                              label: 'Tổng đơn',
                              color: AppColors.primary,
                            ),
                            _StatTile(
                              icon: Icons.stars,
                              value:
                                  '${_loyalty?.pointsAccount.pointsBalance ?? 0}',
                              label: 'Điểm thưởng',
                              color: const Color(0xFF9C27B0),
                            ),
                          ],
                        ),
                        if (_loyalty != null) ...[
                          const SizedBox(height: 20),
                          _sectionTitle('Tích điểm'),
                          _LoyaltyCard(loyalty: _loyalty!),
                        ],
                        const SizedBox(height: 20),
                        _sectionTitle('Lối tắt'),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              Icons.favorite,
                              'Dịch vụ yêu thích',
                              'Cửa hàng đã lưu',
                              () => context.go('/user/favorites'),
                            ),
                            _MenuItem(
                              Icons.card_giftcard,
                              'Voucher & điểm thưởng',
                              'Ưu đãi đang có',
                              () => context.go('/user/vouchers?tab=rewards'),
                            ),
                            _MenuItem(
                              Icons.receipt_long,
                              'Đơn hàng của tôi',
                              'Theo dõi lịch sử sử dụng',
                              () => context.go('/user/orders'),
                            ),
                            _MenuItem(
                              Icons.report_problem,
                              'Khiếu nại của tôi',
                              'Theo dõi phản hồi đơn hàng',
                              _showComplaints,
                            ),
                            _MenuItem(
                              Icons.build,
                              'Báo cáo tủ của tôi',
                              'Sự cố locker đã gửi',
                              _showLockerReports,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Tài khoản'),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              Icons.edit,
                              'Cập nhật hồ sơ',
                              'Thông tin cá nhân',
                              user == null ? () {} : () => _editProfile(user),
                            ),
                            _MenuItem(
                              Icons.lock,
                              'Đổi mật khẩu',
                              'Bảo mật tài khoản',
                              _changePassword,
                            ),
                            _MenuItem(
                              Icons.store,
                              _partnerProfile == null
                                  ? 'Đăng ký đối tác'
                                  : 'Hồ sơ đối tác',
                              _partnerProfile == null
                                  ? 'Mở rộng sang vai trò partner'
                                  : _partnerProfile!.status,
                              _partnerProfile == null
                                  ? _registerPartner
                                  : () => context.go('/partner/profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _statValue(String key, int fallback) {
    final value = _userStats?[key];
    if (value is num) return value.toInt().toString();
    return fallback.toString();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.subtitle,
    required this.avatarUrl,
    required this.role,
    required this.onEditAvatar,
  });

  final String displayName;
  final String subtitle;
  final String? avatarUrl;
  final UserRole? role;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.primary,
                backgroundImage: avatarUrl == null
                    ? null
                    : NetworkImage(avatarUrl!),
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 54, color: Colors.white)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton.filled(
                  onPressed: onEditAvatar,
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          const SizedBox(height: 10),
          Chip(
            avatar: const Icon(Icons.workspace_premium, color: Colors.amber),
            label: Text(role == UserRole.partner ? 'Đối tác' : 'Thành viên'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(label, style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.loyalty});

  final LoyaltySummary loyalty;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _LoyaltyMetric(
                icon: Icons.stars,
                value: '${loyalty.pointsAccount.pointsBalance}',
                label: 'Điểm hiện có',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LoyaltyMetric(
                icon: Icons.savings,
                value: formatCurrency(loyalty.totalRedeemableValue),
                label: 'Có thể quy đổi',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LoyaltyMetric(
                icon: Icons.card_membership,
                value: '${loyalty.totalFreeRewards}',
                label: 'Ưu đãi miễn phí',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyMetric extends StatelessWidget {
  const _LoyaltyMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final item in items)
            ListTile(
              leading: Icon(item.icon, color: AppColors.primary),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            ),
        ],
      ),
    );
  }
}

String _displayName(User? user) {
  if (user == null) return 'Người dùng';
  if ((user.fullName ?? '').isNotEmpty) return user.fullName!;
  final name = '${user.lastName ?? ''} ${user.firstName ?? ''}'.trim();
  return name.isEmpty ? 'Người dùng' : name;
}

String? _avatarUrl(User? user) {
  return user?.imageUrl ?? user?.image ?? user?.avatarUrl;
}
