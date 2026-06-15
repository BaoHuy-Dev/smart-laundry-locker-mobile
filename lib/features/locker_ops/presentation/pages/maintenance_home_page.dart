import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/utils/locker_maps.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// Home for the MAINTENANCE role: live fault cells and the work queue
/// (claim a ticket, mark it resolved — the cell goes back into service).
class MaintenanceHomePage extends StatefulWidget {
  const MaintenanceHomePage({super.key});

  @override
  State<MaintenanceHomePage> createState() => _MaintenanceHomePageState();
}

class _MaintenanceHomePageState extends State<MaintenanceHomePage>
    with SingleTickerProviderStateMixin {
  final _service = LockerOpsService();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  List<Map<String, dynamic>> _faults = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _myReports = [];
  bool _loading = true;
  String? _myUserId;

  // Inspection tab state
  List<Map<String, dynamic>> _lockers = [];
  int? _selectedLockerId;
  Map<String, dynamic>? _layout;
  bool _layoutLoading = false;

  List<Map<String, dynamic>> get _lockerOptions => _lockers
      .where((locker) => _asInt(locker['id']) != null)
      .toList(growable: false);

  Map<String, dynamic>? get _selectedLocker {
    final selectedId = _selectedLockerId;
    if (selectedId == null) return null;
    for (final locker in _lockerOptions) {
      if (_asInt(locker['id']) == selectedId) return locker;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _myUserId = await TokenService.getUserId();
      final faults = await _service.faults();
      final reports = await _service.reports();
      final mine = await _service.reports(mine: true);
      final lockers = await _service.lockers();
      if (!mounted) return;
      setState(() {
        _faults = faults;
        _reports = reports;
        _myReports = mine;
        _lockers = lockers;
      });
      final validSelected = lockers.any(
        (locker) => _asInt(locker['id']) == _selectedLockerId,
      );
      final firstId = lockers.isNotEmpty ? _asInt(lockers.first['id']) : null;
      final nextSelectedId = validSelected ? _selectedLockerId : firstId;
      if (nextSelectedId == null) {
        setState(() {
          _selectedLockerId = null;
          _layout = null;
        });
      } else {
        await _selectLocker(nextSelectedId);
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

  Future<void> _selectLocker(int lockerId) async {
    setState(() {
      _selectedLockerId = lockerId;
      _layoutLoading = true;
    });
    try {
      final layout = await _service.layout(lockerId);
      if (!mounted) return;
      setState(() => _layout = layout);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _layoutLoading = false);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok)));
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

  Future<void> _openDirections(Map<String, dynamic> item) async {
    final opened = await openLockerDirections(
      latitude: _asDouble(item['lockerLatitude'] ?? item['latitude']),
      longitude: _asDouble(item['lockerLongitude'] ?? item['longitude']),
      address: (item['lockerAddress'] ?? item['address'])?.toString(),
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tủ này chưa có vị trí để chỉ đường.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _reports.where((r) => r['status'] != 'RESOLVED').length;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Đội bảo trì'),
        backgroundColor: const Color(0xFF7F1D1D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            const Tab(text: 'Kiểm tra tủ'),
            Tab(text: 'Sự cố ($openCount)'),
            Tab(
              text:
                  'Việc của tôi (${_myReports.where((r) => r['status'] == 'IN_PROGRESS').length})',
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [_buildInspect(), _buildQueue(), _buildMine()],
            ),
    );
  }

  // ---- Tab 1: inspect lockers (browse cabinet, see cell status, report/clear) ----
  Widget _buildInspect() {
    final cells =
        (_layout?['cells'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final lockerOptions = _lockerOptions;
    final selectedLocker = _selectedLocker;
    final rows = <int, List<Map<String, dynamic>>>{};
    for (final c in cells) {
      rows.putIfAbsent(_asInt(c['rowIndex']) ?? 0, () => []).add(c);
    }
    final sortedRows = rows.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final selectedValue =
        lockerOptions.any((locker) => _asInt(locker['id']) == _selectedLockerId)
        ? _selectedLockerId
        : null;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chọn tủ để kiểm tra',
            style: TextStyle(fontWeight: FontWeight.w800, color: opsDark),
          ),
          const SizedBox(height: 8),
          if (lockerOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Chưa có tủ nào',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            DropdownButtonFormField<int>(
              initialValue: selectedValue,
              isExpanded: true,
              items: [
                for (final l in lockerOptions)
                  DropdownMenuItem(
                    value: _asInt(l['id']),
                    child: Text(
                      '${l['name'] ?? l['code'] ?? 'Tủ'} (${l['code'] ?? ''})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) _selectLocker(v);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (selectedLocker != null) ...[
            _selectedLockerCard(selectedLocker, cells),
            const SizedBox(height: 12),
          ],
          if (_layoutLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_layout != null) ...[
            _layoutSummary(),
            const SizedBox(height: 8),
            _statusLegend(),
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
                    Expanded(
                      child: Text(
                        'Bãi đáp drone trên nóc · marker ${_layout?['landingMarkerId'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C3AED),
                        ),
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
                  for (final c in _sortCellsByColumn(row.value))
                    Expanded(child: _cellTile(c)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            const Text(
              'Chạm vào một ô để báo hỏng hoặc mở lại ô sau khi sửa.',
              style: TextStyle(fontSize: 12, color: opsMutedText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _selectedLockerCard(
    Map<String, dynamic> locker,
    List<Map<String, dynamic>> cells,
  ) {
    final status = locker['status']?.toString();
    final address = locker['address']?.toString();
    final reserved = _countCells(cells, 'RESERVED');
    final occupied = _countCells(cells, 'OCCUPIED');
    final hasLocation =
        _asDouble(locker['latitude']) != null ||
        (address != null && address.trim().isNotEmpty);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: opsBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: opsPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${locker['name'] ?? 'Tủ'} · ${locker['code'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: opsDark,
                    ),
                  ),
                ),
                StatusChip(status),
              ],
            ),
            if (address != null && address.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: opsMutedText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 12, color: opsMutedText),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniPill(
                  icon: Icons.event_available_outlined,
                  text: 'Đã giữ chỗ: $reserved',
                  color: statusColor('RESERVED'),
                ),
                _MiniPill(
                  icon: Icons.inventory_outlined,
                  text: 'Có đồ: $occupied',
                  color: statusColor('OCCUPIED'),
                ),
                _MiniPill(
                  icon: Icons.grid_view_outlined,
                  text:
                      'STANDARD ${_countCells(cells, 'STANDARD', field: 'cellType')}',
                ),
                _MiniPill(
                  icon: Icons.luggage_outlined,
                  text: 'XL ${_countCells(cells, 'XL', field: 'cellType')}',
                ),
                _MiniPill(
                  icon: Icons.flight_takeoff,
                  text:
                      'DRONE ${_countCells(cells, 'DRONE', field: 'cellType')}',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kiểm tra trực quan từng ô rồi chỉ báo hỏng khi xác nhận lỗi vật lý tại tủ.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                TextButton.icon(
                  onPressed: hasLocation ? () => _openDirections(locker) : null,
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Chỉ đường'),
                ),
              ],
            ),
          ],
        ),
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

  Widget _statusLegend() {
    const items = <String>[
      'AVAILABLE',
      'RESERVED',
      'OCCUPIED',
      'FAULT',
      'OUT_OF_SERVICE',
      'CLEANING',
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        for (final s in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor(s),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statusLabel(s),
                style: const TextStyle(fontSize: 11, color: opsMutedText),
              ),
            ],
          ),
      ],
    );
  }

  Widget _cellTile(Map<String, dynamic> cell) {
    final color = statusColor(cell['status'] as String?);
    final type = cell['cellType'] as String? ?? 'STANDARD';
    return GestureDetector(
      onTap: () => _cellActions(cell),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
            Text(
              _cellTypeLabel(type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: opsMutedText),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet hành động cho 1 ô, tuỳ theo trạng thái hiện tại của ô.
  Future<void> _cellActions(Map<String, dynamic> cell) async {
    final boxId = _asInt(cell['id']);
    if (boxId == null) return;
    final status = cell['status'] as String? ?? 'AVAILABLE';
    final color = statusColor(status);
    final reason = cell['faultReason'] as String?;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        Widget tile(IconData icon, String label, Color c, VoidCallback onTap) {
          return ListTile(
            leading: Icon(icon, color: c),
            title: Text(
              label,
              style: TextStyle(color: c, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(sheetCtx);
              onTap();
            },
          );
        }

        final actions = <Widget>[];
        switch (status) {
          case 'FAULT':
            actions.add(tile(
              Icons.check_circle,
              'Đã sửa xong — mở lại ô',
              const Color(0xFF16A34A),
              () => _runCellAction(
                () => _service.clearFault(boxId),
                'Ô đã hoạt động lại',
              ),
            ));
            break;
          case 'OUT_OF_SERVICE':
          case 'CLEANING':
            actions.add(tile(
              Icons.restart_alt,
              status == 'CLEANING' ? 'Hoàn tất vệ sinh' : 'Khôi phục ô',
              const Color(0xFF16A34A),
              () => _runCellAction(
                () => _service.returnToService(boxId),
                'Ô đã hoạt động lại',
              ),
            ));
            break;
          case 'OCCUPIED':
          case 'RESERVED':
            actions.add(tile(
              Icons.report_problem,
              'Báo hỏng ô',
              const Color(0xFFDC2626),
              () => _reportFaultFlow(cell),
            ));
            break;
          default: // AVAILABLE và các trạng thái khác
            actions.add(tile(
              Icons.report_problem,
              'Báo hỏng ô',
              const Color(0xFFDC2626),
              () => _reportFaultFlow(cell),
            ));
            actions.add(tile(
              Icons.do_not_disturb_on,
              'Ngưng dùng ô',
              const Color(0xFF6B7280),
              () => _outOfServiceFlow(cell),
            ));
            actions.add(tile(
              Icons.cleaning_services,
              'Đánh dấu đang vệ sinh',
              const Color(0xFF0891B2),
              () => _runCellAction(
                () => _service.cleaning(boxId),
                'Ô đang vệ sinh',
              ),
            ));
        }

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${cell['boxNumber']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  'Ô #${cell['boxNumber']} · ${_cellTypeLabel(cell['cellType'] as String?)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Trạng thái: ${statusLabel(status)}'
                  '${(reason != null && reason.isNotEmpty) ? ' · $reason' : ''}',
                ),
              ),
              const Divider(height: 1),
              ...actions,
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Chạy 1 thao tác đổi trạng thái ô + báo kết quả + reload danh sách.
  Future<void> _runCellAction(
    Future<dynamic> Function() action,
    String successMsg,
  ) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(successMsg)));
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

  /// Dialog nhập lý do rồi báo hỏng ô.
  Future<void> _reportFaultFlow(Map<String, dynamic> cell) async {
    final boxId = _asInt(cell['id']);
    if (boxId == null) return;
    final reasonCtrl = TextEditingController(text: 'Hỏng khóa');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Báo hỏng ô #${cell['boxNumber']}'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Lý do hỏng'),
          minLines: 1,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Báo hỏng'),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (ok != true) return;
    if (reason.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập lý do hỏng.')),
        );
      }
      return;
    }
    await _runCellAction(
      () => _service.reportFault(boxId, reason),
      'Đã báo hỏng ô',
    );
  }

  /// Dialog xác nhận (lý do tuỳ chọn) rồi ngưng dùng ô.
  Future<void> _outOfServiceFlow(Map<String, dynamic> cell) async {
    final boxId = _asInt(cell['id']);
    if (boxId == null) return;
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ngưng dùng ô #${cell['boxNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ô sẽ bị loại khỏi phân phối cho khách tới khi được khôi phục.',
              style: TextStyle(fontSize: 12, color: opsMutedText),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Lý do (tùy chọn)'),
              minLines: 1,
              maxLines: 3,
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
              backgroundColor: const Color(0xFF6B7280),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ngưng dùng'),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (ok != true) return;
    await _runCellAction(
      () => _service.outOfService(boxId, reason: reason.isEmpty ? null : reason),
      'Đã ngưng dùng ô',
    );
  }

  /// Mở nhật ký xử lý (work-log) của 1 phiếu để xem + thêm ghi chú tiến trình.
  Future<void> _reportLogSheet(Map<String, dynamic> report) async {
    final reportId = _asInt(report['id']);
    if (reportId == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RepairLogSheet(
        reportId: reportId,
        service: _service,
        title: '#${report['id']} · ${report['title'] ?? ''}',
      ),
    );
    if (mounted) await _load();
  }

  Widget _buildQueue() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildShiftSummary(),
          const SizedBox(height: 12),
          if (_faults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Ô đang lỗi vật lý',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final f in _faults)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${f['lockerName'] ?? 'Tủ ${f['lockerId']}'} · Ô #${f['boxNumber']} (${f['cellType']})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          StatusChip('FAULT'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        f['faultReason'] as String? ?? 'Không rõ lý do',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if ((f['lockerAddress'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: opsMutedText,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  f['lockerAddress'].toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: opsMutedText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed: () => _openDirections(f),
                            icon: const Icon(Icons.map_outlined, size: 16),
                            label: const Text('Chỉ đường'),
                          ),
                          TextButton(
                            onPressed: () => _run(
                              () => _service.clearFault(f['boxId'] as int),
                              'Ô đã hoạt động lại',
                            ),
                            child: const Text('Đã sửa'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 32),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Phiếu sự cố',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (_reports.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Không có phiếu nào',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          for (final r in _reports) _reportCard(r),
        ],
      ),
    );
  }

  Widget _buildShiftSummary() {
    final open = _reports.where((r) => r['status'] == 'OPEN').length;
    final inProgress = _reports
        .where((r) => r['status'] == 'IN_PROGRESS')
        .length;
    final mineActive = _myReports
        .where((r) => r['status'] != 'RESOLVED')
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng quan ca trực',
          style: TextStyle(fontWeight: FontWeight.w800, color: opsDark),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Ô lỗi',
                value: '${_faults.length}',
                color: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: 'Phiếu mới',
                value: '$open',
                color: const Color(0xFFEA580C),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: 'Đang xử lý',
                value: '$inProgress',
                color: const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: 'Của tôi',
                value: '$mineActive',
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const OpsBanner(
          text:
              'Quy trình chuẩn: kiểm tra vị trí tủ, nhận phiếu, tới đúng ô, xác nhận sửa vật lý rồi hoàn tất để clear fault.',
          icon: Icons.engineering,
          tone: OpsBannerTone.info,
        ),
      ],
    );
  }

  Widget _buildMine() {
    final active = _myReports.where((r) => r['status'] != 'RESOLVED').toList();
    final done = _myReports.where((r) => r['status'] == 'RESOLVED').toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (active.isEmpty && done.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Bạn chưa nhận việc nào',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          for (final r in active) _reportCard(r),
          if (done.isNotEmpty) ...[
            const Divider(height: 32),
            const Text(
              'Đã hoàn thành',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final r in done) _reportCard(r),
          ],
        ],
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> r) {
    final status = r['status'] as String? ?? '';
    final assignedToMe = '${r['assignedToUserId'] ?? ''}' == (_myUserId ?? '');
    final lockerLabel = r['lockerName'] ?? 'Tủ ${r['lockerId']}';
    final boxLabel = r['boxNumber'] ?? r['boxId'];
    final createdAt = _parseDate(r['createdAt']);
    final ageLabel = createdAt == null ? null : _ageLabel(createdAt);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${r['id']} · ${r['title'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                StatusChip(status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${r['description'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MiniPill(
                  icon: Icons.inventory_2_outlined,
                  text:
                      '$lockerLabel${boxLabel != null ? ' · ô $boxLabel' : ''}',
                ),
                if ((r['cellType'] ?? '').toString().isNotEmpty)
                  _MiniPill(
                    icon: Icons.grid_view_outlined,
                    text: r['cellType'].toString(),
                  ),
                if (ageLabel != null)
                  _MiniPill(
                    icon: Icons.schedule,
                    text: ageLabel,
                    color: _slaColor(createdAt!),
                  ),
                if (r['assignedToUserId'] != null)
                  _MiniPill(
                    icon: Icons.engineering_outlined,
                    text:
                        'KTV #${r['assignedToUserId']}${assignedToMe ? ' (bạn)' : ''}',
                  ),
              ],
            ),
            if ((r['lockerAddress'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: opsMutedText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      r['lockerAddress'].toString(),
                      style: const TextStyle(fontSize: 12, color: opsMutedText),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _openDirections(r),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Chỉ đường'),
                ),
                TextButton.icon(
                  onPressed: () => _reportLogSheet(r),
                  icon: const Icon(Icons.history_edu_outlined, size: 16),
                  label: const Text('Nhật ký'),
                ),
                if (status == 'OPEN')
                  TextButton.icon(
                    onPressed: () => _run(
                      () => _service.claimReport(r['id'] as int),
                      'Đã nhận việc',
                    ),
                    icon: const Icon(Icons.pan_tool_alt, size: 16),
                    label: const Text('Nhận việc'),
                  ),
                if (status != 'RESOLVED')
                  ElevatedButton.icon(
                    onPressed: () => _run(
                      () => _service.resolveReport(r['id'] as int),
                      'Đã xử lý xong — ô hoạt động lại',
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Hoàn tất'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse('$value')?.toLocal();
  }

  String _ageLabel(DateTime createdAt) {
    final age = DateTime.now().difference(createdAt);
    if (age.inDays > 0) return 'Mở ${age.inDays} ngày';
    if (age.inHours > 0) return 'Mở ${age.inHours} giờ';
    if (age.inMinutes > 0) return 'Mở ${age.inMinutes} phút';
    return 'Vừa mở';
  }

  Color _slaColor(DateTime createdAt) {
    final age = DateTime.now().difference(createdAt);
    if (age.inHours >= 4) return const Color(0xFFDC2626);
    if (age.inHours >= 1) return const Color(0xFFD97706);
    return opsPrimary;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

/// Bottom sheet xem + thêm nhật ký xử lý (work-log) cho một phiếu bảo trì.
class _RepairLogSheet extends StatefulWidget {
  const _RepairLogSheet({
    required this.reportId,
    required this.service,
    required this.title,
  });

  final int reportId;
  final LockerOpsService service;
  final String title;

  @override
  State<_RepairLogSheet> createState() => _RepairLogSheetState();
}

class _RepairLogSheetState extends State<_RepairLogSheet> {
  final _noteCtrl = TextEditingController();
  List<Map<String, dynamic>> _logs = const [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final logs = await widget.service.reportLogs(widget.reportId);
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.service.addReportLog(widget.reportId, note);
      _noteCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _fmt(dynamic value) {
    final d = DateTime.tryParse('$value')?.toLocal();
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)} ${two(d.day)}/${two(d.month)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_edu_outlined,
                    size: 18,
                    color: opsMutedText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nhật ký xử lý · ${widget.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _logs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Chưa có ghi chú nào. Thêm bước xử lý đầu tiên bên dưới.',
                        style: TextStyle(color: opsMutedText),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final log = _logs[i];
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${log['note'] ?? ''}'),
                              const SizedBox(height: 4),
                              Text(
                                '${_fmt(log['createdAt'])}'
                                '${log['actorUserId'] != null ? ' · KTV #${log['actorUserId']}' : ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: opsMutedText,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteCtrl,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Thêm bước xử lý / ghi chú...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _add,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
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

double? _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

List<Map<String, dynamic>> _sortCellsByColumn(
  List<Map<String, dynamic>> cells,
) {
  final sorted = [...cells];
  sorted.sort(
    (a, b) =>
        (_asInt(a['colIndex']) ?? 0).compareTo(_asInt(b['colIndex']) ?? 0),
  );
  return sorted;
}

int _countCells(
  List<Map<String, dynamic>> cells,
  String expected, {
  String field = 'status',
}) => cells
    .where((cell) => cell[field]?.toString().toUpperCase() == expected)
    .length;

String _cellTypeLabel(String? type) => switch (type) {
  'DRONE' => 'Drone',
  'XL' => 'XL',
  'STANDARD' => 'Chuẩn',
  null => 'Chuẩn',
  _ => type,
};

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

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.icon,
    required this.text,
    this.color = opsPrimary,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
