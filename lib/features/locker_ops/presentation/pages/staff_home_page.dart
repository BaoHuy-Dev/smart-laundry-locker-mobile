import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

/// Home for the STAFF role: locker overview, active orders, and shift stats.
/// Mirror architecture of [MaintenanceHomePage] but uses /api/staff/* endpoints.
class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage>
    with SingleTickerProviderStateMixin {
  final _service = LockerOpsService();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  List<Map<String, dynamic>> _lockers = [];
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _stats;

  // Locker detail state
  int? _selectedLockerId;
  Map<String, dynamic>? _layout;
  bool _layoutLoading = false;

  bool _loading = true;

  // Error flags per section (API may not exist yet)
  String? _lockersError;
  String? _ordersError;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.wait([_loadLockers(), _loadOrders(), _loadStats()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadLockers() async {
    try {
      final data = await _service.staffLockers();
      if (!mounted) return;
      setState(() {
        _lockers = data;
        _lockersError = null;
      });
      // Auto-select first locker
      if (data.isNotEmpty && _selectedLockerId == null) {
        final firstId = _asInt(data.first['id']);
        if (firstId != null) await _selectLocker(firstId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _lockersError = LockerOpsService.errorMessage(e));
    }
  }

  Future<void> _loadOrders() async {
    try {
      final data = await _service.staffOrders();
      if (!mounted) return;
      setState(() {
        _orders = data;
        _ordersError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _ordersError = LockerOpsService.errorMessage(e));
    }
  }

  Future<void> _loadStats() async {
    try {
      final data = await _service.staffStats();
      if (!mounted) return;
      setState(() {
        _stats = data;
        _statsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statsError = LockerOpsService.errorMessage(e));
    }
  }

  Future<void> _selectLocker(int lockerId) async {
    setState(() {
      _selectedLockerId = lockerId;
      _layoutLoading = true;
    });
    try {
      final layout = await _service.staffLayout(lockerId);
      if (!mounted) return;
      setState(() => _layout = layout);
    } catch (_) {
      // layout endpoint may not exist yet; fail silently
      if (mounted) setState(() => _layout = null);
    } finally {
      if (mounted) setState(() => _layoutLoading = false);
    }
  }

  Future<void> _logout() async {
    await TokenService.clearTokens();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          BrandHeroHeader(
            title: 'Nhân viên ca',
            subtitle: _loading
                ? 'Đang tải...'
                : '${_lockers.length} tủ được phân công',
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
                Tab(text: 'Tủ của tôi'),
                Tab(text: 'Đơn hàng'),
                Tab(text: 'Thống kê'),
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
                      _buildLockers(),
                      _buildOrders(),
                      _buildStats(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---- Tab 0: Tủ của tôi ----
  Widget _buildLockers() {
    if (_lockersError != null) {
      return _apiNotReadyBanner(_lockersError!);
    }

    final cells =
        (_layout?['cells'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rows = <int, List<Map<String, dynamic>>>{};
    for (final c in cells) {
      rows.putIfAbsent(_asInt(c['rowIndex']) ?? 0, () => []).add(c);
    }
    final sortedRows = rows.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OpsSectionLabel('Tủ được phân công', icon: Icons.warehouse_outlined),
          if (_lockers.isEmpty)
            const OpsEmptyState(
              icon: Icons.warehouse_outlined,
              title: 'Chưa có tủ nào',
              subtitle: 'Quản lý chưa phân công tủ cho bạn.',
            )
          else
            for (final locker in _lockers)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpsCard(
                  onTap: () {
                    final id = _asInt(locker['id']);
                    if (id != null) _selectLocker(id);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: opsPrimary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${locker['name'] ?? 'Tủ'}  ·  ${locker['code'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: opsDark,
                              ),
                            ),
                            if ((locker['address'] ?? '').toString().isNotEmpty)
                              Text(
                                locker['address'].toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: opsMutedText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      StatusChip(locker['status'] as String?),
                    ],
                  ),
                ),
              ),
          if (_selectedLockerId != null) ...[
            const SizedBox(height: 12),
            const OpsSectionLabel(
              'Sơ đồ ô',
              icon: Icons.grid_view_outlined,
            ),
            if (_layoutLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: opsPrimary),
                ),
              )
            else if (_layout == null)
              const OpsBanner(
                tone: OpsBannerTone.warning,
                icon: Icons.info_outline,
                text: 'Tính năng đang được kích hoạt',
              )
            else ...[
              _layoutSummary(),
              const SizedBox(height: 10),
              OpsCard(
                child: Column(
                  children: [
                    for (final row in sortedRows) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              'Hàng ${row.key}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: opsMutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          for (final c in _sortByCol(row.value))
                            Expanded(child: _cellTile(c)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _layoutSummary() {
    final total = _layout?['totalCells'] ?? 0;
    final available = _layout?['availableCells'] ?? 0;
    final fault = _layout?['faultCells'] ?? 0;
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Tổng ô',
            value: '$total',
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'Sẵn sàng',
            value: '$available',
            color: const Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'Ô lỗi',
            value: '$fault',
            color: const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }

  Widget _cellTile(Map<String, dynamic> cell) {
    final color = statusColor(cell['status'] as String?);
    final type = cell['cellType'] as String? ?? 'STANDARD';
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#${cell['boxNumber']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                if (type == 'DRONE')
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(Icons.flight, size: 12),
                  ),
                if (type == 'XL')
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(Icons.luggage, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              statusLabel(cell['status'] as String?),
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Tab 1: Đơn hàng ----
  Widget _buildOrders() {
    if (_ordersError != null) {
      return _apiNotReadyBanner(_ordersError!);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const OpsSectionLabel('Đơn hàng trong ca', icon: Icons.receipt_outlined),
          if (_orders.isEmpty)
            const OpsEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Không có đơn hàng nào',
              subtitle: 'Các đơn hàng trong ca của bạn sẽ hiện ở đây.',
            )
          else
            for (final o in _orders)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpsCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${typeLabel(o['type'] as String?)}  ·  ${o['orderCode'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: opsDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'KH #${o['userId'] ?? '-'}  ·  tủ ${o['lockerId'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: opsMutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(o['status'] as String?),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ---- Tab 2: Thống kê ----
  Widget _buildStats() {
    if (_statsError != null) {
      return _apiNotReadyBanner(_statsError!);
    }
    if (_stats == null) {
      return const OpsEmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'Chưa có dữ liệu thống kê',
      );
    }
    final available = _stats!['available'] ?? _stats!['availableCells'] ?? 0;
    final occupied = _stats!['occupied'] ?? _stats!['occupiedCells'] ?? 0;
    final fault = _stats!['fault'] ?? _stats!['faultCells'] ?? 0;
    final total = _stats!['total'] ?? _stats!['totalCells'] ?? 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OpsSectionLabel(
            'Tổng quan tủ hôm nay',
            icon: Icons.bar_chart_outlined,
          ),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Tổng ô',
                  value: '$total',
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  label: 'Trống',
                  value: '$available',
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Có đồ',
                  value: '$occupied',
                  color: const Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  label: 'Ô lỗi',
                  value: '$fault',
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_stats!.isNotEmpty)
            for (final entry in _stats!.entries
                .where((e) =>
                    !const {'available', 'occupied', 'fault', 'total', 'availableCells', 'occupiedCells', 'faultCells', 'totalCells'}
                        .contains(e.key))
                .toList())
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OpsCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: opsMutedText,
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: opsDark,
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

  /// Shown when the backend endpoint returns 403/404 (not yet implemented).
  Widget _apiNotReadyBanner(String errorMsg) {
    // Treat 403/404 or network error as "feature not activated"
    final isNotReady = errorMsg.contains('403') ||
        errorMsg.contains('404') ||
        errorMsg.contains('quyền') ||
        errorMsg.contains('kết nối');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: OpsBanner(
          tone: OpsBannerTone.warning,
          icon: Icons.construction_outlined,
          text: isNotReady
              ? 'Tính năng đang được kích hoạt'
              : errorMsg,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

// ---- Helpers ----

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

List<Map<String, dynamic>> _sortByCol(List<Map<String, dynamic>> cells) {
  final sorted = [...cells];
  sorted.sort(
    (a, b) => (_asInt(a['colIndex']) ?? 0).compareTo(_asInt(b['colIndex']) ?? 0),
  );
  return sorted;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: opsMutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
