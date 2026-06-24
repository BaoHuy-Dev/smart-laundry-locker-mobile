import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  final _service = LockerOpsService();
  late final TabController _tabs = TabController(length: 5, vsync: this);

  // Tab 0 – Dashboard
  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _orderStats;
  Map<String, dynamic>? _revenue;

  // Tab 1 – Users
  List<Map<String, dynamic>> _users = [];

  // Tab 2 – Stores
  List<Map<String, dynamic>> _stores = [];

  // Tab 3 – Orders
  List<Map<String, dynamic>> _orders = [];
  String? _orderFilter;

  // Tab 4 – Promotions
  List<Map<String, dynamic>> _promotions = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.adminDashboard().catchError((_) => <String, dynamic>{}),
        _service.adminOrderStats().catchError((_) => <String, dynamic>{}),
        _service.adminRevenue().catchError((_) => <String, dynamic>{}),
        _service.adminUsers().catchError((_) => <Map<String, dynamic>>[]),
        _service.adminStores().catchError((_) => <Map<String, dynamic>>[]),
        _service
            .adminOrders(status: _orderFilter)
            .catchError((_) => <Map<String, dynamic>>[]),
        _service.adminPromotions().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, dynamic>?;
        _orderStats = results[1] as Map<String, dynamic>?;
        _revenue = results[2] as Map<String, dynamic>?;
        _users = (results[3] as List).cast<Map<String, dynamic>>();
        _stores = (results[4] as List).cast<Map<String, dynamic>>();
        _orders = (results[5] as List).cast<Map<String, dynamic>>();
        _promotions = (results[6] as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await TokenService.clearTokens();
    if (mounted) context.go('/onboarding');
  }

  Future<void> _run(Future<Object?> Function() fn, String ok) async {
    try {
      await fn();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ok)));
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          BrandHeroHeader(
            title: 'Quản trị hệ thống',
            subtitle:
                '${_users.length} người dùng · ${_stores.length} cửa hàng',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandCircleIconButton(icon: Icons.refresh, onTap: _load),
                const SizedBox(width: 8),
                BrandCircleIconButton(icon: Icons.logout, onTap: _logout),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              indicatorColor: opsPrimary,
              labelColor: opsDark,
              unselectedLabelColor: opsMutedText,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Người dùng'),
                Tab(text: 'Cửa hàng'),
                Tab(text: 'Đơn hàng'),
                Tab(text: 'Khuyến mãi'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AislBrand.navy),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _buildDashboard(),
                      _buildUsers(),
                      _buildStores(),
                      _buildOrders(),
                      _buildPromotions(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Tab 0: Dashboard ───────────────────────────────────────────────────────

  Widget _buildDashboard() {
    final totalOrders = _adminVal(_overview, 'totalOrders') ??
        _adminVal(_orderStats, 'totalOrders') ??
        '–';
    final totalUsers = _adminVal(_overview, 'totalUsers') ??
        _adminVal(_overview, 'userCount') ??
        '${_users.length}';
    final totalStores = _adminVal(_overview, 'totalStores') ??
        _adminVal(_overview, 'storeCount') ??
        '${_stores.length}';
    final todayRevenue = _adminVal(_revenue, 'todayRevenue') ??
        _adminVal(_revenue, 'today') ??
        '–';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OpsSectionLabel('Tổng quan', icon: Icons.dashboard_outlined),
          Row(
            children: [
              Expanded(
                child: _AdminMetricCard(
                  label: 'Tổng đơn',
                  value: totalOrders,
                  color: const Color(0xFF2563EB),
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AdminMetricCard(
                  label: 'Người dùng',
                  value: totalUsers,
                  color: const Color(0xFF7C3AED),
                  icon: Icons.people_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _AdminMetricCard(
                  label: 'Cửa hàng',
                  value: totalStores,
                  color: const Color(0xFF0891B2),
                  icon: Icons.store_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AdminMetricCard(
                  label: 'DT hôm nay',
                  value: todayRevenue,
                  color: const Color(0xFF16A34A),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          if (_orderStats != null && _orderStats!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const OpsSectionLabel(
              'Đơn theo trạng thái',
              icon: Icons.bar_chart_outlined,
            ),
            OpsCard(
              child: Column(
                children: [
                  for (final entry in _orderStats!.entries)
                    if (entry.value != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: opsMutedText,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: opsDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
          if (_revenue != null && _revenue!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const OpsSectionLabel(
              'Doanh thu',
              icon: Icons.trending_up_outlined,
            ),
            OpsCard(
              child: Column(
                children: [
                  for (final entry in _revenue!.entries)
                    if (entry.value != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: opsMutedText,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: opsDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab 1: Users ────────────────────────────────────────────────────────────

  Widget _buildUsers() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_users.isEmpty)
            const OpsEmptyState(
              icon: Icons.people_outline,
              title: 'Chưa có người dùng',
            )
          else
            for (final u in _users) _userCard(u),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final email = u['email']?.toString() ?? u['username']?.toString() ?? '–';
    final name = u['fullName']?.toString() ??
        u['name']?.toString() ??
        email.split('@').first;
    final roles = _roleList(u['roles']);
    final status = u['status']?.toString() ?? u['accountStatus']?.toString();
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim()[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OpsCard(
        onTap: () => _userActions(u),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: opsPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: opsPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: opsDark,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 12, color: opsMutedText),
                  ),
                  if (roles.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        for (final r in roles) _RoleChip(r),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            StatusChip(status),
          ],
        ),
      ),
    );
  }

  Future<void> _userActions(Map<String, dynamic> u) async {
    final userId = _asInt(u['id']);
    if (userId == null) return;
    final status = u['status']?.toString() ?? u['accountStatus']?.toString();
    final isActive = status?.toUpperCase() == 'ACTIVE';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetCtx) {
        Widget tile(IconData icon, String label, Color c, VoidCallback onTap) {
          return OpsSheetAction(
            icon: icon,
            label: label,
            color: c,
            onTap: () {
              Navigator.pop(sheetCtx);
              onTap();
            },
          );
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u['fullName']?.toString() ??
                      u['email']?.toString() ??
                      'Người dùng #$userId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: opsDark,
                  ),
                ),
                const SizedBox(height: 16),
                tile(
                  Icons.manage_accounts_outlined,
                  'Đổi role',
                  const Color(0xFF7C3AED),
                  () => _changeRoleFlow(u),
                ),
                if (isActive)
                  tile(
                    Icons.block,
                    'Khoá tài khoản',
                    const Color(0xFFDC2626),
                    () => _run(
                      () => _service.adminSetUserStatus(userId, 'INACTIVE'),
                      'Đã khoá tài khoản',
                    ),
                  )
                else
                  tile(
                    Icons.check_circle_outline,
                    'Mở khoá tài khoản',
                    const Color(0xFF16A34A),
                    () => _run(
                      () => _service.adminSetUserStatus(userId, 'ACTIVE'),
                      'Đã mở khoá tài khoản',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeRoleFlow(Map<String, dynamic> u) async {
    final userId = _asInt(u['id']);
    if (userId == null) return;
    final currentRoles = _roleList(u['roles']);
    var selected = currentRoles.isNotEmpty ? currentRoles.first : 'CUSTOMER';

    const allRoles = [
      'CUSTOMER',
      'MANAGER',
      'MAINTENANCE',
      'STAFF',
      'TECHNICIAN',
      'ADMIN',
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Đổi role'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in allRoles)
                ChoiceChip(
                  label: Text(r),
                  selected: selected == r,
                  onSelected: (_) => setLocal(() => selected = r),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: opsPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await _run(
      () => _service.adminSetUserRoles(userId, [result]),
      'Đã đổi role thành $result',
    );
  }

  // ── Tab 2: Stores ───────────────────────────────────────────────────────────

  Widget _buildStores() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              const Expanded(
                child: OpsSectionLabel(
                  'Cửa hàng',
                  icon: Icons.store_outlined,
                ),
              ),
              TextButton.icon(
                onPressed: _createStoreFlow,
                icon: const Icon(Icons.add, size: 18, color: opsPrimary),
                label: const Text(
                  'Thêm mới',
                  style: TextStyle(color: opsPrimary),
                ),
              ),
            ],
          ),
          if (_stores.isEmpty)
            const OpsEmptyState(
              icon: Icons.store_outlined,
              title: 'Chưa có cửa hàng nào',
            )
          else
            for (final s in _stores) _storeCard(s),
        ],
      ),
    );
  }

  Widget _storeCard(Map<String, dynamic> s) {
    final status = s['status']?.toString();
    final isActive = status?.toUpperCase() == 'ACTIVE';
    final storeId = _asInt(s['id']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OpsCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['name']?.toString() ?? 'Cửa hàng #${s['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: opsDark,
                    ),
                  ),
                  if ((s['address']?.toString() ?? '').isNotEmpty)
                    Text(
                      s['address'].toString(),
                      style:
                          const TextStyle(fontSize: 12, color: opsMutedText),
                    ),
                  if ((s['phone']?.toString() ?? '').isNotEmpty)
                    Text(
                      s['phone'].toString(),
                      style:
                          const TextStyle(fontSize: 12, color: opsMutedText),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status),
                if (storeId != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _run(
                      () => _service.adminSetStoreStatus(
                        storeId,
                        isActive ? 'INACTIVE' : 'ACTIVE',
                      ),
                      isActive ? 'Đã tắt cửa hàng' : 'Đã kích hoạt cửa hàng',
                    ),
                    child: Text(
                      isActive ? 'Tắt' : 'Bật',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createStoreFlow() async {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thêm cửa hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên cửa hàng *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: opsPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );

    final name = nameCtrl.text.trim();
    final addr = addrCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    nameCtrl.dispose();
    addrCtrl.dispose();
    phoneCtrl.dispose();

    if (ok != true || name.isEmpty) return;
    await _run(
      () => _service.adminCreateStore({
        'name': name,
        if (addr.isNotEmpty) 'address': addr,
        if (phone.isNotEmpty) 'phone': phone,
      }),
      'Đã tạo cửa hàng "$name"',
    );
  }

  // ── Tab 3: Orders ───────────────────────────────────────────────────────────

  Widget _buildOrders() {
    const statuses = [
      null,
      'INITIALIZED',
      'STORING',
      'COMPLETED',
      'CANCELED',
    ];
    const labels = [
      'Tất cả',
      'Khởi tạo',
      'Đang lưu',
      'Hoàn thành',
      'Đã huỷ',
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => FilterChip(
                label: Text(labels[i]),
                selected: _orderFilter == statuses[i],
                selectedColor: opsPrimary.withValues(alpha: 0.15),
                checkmarkColor: opsPrimary,
                onSelected: (_) {
                  setState(() => _orderFilter = statuses[i]);
                  _load();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_orders.isEmpty)
            const OpsEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Không có đơn hàng nào',
            )
          else
            for (final o in _orders) _orderCard(o),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    final status = o['status']?.toString();
    final type = o['orderType']?.toString() ?? o['type']?.toString() ?? '–';
    final createdAt = _fmtDate(o['createdAt']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OpsCard(
        onTap: () => _orderActions(o),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${o['id']} · $type',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: opsDark,
                    ),
                  ),
                ),
                StatusChip(status),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if ((o['customerEmail'] ?? o['userEmail'] ?? '').toString().isNotEmpty)
                  _AdminPill(
                    icon: Icons.person_outline,
                    text: (o['customerEmail'] ?? o['userEmail']).toString(),
                  ),
                if (createdAt != null)
                  _AdminPill(icon: Icons.schedule, text: createdAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _orderActions(Map<String, dynamic> o) async {
    final orderId = _asInt(o['id']);
    if (orderId == null) return;

    const newStatuses = [
      'INITIALIZED',
      'STORING',
      'COMPLETED',
      'CANCELED',
    ];

    var selected = o['status']?.toString() ?? 'INITIALIZED';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setLocal) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn #${o['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: opsDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Đổi trạng thái',
                  style: TextStyle(
                    fontSize: 13,
                    color: opsMutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in newStatuses)
                      ChoiceChip(
                        label: Text(s),
                        selected: selected == s,
                        onSelected: (_) => setLocal(() => selected = s),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: opsPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _run(
                        () => _service.adminSetOrderStatus(orderId, selected),
                        'Đã đổi trạng thái đơn #${o['id']}',
                      );
                    },
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab 4: Promotions ───────────────────────────────────────────────────────

  Widget _buildPromotions() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              const Expanded(
                child: OpsSectionLabel(
                  'Khuyến mãi',
                  icon: Icons.local_offer_outlined,
                ),
              ),
              TextButton.icon(
                onPressed: _createPromotionFlow,
                icon: const Icon(Icons.add, size: 18, color: opsPrimary),
                label: const Text(
                  'Thêm mới',
                  style: TextStyle(color: opsPrimary),
                ),
              ),
            ],
          ),
          if (_promotions.isEmpty)
            const OpsEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'Chưa có khuyến mãi nào',
            )
          else
            for (final p in _promotions) _promotionCard(p),
        ],
      ),
    );
  }

  Widget _promotionCard(Map<String, dynamic> p) {
    final promoId = _asInt(p['id']);
    final code = p['code']?.toString() ?? '–';
    final type = p['discountType']?.toString() ?? '';
    final value = p['discountValue'] ?? p['value'];
    final status = p['status']?.toString();
    final startDate = _fmtDate(p['startDate'] ?? p['startAt']);
    final endDate = _fmtDate(p['endDate'] ?? p['endAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OpsCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: opsDark,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (type.isNotEmpty)
                        _AdminPill(
                          icon: Icons.percent,
                          text: type == 'PERCENT'
                              ? '$value%'
                              : '$valueđ',
                        ),
                    ],
                  ),
                  if (startDate != null || endDate != null)
                    Text(
                      '${startDate ?? ''} → ${endDate ?? ''}',
                      style: const TextStyle(fontSize: 12, color: opsMutedText),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                StatusChip(status),
                if (promoId != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _deletePromotion(promoId, code),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePromotion(int promoId, String code) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xoá khuyến mãi'),
        content: Text('Xác nhận xoá mã "$code"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(
      () => _service.adminDeletePromotion(promoId),
      'Đã xoá mã "$code"',
    );
  }

  Future<void> _createPromotionFlow() async {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minOrderCtrl = TextEditingController();
    var discountType = 'PERCENT';
    DateTime? startDate;
    DateTime? endDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tạo khuyến mãi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Mã code *'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Loại giảm giá',
                  style: TextStyle(fontSize: 12, color: opsMutedText),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in ['PERCENT', 'FIXED'])
                      ChoiceChip(
                        label: Text(t),
                        selected: discountType == t,
                        onSelected: (_) => setLocal(() => discountType = t),
                      ),
                  ],
                ),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: discountType == 'PERCENT' ? 'Phần trăm *' : 'Số tiền *',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Đơn hàng tối thiểu'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          startDate != null
                              ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                              : 'Ngày bắt đầu',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (d != null) setLocal(() => startDate = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          endDate != null
                              ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                              : 'Ngày kết thúc',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (d != null) setLocal(() => endDate = d);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: opsPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );

    final code = codeCtrl.text.trim().toUpperCase();
    final value = double.tryParse(valueCtrl.text.trim());
    final minOrder = double.tryParse(minOrderCtrl.text.trim());
    codeCtrl.dispose();
    valueCtrl.dispose();
    minOrderCtrl.dispose();

    if (ok != true || code.isEmpty || value == null) return;
    await _run(
      () => _service.adminCreatePromotion({
        'code': code,
        'discountType': discountType,
        'discountValue': value,
        if (minOrder != null) 'minOrderAmount': minOrder,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      }),
      'Đã tạo mã "$code"',
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String? _adminVal(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final v = map[key];
    return v != null ? '$v' : null;
  }

  List<String> _roleList(dynamic roles) {
    if (roles is List) return roles.map((e) => '$e').toList();
    if (roles is String && roles.isNotEmpty) return [roles];
    return const [];
  }

  String? _fmtDate(dynamic value) {
    final d = DateTime.tryParse('$value')?.toLocal();
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

// ── Local widgets ─────────────────────────────────────────────────────────────

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: opsMutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPill extends StatelessWidget {
  const _AdminPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: opsPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: opsPrimary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: opsPrimary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: opsPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip(this.role);
  final String role;

  static Color _colorFor(String role) => switch (role) {
    'ADMIN' => const Color(0xFFDC2626),
    'MANAGER' => const Color(0xFF7C3AED),
    'MAINTENANCE' => const Color(0xFFD97706),
    'STAFF' => const Color(0xFF0891B2),
    'TECHNICIAN' => const Color(0xFF16A34A),
    _ => opsMutedText,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
