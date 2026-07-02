import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// Home for the MANAGER role: utilization stats, live cabinet grid,
/// and the full order book.
class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage>
    with SingleTickerProviderStateMixin {
  final _service = LockerOpsService();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  List<Map<String, dynamic>> _stats = [];
  Map<String, dynamic>? _layout;
  int? _selectedLockerId;
  List<Map<String, dynamic>> _orders = [];
  String _orderFilter = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final stats = await _service.managerStats();
      final orders = await _service.managerOrders(status: _orderFilter);
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _orders = orders;
        _selectedLockerId ??= stats.isNotEmpty
            ? stats.first['lockerId'] as int?
            : null;
      });
      if (_selectedLockerId != null) {
        final layout = await _service.layout(_selectedLockerId!);
        if (!mounted) return;
        setState(() => _layout = layout);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Quản lý vận hành'),
        backgroundColor: opsDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Thống kê'),
            Tab(text: 'Sơ đồ tủ'),
            Tab(text: 'Đơn hàng'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [_buildStats(), _buildLayout(), _buildOrders()],
            ),
    );
  }

  // ---- Tab 1: stats ----
  Widget _buildStats() {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final s = _stats[i];
          final utilization = (s['utilization'] as num?)?.toDouble() ?? 0;
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${s['name'] ?? s['code']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (s['landingPad'] == true)
                        const Icon(
                          Icons.flight,
                          size: 18,
                          color: Color(0xFF7C3AED),
                        ),
                      const SizedBox(width: 6),
                      StatusChip(s['status'] as String?),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _stat('Tổng ô', s['totalCells']),
                      _stat(
                        'Trống',
                        s['availableCells'],
                        color: const Color(0xFF16A34A),
                      ),
                      _stat(
                        'Giữ chỗ',
                        s['reservedCells'],
                        color: const Color(0xFF2563EB),
                      ),
                      _stat(
                        'Có đồ',
                        s['occupiedCells'],
                        color: const Color(0xFFEA580C),
                      ),
                      _stat(
                        'Hỏng',
                        s['faultCells'],
                        color: const Color(0xFFDC2626),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: utilization / 100,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(opsPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Công suất sử dụng: $utilization% · phiếu sự cố mở: ${s['openReports']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, Object? value, {Color color = opsDark}) {
    return Column(
      children: [
        Text(
          '${value ?? 0}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // ---- Tab 2: cabinet grid ----
  Widget _buildLayout() {
    final cells =
        (_layout?['cells'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rows = <int, List<Map<String, dynamic>>>{};
    for (final c in cells) {
      rows.putIfAbsent((c['rowIndex'] as int?) ?? 0, () => []).add(c);
    }
    final sortedRows = rows.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedLockerId,
          items: _stats
              .map(
                (s) => DropdownMenuItem(
                  value: s['lockerId'] as int?,
                  child: Text('${s['name'] ?? s['code']}'),
                ),
              )
              .toList(),
          onChanged: (v) async {
            setState(() => _selectedLockerId = v);
            if (v != null) {
              final layout = await _service.layout(v);
              if (mounted) setState(() => _layout = layout);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        if (_layout?['landingPad'] == true)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flight_land,
                  color: Color(0xFF7C3AED),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bãi đáp drone trên nóc · marker ${_layout?['landingMarkerId'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
        for (final row in sortedRows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Hàng ${row.key}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Row(
            children: [
              for (final c
                  in row.value..sort(
                    (a, b) => ((a['colIndex'] as int?) ?? 0).compareTo(
                      (b['colIndex'] as int?) ?? 0,
                    ),
                  ))
                Expanded(child: _cellTile(c)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _cellTile(Map<String, dynamic> cell) {
    final color = statusColor(cell['status'] as String?);
    final type = cell['cellType'] as String? ?? 'STANDARD';
    return GestureDetector(
      onLongPress: () => _faultDialog(cell),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
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
                if (type == 'DRONE') const Icon(Icons.flight, size: 12),
                if (type == 'XL') const Icon(Icons.luggage, size: 12),
              ],
            ),
            Text(
              statusLabel(cell['status'] as String?),
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _faultDialog(Map<String, dynamic> cell) async {
    final isFault = cell['status'] == 'FAULT';
    final reasonCtrl = TextEditingController(text: 'Hỏng khóa');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isFault
              ? 'Ô #${cell['boxNumber']} đã sửa xong?'
              : 'Báo hỏng ô #${cell['boxNumber']}?',
        ),
        content: isFault
            ? Text('Lý do trước đó: ${cell['faultReason'] ?? '-'}')
            : TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Lý do'),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isFault ? 'Mở lại ô' : 'Báo hỏng'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      if (isFault) {
        await _service.clearFault(cell['id'] as int);
      } else {
        await _service.reportFault(cell['id'] as int, reasonCtrl.text.trim());
      }
      await _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    }
  }

  // ---- Tab 3: orders ----
  Widget _buildOrders() {
    const filters = [
      '',
      'INITIALIZED',
      'STORING',
      'RETURNED',
      'EXPIRED',
      'COMPLETED',
      'CANCELED',
    ];
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final f in filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.isEmpty ? 'Tất cả' : statusLabel(f)),
                    selected: _orderFilter == f,
                    onSelected: (_) async {
                      setState(() => _orderFilter = f);
                      final orders = await _service.managerOrders(status: f);
                      if (mounted) setState(() => _orders = orders);
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final o = _orders[i];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    dense: true,
                    onTap: () => _orderStatusSheet(o),
                    title: Text(
                      '${typeLabel(o['type'] as String?)} · ${o['orderCode'] ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      'KH #${o['userId']} · tủ ${o['lockerId'] ?? '-'} · ${o['totalPrice'] ?? 0}đ',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: StatusChip(o['status'] as String?),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Đổi trạng thái đơn ở mức Manager — trước đây tab này read-only và chỉ
  /// Admin thao tác được (gap điểm 6 file 04).
  Future<void> _orderStatusSheet(Map<String, dynamic> o) async {
    final orderId = (o['id'] as num?)?.toInt();
    if (orderId == null) return;

    const statuses = [
      'INITIALIZED',
      'STORING',
      'RETURNED',
      'EXPIRED',
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
                  '${typeLabel(o['type'] as String?)} · ${o['orderCode'] ?? '#$orderId'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: opsDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'KH #${o['userId']} · tủ ${o['lockerId'] ?? '-'} · ${o['totalPrice'] ?? 0}đ',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Đổi trạng thái',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in statuses)
                      ChoiceChip(
                        label: Text(statusLabel(s)),
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
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      try {
                        await _service.managerSetOrderStatus(
                          orderId,
                          selected,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã đổi trạng thái đơn ${o['orderCode'] ?? '#$orderId'} → ${statusLabel(selected)}',
                            ),
                          ),
                        );
                        await _loadAll();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(LockerOpsService.errorMessage(e)),
                          ),
                        );
                      }
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

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}
