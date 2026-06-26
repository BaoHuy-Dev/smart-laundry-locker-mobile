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
  late final TabController _tabs = TabController(length: 6, vsync: this);

  // Tab 0 – Dashboard
  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _orderStats;
  Map<String, dynamic>? _revenue;

  // Tab 1 – Users
  List<Map<String, dynamic>> _users = [];
  String _userSearch = '';
  String? _userStatusFilter;  // null = all, 'ACTIVE', 'INACTIVE'
  final Set<String> _userRoleFilter = {};
  String _userSort = 'name'; // 'name' | 'role' | 'status'

  List<Map<String, dynamic>> get _filteredUsers {
    var list = _users.where((u) {
      final name = (u['fullName'] ?? u['name'] ?? u['email'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final q = _userSearch.toLowerCase();
      if (q.isNotEmpty && !name.contains(q) && !email.contains(q)) return false;
      if (_userStatusFilter != null && u['status'] != _userStatusFilter) return false;
      if (_userRoleFilter.isNotEmpty) {
        final roles = _roleList(u['roles']);
        if (!roles.any(_userRoleFilter.contains)) return false;
      }
      return true;
    }).toList();
    list.sort((a, b) {
      switch (_userSort) {
        case 'role':
          return (_roleList(a['roles']).firstOrNull ?? '').compareTo(_roleList(b['roles']).firstOrNull ?? '');
        case 'status':
          return (a['status'] ?? '').toString().compareTo((b['status'] ?? '').toString());
        default:
          final na = (a['fullName'] ?? a['email'] ?? '').toString();
          final nb = (b['fullName'] ?? b['email'] ?? '').toString();
          return na.toLowerCase().compareTo(nb.toLowerCase());
      }
    });
    return list;
  }

  // Tab 2 – Stores
  List<Map<String, dynamic>> _stores = [];
  String _storeSearch = '';
  String? _storeStatusFilter;
  String _storeSort = 'name';

  List<Map<String, dynamic>> get _filteredStores {
    String q = _storeSearch.toLowerCase();
    var list = _stores.where((s) {
      if (_storeStatusFilter != null && s['status'] != _storeStatusFilter) return false;
      if (q.isNotEmpty) {
        final name = (s['name'] ?? '').toString().toLowerCase();
        final addr = (s['address'] ?? '').toString().toLowerCase();
        if (!name.contains(q) && !addr.contains(q)) return false;
      }
      return true;
    }).toList();
    list.sort((a, b) {
      if (_storeSort == 'status') {
        return (a['status'] ?? '').toString().compareTo((b['status'] ?? '').toString());
      }
      return (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase());
    });
    return list;
  }

  // Tab 3 – Orders
  List<Map<String, dynamic>> _orders = [];
  String? _orderFilter;
  String _orderSearch = '';
  String? _orderTypeFilter;

  List<Map<String, dynamic>> get _filteredOrders {
    final q = _orderSearch.toLowerCase();
    return _orders.where((o) {
      if (_orderFilter != null && o['status'] != _orderFilter) return false;
      if (_orderTypeFilter != null) {
        final type = (o['orderType'] ?? o['type'] ?? '').toString().toUpperCase();
        if (type != _orderTypeFilter) return false;
      }
      if (q.isNotEmpty) {
        final id = '#${o['id']}'.toLowerCase();
        final email = (o['customerEmail'] ?? o['userEmail'] ?? '').toString().toLowerCase();
        if (!id.contains(q) && !email.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  // Tab 4 – Promotions
  List<Map<String, dynamic>> _promotions = [];
  String _promoSearch = '';
  String? _promoTypeFilter;
  String? _promoStatusFilter;

  List<Map<String, dynamic>> get _filteredPromotions {
    final q = _promoSearch.toLowerCase();
    return _promotions.where((p) {
      if (_promoStatusFilter != null && p['status'] != _promoStatusFilter) return false;
      if (_promoTypeFilter != null && p['discountType'] != _promoTypeFilter) return false;
      if (q.isNotEmpty) {
        final code = (p['code'] ?? '').toString().toLowerCase();
        final name = (p['name'] ?? '').toString().toLowerCase();
        if (!code.contains(q) && !name.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  // Tab 5 – Drones
  List<Map<String, dynamic>> _drones = [];
  String? _droneStatusFilter;

  final Map<int, bool> _tabLoaded = {};
  final Map<int, bool> _tabLoading = {};

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTabChanged);
    _loadTab(0);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    final i = _tabs.index;
    if (!(_tabLoaded[i] ?? false)) _loadTab(i);
  }

  Future<void> _loadTab(int tab, {bool force = false}) async {
    if (_tabLoading[tab] == true) return;
    if ((_tabLoaded[tab] ?? false) && !force) return;
    setState(() => _tabLoading[tab] = true);
    try {
      switch (tab) {
        case 0:
          final r = await Future.wait([
            _service.adminDashboard().catchError((_) => <String, dynamic>{}),
            _service.adminOrderStats().catchError((_) => <String, dynamic>{}),
            _service.adminRevenue().catchError((_) => <String, dynamic>{}),
          ]);
          if (!mounted) return;
          setState(() {
            _overview = r[0] as Map<String, dynamic>?;
            _orderStats = r[1] as Map<String, dynamic>?;
            _revenue = r[2] as Map<String, dynamic>?;
            _tabLoaded[0] = true;
          });
        case 1:
          final u = await _service.adminUsers().catchError((_) => <Map<String, dynamic>>[]);
          if (!mounted) return;
          setState(() { _users = u; _tabLoaded[1] = true; });
        case 2:
          final s = await _service.adminStores().catchError((_) => <Map<String, dynamic>>[]);
          if (!mounted) return;
          setState(() { _stores = s; _tabLoaded[2] = true; });
        case 3:
          final o = await _service.adminOrders().catchError((_) => <Map<String, dynamic>>[]);
          if (!mounted) return;
          setState(() { _orders = o; _tabLoaded[3] = true; });
        case 4:
          final p = await _service.adminPromotions().catchError((_) => <Map<String, dynamic>>[]);
          if (!mounted) return;
          setState(() { _promotions = p; _tabLoaded[4] = true; });
        case 5:
          final d = await _service.adminDrones().catchError((_) => <Map<String, dynamic>>[]);
          if (!mounted) return;
          setState(() { _drones = d; _tabLoaded[5] = true; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _tabLoading[tab] = false);
    }
  }

  Future<void> _logout() async {
    await TokenService.clearTokens();
    if (mounted) context.go('/onboarding');
  }

  Future<void> _run(Future<void> Function() fn, String ok, {int? reloadTab}) async {
    try {
      await fn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok)));
      }
      final tab = reloadTab ?? _tabs.index;
      await _loadTab(tab, force: true);
      if (tab == 3 && (_tabLoaded[0] ?? false)) await _loadTab(0, force: true);
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
            subtitle: [
              if (_tabLoaded[1] ?? false) '${_users.length} người dùng',
              if (_tabLoaded[2] ?? false) '${_stores.length} cửa hàng',
              if (_tabLoaded[5] ?? false) '${_drones.length} drone',
            ].join(' · '),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandCircleIconButton(
                  icon: Icons.refresh,
                  onTap: () => _loadTab(_tabs.index, force: true),
                ),
                const SizedBox(width: 8),
                BrandCircleIconButton(icon: Icons.logout, onTap: _logout),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              indicatorColor: opsPrimary,
              labelColor: opsDark,
              unselectedLabelColor: opsMutedText,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Người dùng'),
                Tab(text: 'Cửa hàng'),
                Tab(text: 'Đơn hàng'),
                Tab(text: 'Khuyến mãi'),
                Tab(text: 'Drone'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildDashboard(),
                _buildUsers(),
                _buildStores(),
                _buildOrders(),
                _buildPromotions(),
                _buildDrones(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 0: Dashboard ───────────────────────────────────────────────────────

  Widget _buildDashboard() {
    if (_tabLoading[0] == true && _overview == null) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }

    final totalOrders = _adminVal(_overview, 'totalOrders') ??
        _adminVal(_orderStats, 'totalOrders') ??
        '–';
    final totalUsers = _adminVal(_overview, 'totalUsers') ??
        _adminVal(_overview, 'userCount') ??
        '–';
    final totalStores = _adminVal(_overview, 'totalStores') ??
        _adminVal(_overview, 'storeCount') ??
        '–';
    final todayRevenue = _adminVal(_overview, 'revenueToday') ??
        _adminVal(_revenue, 'revenueToday') ??
        _adminVal(_revenue, 'todayRevenue') ??
        '–';

    return RefreshIndicator(
      onRefresh: () => _loadTab(0, force: true),
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
          if (_orderStats != null && _orderStats!.isNotEmpty) ...() {
            final statusMap = (_orderStats!['byStatus'] as Map?)
                    ?.cast<String, dynamic>() ??
                _orderStats!;
            return [
            const SizedBox(height: 16),
            const OpsSectionLabel(
              'Đơn theo trạng thái',
              icon: Icons.bar_chart_outlined,
            ),
            OpsCard(
              child: Column(
                children: [
                  for (final entry in statusMap.entries)
                    if (entry.value != null && entry.value is! Map)
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
            ];
          }(),
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
    if (_tabLoading[1] == true && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }
    final filtered = _filteredUsers;
    final hasActiveFilter = _userStatusFilter != null || _userRoleFilter.isNotEmpty || _userSort != 'name';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _userSearch = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm tên, email…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: _showUserFilter,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: hasActiveFilter ? opsPrimary : Colors.grey.shade100,
                      foregroundColor: hasActiveFilter ? Colors.white : opsDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (hasActiveFilter)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (hasActiveFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} / ${_users.length} người dùng',
                  style: const TextStyle(fontSize: 12, color: opsMutedText),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _userSearch = '';
                    _userStatusFilter = null;
                    _userRoleFilter.clear();
                    _userSort = 'name';
                  }),
                  child: const Text(
                    'Xoá bộ lọc',
                    style: TextStyle(fontSize: 12, color: opsPrimary),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadTab(1, force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                if (filtered.isEmpty)
                  OpsEmptyState(
                    icon: Icons.people_outline,
                    title: _users.isEmpty ? 'Chưa có người dùng' : 'Không tìm thấy kết quả',
                  )
                else
                  for (final u in filtered) _userCard(u),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUserFilter() {
    var tempStatus = _userStatusFilter;
    final tempRoles = Set<String>.from(_userRoleFilter);
    var tempSort = _userSort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bộ lọc & Sắp xếp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Trạng thái', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in [null, 'ACTIVE', 'INACTIVE'])
                    ChoiceChip(
                      label: Text(s ?? 'Tất cả'),
                      selected: tempStatus == s,
                      onSelected: (_) => setLocal(() => tempStatus = s),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Vai trò', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final r in ['ADMIN', 'MANAGER', 'STAFF', 'MAINTENANCE', 'CUSTOMER', 'USER'])
                    FilterChip(
                      label: Text(r),
                      selected: tempRoles.contains(r),
                      onSelected: (v) => setLocal(() => v ? tempRoles.add(r) : tempRoles.remove(r)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Sắp xếp theo', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in {'name': 'Tên', 'role': 'Vai trò', 'status': 'Trạng thái'}.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: tempSort == entry.key,
                      onSelected: (_) => setLocal(() => tempSort = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _userStatusFilter = tempStatus;
                      _userRoleFilter
                        ..clear()
                        ..addAll(tempRoles);
                      _userSort = tempSort;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
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
                      reloadTab: 1,
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
                      reloadTab: 1,
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
      reloadTab: 1,
    );
  }

  // ── Tab 2: Stores ───────────────────────────────────────────────────────────

  Widget _buildStores() {
    if (_tabLoading[2] == true && _stores.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }
    final filtered = _filteredStores;
    final hasFilter = _storeSearch.isNotEmpty || _storeStatusFilter != null || _storeSort != 'name';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _storeSearch = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm tên, địa chỉ...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: _showStoreFilter,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: hasFilter ? opsPrimary : Colors.grey.shade100,
                      foregroundColor: hasFilter ? Colors.white : opsDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (hasFilter)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    ),
                ],
              ),
              TextButton.icon(
                onPressed: _createStoreFlow,
                icon: const Icon(Icons.add, size: 18, color: opsPrimary),
                label: const Text('Thêm mới', style: TextStyle(color: opsPrimary, fontSize: 13)),
              ),
            ],
          ),
        ),
        if (hasFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Text('${filtered.length} / ${_stores.length} cửa hàng', style: const TextStyle(fontSize: 12, color: opsMutedText)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() { _storeSearch = ''; _storeStatusFilter = null; _storeSort = 'name'; }),
                  child: const Text('Xoá bộ lọc', style: TextStyle(fontSize: 12, color: opsPrimary)),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadTab(2, force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                if (filtered.isEmpty)
                  OpsEmptyState(icon: Icons.store_outlined, title: _stores.isEmpty ? 'Chưa có cửa hàng nào' : 'Không tìm thấy kết quả')
                else
                  for (final s in filtered) _storeCard(s),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showStoreFilter() {
    var tempStatus = _storeStatusFilter;
    var tempSort = _storeSort;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bộ lọc & Sắp xếp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Trạng thái', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final s in [null, 'ACTIVE', 'INACTIVE', 'PENDING'])
                  ChoiceChip(label: Text(s ?? 'Tất cả'), selected: tempStatus == s, onSelected: (_) => setLocal(() => tempStatus = s)),
              ]),
              const SizedBox(height: 16),
              const Text('Sắp xếp theo', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final entry in {'name': 'Tên', 'status': 'Trạng thái'}.entries)
                  ChoiceChip(label: Text(entry.value), selected: tempSort == entry.key, onSelected: (_) => setLocal(() => tempSort = entry.key)),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () { setState(() { _storeStatusFilter = tempStatus; _storeSort = tempSort; }); Navigator.pop(ctx); },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
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
                  if ((s['phone']?.toString() ?? s['contactPhone']?.toString() ?? '').isNotEmpty)
                    Text(
                      (s['phone'] ?? s['contactPhone']).toString(),
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
                      reloadTab: 2,
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
      reloadTab: 2,
    );
  }

  // ── Tab 3: Orders ───────────────────────────────────────────────────────────

  Widget _buildOrders() {
    if (_tabLoading[3] == true && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }
    const statuses = [null, 'INITIALIZED', 'STORING', 'COMPLETED', 'CANCELED'];
    const labels = ['Tất cả', 'Khởi tạo', 'Đang lưu', 'Hoàn thành', 'Đã huỷ'];
    final filtered = _filteredOrders;
    final hasFilter = _orderSearch.isNotEmpty || _orderTypeFilter != null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _orderSearch = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm mã đơn, email...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: _showOrderTypeFilter,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: hasFilter ? opsPrimary : Colors.grey.shade100,
                      foregroundColor: hasFilter ? Colors.white : opsDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (hasFilter)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: SizedBox(
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
                onSelected: (_) => setState(() => _orderFilter = statuses[i]),
              ),
            ),
          ),
        ),
        if (hasFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Text('${filtered.length} / ${_orders.length} đơn hàng', style: const TextStyle(fontSize: 12, color: opsMutedText)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() { _orderSearch = ''; _orderTypeFilter = null; }),
                  child: const Text('Xoá bộ lọc', style: TextStyle(fontSize: 12, color: opsPrimary)),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadTab(3, force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                if (filtered.isEmpty)
                  OpsEmptyState(icon: Icons.receipt_long_outlined, title: _orders.isEmpty ? 'Không có đơn hàng nào' : 'Không tìm thấy kết quả')
                else
                  for (final o in filtered) _orderCard(o),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showOrderTypeFilter() {
    var tempType = _orderTypeFilter;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lọc loại đơn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Loại đơn', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final entry in {null: 'Tất cả', 'SEND': 'Gửi hàng', 'RENTAL': 'Thuê tủ', 'STORAGE': 'Lưu trữ'}.entries)
                  ChoiceChip(label: Text(entry.value), selected: tempType == entry.key, onSelected: (_) => setLocal(() => tempType = entry.key)),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () { setState(() => _orderTypeFilter = tempType); Navigator.pop(ctx); },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
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
                if ((o['customerEmail'] ?? o['userEmail'] ?? o['userId']) != null)
                  _AdminPill(
                    icon: Icons.person_outline,
                    text: (o['customerEmail'] ?? o['userEmail'] ?? 'User #${o['userId']}').toString(),
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
                        reloadTab: 3,
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
    if (_tabLoading[4] == true && _promotions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }
    final filtered = _filteredPromotions;
    final hasFilter = _promoSearch.isNotEmpty || _promoStatusFilter != null || _promoTypeFilter != null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _promoSearch = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm mã code, tên...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: _showPromoFilter,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: hasFilter ? opsPrimary : Colors.grey.shade100,
                      foregroundColor: hasFilter ? Colors.white : opsDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (hasFilter)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    ),
                ],
              ),
              TextButton.icon(
                onPressed: _createPromotionFlow,
                icon: const Icon(Icons.add, size: 18, color: opsPrimary),
                label: const Text('Thêm mới', style: TextStyle(color: opsPrimary, fontSize: 13)),
              ),
            ],
          ),
        ),
        if (hasFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Text('${filtered.length} / ${_promotions.length} khuyến mãi', style: const TextStyle(fontSize: 12, color: opsMutedText)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() { _promoSearch = ''; _promoStatusFilter = null; _promoTypeFilter = null; }),
                  child: const Text('Xoá bộ lọc', style: TextStyle(fontSize: 12, color: opsPrimary)),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadTab(4, force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                if (filtered.isEmpty)
                  OpsEmptyState(icon: Icons.local_offer_outlined, title: _promotions.isEmpty ? 'Chưa có khuyến mãi nào' : 'Không tìm thấy kết quả')
                else
                  for (final p in filtered) _promotionCard(p),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPromoFilter() {
    var tempStatus = _promoStatusFilter;
    var tempType = _promoTypeFilter;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bộ lọc khuyến mãi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Trạng thái', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final entry in {null: 'Tất cả', 'ACTIVE': 'Đang dùng', 'INACTIVE': 'Tắt'}.entries)
                  ChoiceChip(label: Text(entry.value), selected: tempStatus == entry.key, onSelected: (_) => setLocal(() => tempStatus = entry.key)),
              ]),
              const SizedBox(height: 16),
              const Text('Loại giảm giá', style: TextStyle(fontSize: 13, color: opsMutedText)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final entry in {null: 'Tất cả', 'PERCENT': 'Phần trăm', 'FIXED_AMOUNT': 'Số tiền cố định'}.entries)
                  ChoiceChip(label: Text(entry.value), selected: tempType == entry.key, onSelected: (_) => setLocal(() => tempType = entry.key)),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () { setState(() { _promoStatusFilter = tempStatus; _promoTypeFilter = tempType; }); Navigator.pop(ctx); },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
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
      reloadTab: 4,
    );
  }

  Future<void> _createPromotionFlow() async {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minOrderCtrl = TextEditingController();
    var discountType = 'PERCENT'; // PERCENT | FIXED_AMOUNT (matches backend enum)
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
                    for (final t in ['PERCENT', 'FIXED_AMOUNT'])
                      ChoiceChip(
                        label: Text(t == 'FIXED_AMOUNT' ? 'FIXED' : t),
                        selected: discountType == t,
                        onSelected: (_) => setLocal(() => discountType = t),
                      ),
                  ],
                ),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: discountType == 'PERCENT' ? 'Phần trăm (%) *' : 'Số tiền (đ) *',
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
      reloadTab: 4,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String? _adminVal(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final v = map[key];
    return v != null ? '$v' : null;
  }

  // ── Tab 5: Drones ──────────────────────────────────────────────────────────

  Widget _buildDrones() {
    if (_tabLoading[5] == true && _drones.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }
    const statuses = [null, 'IDLE', 'CHARGING', 'IN_FLIGHT', 'FAULT'];
    const labels = ['Tất cả', 'IDLE', 'Đang sạc', 'Đang bay', 'Lỗi'];

    final filtered = _droneStatusFilter == null
        ? _drones
        : _drones.where((d) => d['status'] == _droneStatusFilter).toList();

    final idle = _drones.where((d) => d['status'] == 'IDLE').length;
    final charging = _drones.where((d) => d['status'] == 'CHARGING').length;
    final fault = _drones.where((d) => d['status'] == 'FAULT').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Expanded(child: _DroneStatBadge(label: 'Tổng', value: _drones.length, color: opsPrimary)),
              const SizedBox(width: 8),
              Expanded(child: _DroneStatBadge(label: 'IDLE', value: idle, color: const Color(0xFF16A34A))),
              const SizedBox(width: 8),
              Expanded(child: _DroneStatBadge(label: 'Sạc', value: charging, color: const Color(0xFFF59E0B))),
              const SizedBox(width: 8),
              Expanded(child: _DroneStatBadge(label: 'Lỗi', value: fault, color: const Color(0xFFDC2626))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _createDroneFlow,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm drone'),
              style: OutlinedButton.styleFrom(foregroundColor: opsPrimary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => FilterChip(
                label: Text(labels[i]),
                selected: _droneStatusFilter == statuses[i],
                selectedColor: opsPrimary.withValues(alpha: 0.15),
                checkmarkColor: opsPrimary,
                onSelected: (_) => setState(() => _droneStatusFilter = statuses[i]),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadTab(5, force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                if (filtered.isEmpty)
                  OpsEmptyState(
                    icon: Icons.flight_outlined,
                    title: _drones.isEmpty ? 'Chưa có drone nào' : 'Không tìm thấy drone',
                  )
                else
                  for (final d in filtered) _droneCard(d),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _droneCard(Map<String, dynamic> d) {
    final status = d['status']?.toString() ?? '–';
    final battery = (d['batteryPercent'] as num?)?.toDouble() ?? 0.0;
    final code = d['code']?.toString() ?? '–';
    final lockerName = d['lockerName']?.toString() ?? 'Tủ #${d['lockerId']}';
    final fault = d['faultReason']?.toString() ?? '';

    Color statusColor() => switch (status) {
      'IDLE' => const Color(0xFF16A34A),
      'CHARGING' => const Color(0xFFF59E0B),
      'IN_USE' || 'IN_FLIGHT' => opsPrimary,
      'FAULT' => const Color(0xFFDC2626),
      _ => opsMutedText,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OpsCard(
        onTap: () => _droneDetail(d),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flight, size: 18, color: opsPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(code, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: opsDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor().withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor())),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(lockerName, style: const TextStyle(fontSize: 12, color: opsMutedText)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.battery_charging_full, size: 14, color: opsMutedText),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: battery / 100.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: battery < 20 ? const Color(0xFFDC2626) : battery < 50 ? const Color(0xFFF59E0B) : const Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${battery.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: opsDark)),
              ],
            ),
            if (fault.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(fault, style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _droneDetail(Map<String, dynamic> d) async {
    final droneId = _asInt(d['id']);
    if (droneId == null) return;

    final allStatuses = ['IDLE', 'CHARGING', 'IN_FLIGHT', 'MAINTENANCE', 'FAULT'];
    final initialStatus = d['status']?.toString() ?? 'IDLE';
    var selectedStatus = initialStatus;
    final batteryCtrl = TextEditingController(text: (d['batteryPercent'] as num?)?.toStringAsFixed(0) ?? '');
    final reasonCtrl = TextEditingController(text: d['faultReason']?.toString() ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setLocal) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 4, bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Drone ${d['code'] ?? '#$droneId'}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: opsDark)),
              Text(d['lockerName']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: opsMutedText)),
              const SizedBox(height: 16),
              const Text('Đổi trạng thái', style: TextStyle(fontSize: 13, color: opsMutedText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  for (final s in allStatuses)
                    ChoiceChip(label: Text(s), selected: selectedStatus == s, onSelected: (_) => setLocal(() => selectedStatus = s)),
                ],
              ),
              if (selectedStatus == 'FAULT') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Lý do lỗi (bắt buộc)', isDense: true, border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: batteryCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pin (%)', isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: opsPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    final reason = reasonCtrl.text.trim();
                    if (selectedStatus == 'FAULT' && reason.isEmpty) {
                      ScaffoldMessenger.of(sheetCtx).showSnackBar(
                        const SnackBar(content: Text('Cần nhập lý do khi chuyển sang FAULT')),
                      );
                      return;
                    }
                    Navigator.pop(sheetCtx);
                    final battery = double.tryParse(batteryCtrl.text);
                    _run(() async {
                      if (selectedStatus != initialStatus || selectedStatus == 'FAULT') {
                        await _service.updateDroneStatus(
                          droneId,
                          selectedStatus,
                          reason: selectedStatus == 'FAULT' ? reason : null,
                        );
                      }
                      if (battery != null) await _service.updateDroneBattery(droneId, battery.round());
                    }, 'Đã cập nhật drone ${d['code']}', reloadTab: 5);
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _editDroneFlow(d);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Sửa mã/tủ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _createDroneScheduleFlow(d);
                      },
                      icon: const Icon(Icons.event_repeat, size: 16),
                      label: const Text('Lịch định kỳ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    _decommissionDroneFlow(d);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                  label: const Text('Ngừng hoạt động', style: TextStyle(color: Color(0xFFDC2626))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    batteryCtrl.dispose();
    reasonCtrl.dispose();
  }

  // ── #4 vòng đời drone (admin): tạo / sửa / ngừng hoạt động ──────────────────

  Future<List<Map<String, dynamic>>> _lockerOptions() async {
    try {
      return await _service.lockers();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _createDroneFlow() async {
    final lockers = await _lockerOptions();
    if (!mounted) return;
    if (lockers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có tủ nào để gắn drone')),
      );
      return;
    }
    final codeCtrl = TextEditingController();
    int? lockerId = _asInt(lockers.first['id']);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Thêm drone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã drone (vd: DRONE-04)', isDense: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: lockerId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tủ gốc', isDense: true),
                items: [
                  for (final l in lockers)
                    DropdownMenuItem(
                      value: _asInt(l['id']),
                      child: Text('${l['name'] ?? l['code'] ?? 'Tủ'} (#${l['id']})',
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setLocal(() => lockerId = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: opsPrimary, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
    final code = codeCtrl.text.trim();
    codeCtrl.dispose();
    if (ok != true || code.isEmpty || lockerId == null) return;
    _run(() => _service.adminCreateDrone(lockerId!, code), 'Đã thêm drone $code', reloadTab: 5);
  }

  Future<void> _editDroneFlow(Map<String, dynamic> d) async {
    final droneId = _asInt(d['id']);
    if (droneId == null) return;
    final lockers = await _lockerOptions();
    if (!mounted) return;
    final codeCtrl = TextEditingController(text: d['code']?.toString() ?? '');
    int? lockerId = _asInt(d['lockerId']);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Sửa drone ${d['code'] ?? ''}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã drone', isDense: true),
              ),
              const SizedBox(height: 12),
              if (lockers.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: lockerId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tủ gốc', isDense: true),
                  items: [
                    for (final l in lockers)
                      DropdownMenuItem(
                        value: _asInt(l['id']),
                        child: Text('${l['name'] ?? l['code'] ?? 'Tủ'} (#${l['id']})',
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setLocal(() => lockerId = v),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: opsPrimary, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    final code = codeCtrl.text.trim();
    codeCtrl.dispose();
    if (ok != true) return;
    _run(
      () => _service.adminUpdateDrone(
        droneId,
        lockerId: lockerId,
        code: code.isEmpty ? null : code,
      ),
      'Đã cập nhật drone',
      reloadTab: 5,
    );
  }

  Future<void> _decommissionDroneFlow(Map<String, dynamic> d) async {
    final droneId = _asInt(d['id']);
    if (droneId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ngừng hoạt động ${d['code'] ?? 'drone'}?'),
        content: const Text('Drone sẽ bị ẩn khỏi danh sách vận hành. Lịch sử bảo trì vẫn được giữ.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ngừng hoạt động'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _run(() => _service.adminDecommissionDrone(droneId), 'Đã ngừng hoạt động drone', reloadTab: 5);
  }

  // ── #3 tạo lịch bảo trì định kỳ cho drone (admin) ───────────────────────────
  Future<void> _createDroneScheduleFlow(Map<String, dynamic> d) async {
    final droneId = _asInt(d['id']);
    if (droneId == null) return;
    final titleCtrl = TextEditingController(text: 'Kiểm tra định kỳ ${d['code'] ?? ''}'.trim());
    final intervalCtrl = TextEditingController(text: '30');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Lịch định kỳ cho drone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Nội dung', isDense: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: intervalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Chu kỳ (ngày)', isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: opsPrimary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    final title = titleCtrl.text.trim();
    final interval = int.tryParse(intervalCtrl.text.trim());
    titleCtrl.dispose();
    intervalCtrl.dispose();
    if (ok != true || title.isEmpty || interval == null || interval < 1) return;
    _run(
      () => _service.adminCreateDroneSchedule(droneId, title, interval),
      'Đã tạo lịch định kỳ cho drone',
      reloadTab: 5,
    );
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

class _DroneStatBadge extends StatelessWidget {
  const _DroneStatBadge({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.22))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
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
