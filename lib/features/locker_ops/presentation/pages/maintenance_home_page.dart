import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
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
  late final TabController _tabs = TabController(length: 2, vsync: this);

  List<Map<String, dynamic>> _faults = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _myReports = [];
  bool _loading = true;
  String? _myUserId;

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
      if (!mounted) return;
      setState(() {
        _faults = faults;
        _reports = reports;
        _myReports = mine;
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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
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
              children: [_buildQueue(), _buildMine()],
            ),
    );
  }

  Widget _buildQueue() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
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
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber,
                    color: Color(0xFFDC2626),
                  ),
                  title: Text(
                    '${f['lockerName'] ?? 'Tủ ${f['lockerId']}'} · Ô #${f['boxNumber']} (${f['cellType']})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    f['faultReason'] as String? ?? 'Không rõ lý do',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton(
                    onPressed: () => _run(
                      () => _service.clearFault(f['boxId'] as int),
                      'Ô đã hoạt động lại',
                    ),
                    child: const Text('Đã sửa'),
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
                  'Không có phiếu nào 🎉',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          for (final r in _reports) _reportCard(r),
        ],
      ),
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
              '${r['description'] ?? ''}\nTủ ${r['lockerId']}'
              '${r['boxId'] != null ? ' · ô ${r['boxId']}' : ''}'
              '${r['assignedToUserId'] != null ? ' · KTV #${r['assignedToUserId']}${assignedToMe ? ' (bạn)' : ''}' : ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}
