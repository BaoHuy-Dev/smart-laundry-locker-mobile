import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// Home for the TECHNICIAN role: IoT device list, device detail + audit logs,
/// and device control panel (restart / status change).
class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage>
    with SingleTickerProviderStateMixin {
  final _service = LockerOpsService();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  List<Map<String, dynamic>> _devices = [];
  Map<String, dynamic>? _selectedDevice;
  List<Map<String, dynamic>> _deviceLogs = [];
  int? _selectedDeviceId;

  bool _loading = true;
  bool _detailLoading = false;
  bool _controlBusy = false;

  String? _devicesError;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);
    try {
      final data = await _service.techDevices();
      if (!mounted) return;
      setState(() {
        _devices = data;
        _devicesError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _devicesError = LockerOpsService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadDeviceDetail(int id) async {
    setState(() {
      _selectedDeviceId = id;
      _detailLoading = true;
      _detailError = null;
      _selectedDevice = null;
      _deviceLogs = [];
    });
    try {
      final detail = await _service.techDeviceDetail(id);
      final logs = await _service.techDeviceLogs(id);
      if (!mounted) return;
      setState(() {
        _selectedDevice = detail;
        _deviceLogs = logs;
        _detailError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _detailError = LockerOpsService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _detailLoading = false);
    }
  }

  Future<void> _logout() async {
    await TokenService.clearTokens();
    if (mounted) context.go('/onboarding');
  }

  Future<void> _restartDevice() async {
    final id = _selectedDeviceId;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restart thiết bị'),
        content: Text(
          'Thiết bị "${_selectedDevice?['name'] ?? '#$id'}" sẽ được restart. Xác nhận tiếp tục?',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _controlBusy = true);
    try {
      await _service.techRestartDevice(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lệnh restart thiết bị')),
        );
        await _loadDeviceDetail(id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _controlBusy = false);
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    final id = _selectedDeviceId;
    if (id == null) return;
    setState(() => _controlBusy = true);
    try {
      await _service.techUpdateStatus(id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái: $newStatus')),
        );
        await _loadDeviceDetail(id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _controlBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Kỹ thuật viên IoT'),
        backgroundColor: opsDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Thiết bị'),
            Tab(text: 'Chi tiết'),
            Tab(text: 'Điều khiển'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: opsPrimary))
          : TabBarView(
              controller: _tabs,
              children: [
                _buildDevices(),
                _buildDetail(),
                _buildControl(),
              ],
            ),
    );
  }

  // ---- Tab 0: Danh sách thiết bị ----
  Widget _buildDevices() {
    if (_devicesError != null) {
      return _apiNotReadyBanner(_devicesError!);
    }
    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const OpsSectionLabel(
            'Thiết bị IoT',
            icon: Icons.device_hub_outlined,
          ),
          if (_devices.isEmpty)
            const OpsEmptyState(
              icon: Icons.device_hub_outlined,
              title: 'Không có thiết bị nào',
              subtitle: 'Chưa có thiết bị IoT nào được phân công.',
            )
          else
            for (final device in _devices)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpsCard(
                  onTap: () {
                    final id = _asInt(device['id']);
                    if (id != null) {
                      _loadDeviceDetail(id);
                      // Switch to detail tab
                      _tabs.animateTo(1);
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              _deviceStatusColor(device['status'] as String?)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.router_outlined,
                          color: _deviceStatusColor(
                            device['status'] as String?,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${device['name'] ?? 'Thiết bị #${device['id']}'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: opsDark,
                              ),
                            ),
                            if ((device['model'] ?? '').toString().isNotEmpty)
                              Text(
                                device['model'].toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: opsMutedText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _DeviceStatusBadge(device['status'] as String?),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          const OpsBanner(
            tone: OpsBannerTone.info,
            icon: Icons.touch_app_outlined,
            text: 'Chạm vào thiết bị để xem chi tiết và điều khiển.',
          ),
        ],
      ),
    );
  }

  // ---- Tab 1: Chi tiết thiết bị ----
  Widget _buildDetail() {
    if (_selectedDeviceId == null) {
      return const OpsEmptyState(
        icon: Icons.device_hub_outlined,
        title: 'Chưa chọn thiết bị',
        subtitle: 'Chọn thiết bị ở tab Thiết bị để xem chi tiết.',
      );
    }
    if (_detailLoading) {
      return const Center(
        child: CircularProgressIndicator(color: opsPrimary),
      );
    }
    if (_detailError != null) {
      return _apiNotReadyBanner(_detailError!);
    }
    final device = _selectedDevice;
    if (device == null) {
      return const OpsEmptyState(
        icon: Icons.device_hub_outlined,
        title: 'Không tải được thiết bị',
      );
    }

    final logs = _deviceLogs;
    return RefreshIndicator(
      onRefresh: () => _loadDeviceDetail(_selectedDeviceId!),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OpsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.router_outlined, color: opsPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${device['name'] ?? 'Thiết bị #${device['id']}'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: opsDark,
                        ),
                      ),
                    ),
                    _DeviceStatusBadge(device['status'] as String?),
                  ],
                ),
                const SizedBox(height: 12),
                for (final field in [
                  'model',
                  'firmwareVersion',
                  'ipAddress',
                  'macAddress',
                  'location',
                  'lastSeen',
                ])
                  if (device[field] != null && '${device[field]}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            _fieldLabel(field),
                            style: const TextStyle(
                              fontSize: 13,
                              color: opsMutedText,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${device[field]}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: opsDark,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const OpsSectionLabel(
            'Nhật ký hoạt động',
            icon: Icons.history_edu_outlined,
          ),
          if (logs.isEmpty)
            const OpsEmptyState(
              icon: Icons.history_edu_outlined,
              title: 'Chưa có nhật ký',
              subtitle: 'Các sự kiện của thiết bị sẽ xuất hiện ở đây.',
            )
          else
            for (final log in logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: opsSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: opsBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: opsPrimary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${log['message'] ?? log['event'] ?? log['action'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: opsDark,
                              ),
                            ),
                            if (log['createdAt'] != null)
                              Text(
                                _fmtDate(log['createdAt']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: opsMutedText,
                                ),
                              ),
                          ],
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

  // ---- Tab 2: Điều khiển ----
  Widget _buildControl() {
    if (_selectedDeviceId == null) {
      return const OpsEmptyState(
        icon: Icons.settings_remote_outlined,
        title: 'Chưa chọn thiết bị',
        subtitle: 'Chọn thiết bị ở tab Thiết bị để điều khiển.',
      );
    }

    final currentStatus =
        (_selectedDevice?['status'] as String?) ?? 'ONLINE';
    const statuses = ['ONLINE', 'OFFLINE', 'ERROR'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const OpsSectionLabel(
          'Điều khiển thiết bị',
          icon: Icons.settings_remote_outlined,
        ),
        OpsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thay đổi trạng thái',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: opsDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: [
                  for (final s in statuses)
                    ChoiceChip(
                      label: Text(s),
                      selected: currentStatus == s,
                      selectedColor:
                          _deviceStatusColor(s).withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: currentStatus == s
                            ? _deviceStatusColor(s)
                            : opsMutedText,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: _controlBusy
                          ? null
                          : (selected) {
                              if (selected) _changeStatus(s);
                            },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OpsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thao tác',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: opsDark,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _controlBusy ? null : _restartDevice,
                  icon: _controlBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Restart thiết bị'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const OpsBanner(
          tone: OpsBannerTone.warning,
          icon: Icons.warning_amber_outlined,
          text:
              'Restart thiết bị sẽ ngắt kết nối IoT tạm thời. Đảm bảo không có lệnh đang chờ thực thi trước khi restart.',
        ),
      ],
    );
  }

  Widget _apiNotReadyBanner(String errorMsg) {
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
          text: isNotReady ? 'Tính năng đang được kích hoạt' : errorMsg,
        ),
      ),
    );
  }

  Color _deviceStatusColor(String? status) => switch (status) {
        'ONLINE' => const Color(0xFF16A34A),
        'OFFLINE' => const Color(0xFF6B7280),
        'ERROR' => const Color(0xFFEA580C),
        _ => opsMutedText,
      };

  String _fieldLabel(String key) => switch (key) {
        'model' => 'Model',
        'firmwareVersion' => 'Firmware',
        'ipAddress' => 'IP',
        'macAddress' => 'MAC',
        'location' => 'Vị trí',
        'lastSeen' => 'Lần cuối thấy',
        _ => key,
      };

  String _fmtDate(dynamic value) {
    final d = DateTime.tryParse('$value')?.toLocal();
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)} ${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

/// Compact status badge for IoT devices (ONLINE/OFFLINE/ERROR).
class _DeviceStatusBadge extends StatelessWidget {
  const _DeviceStatusBadge(this.status);
  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'ONLINE' => const Color(0xFF16A34A),
      'OFFLINE' => const Color(0xFF6B7280),
      'ERROR' => const Color(0xFFEA580C),
      _ => opsMutedText,
    };
    final label = switch (status) {
      'ONLINE' => 'Online',
      'OFFLINE' => 'Offline',
      'ERROR' => 'Lỗi',
      _ => status ?? '',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
