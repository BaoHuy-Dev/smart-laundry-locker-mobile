import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/utils/locker_maps.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// All locker orders of the signed-in customer, with the full action set gated
/// to the backend state machine: confirm drop, pickup/complete, delegate,
/// extend/end rental, report fault, cancel.
class MyLockerOrdersPage extends StatefulWidget {
  const MyLockerOrdersPage({super.key});

  @override
  State<MyLockerOrdersPage> createState() => _MyLockerOrdersPageState();
}

class _MyLockerOrdersPageState extends State<MyLockerOrdersPage> {
  final _service = LockerOpsService();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _filter = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final orders = await _service.myOrders();
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      _snack(LockerOpsService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _visible {
    const done = {'COMPLETED', 'CANCELED'};
    return _orders.where((o) {
      final status = o['status'] as String? ?? '';
      return _filter == 'ACTIVE'
          ? !done.contains(status)
          : done.contains(status);
    }).toList();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _runAction(
    Future<Map<String, dynamic>> Function() fn,
    String ok,
  ) async {
    try {
      await fn();
      _snack(ok);
      await _load();
    } catch (e) {
      _snack(LockerOpsService.errorMessage(e));
    }
  }

  Future<void> _delegateDialog(int orderId) async {
    final phoneCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ủy quyền lấy hộ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Người được ủy quyền sẽ nhận PIN mới để mở ô.',
              style: TextStyle(fontSize: 13, color: opsMutedText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'SĐT người lấy hộ',
                prefixIcon: Icon(LucideIcons.phone, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên (tùy chọn)',
                prefixIcon: Icon(LucideIcons.idCard, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ủy quyền'),
          ),
        ],
      ),
    );
    if (confirmed == true && phoneCtrl.text.trim().isNotEmpty) {
      await _runAction(
        () => _service.delegate(
          orderId,
          phone: phoneCtrl.text.trim(),
          name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
        ),
        'Đã ủy quyền — PIN mới được gửi cho người lấy hộ',
      );
    }
  }

  Future<void> _extendDialog(int orderId) async {
    var hours = 2.0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Gia hạn thuê'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thêm ${hours.round()} giờ',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: opsDark,
                ),
              ),
              Slider(
                value: hours,
                min: 1,
                max: 24,
                divisions: 23,
                activeColor: opsPrimary,
                label: '${hours.round()}h',
                onChanged: (v) => setSheet(() => hours = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Gia hạn'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await _runAction(
        () => _service.extendRental(orderId, hours.round()),
        'Đã gia hạn ${hours.round()} giờ',
      );
    }
  }

  Future<void> _reportDialog(int boxId) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Báo ô lỗi'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Mô tả sự cố (ô không mở, kẹt cửa...)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Gửi báo lỗi'),
          ),
        ],
      ),
    );
    if (confirmed == true && reasonCtrl.text.trim().isNotEmpty) {
      await _runAction(
        () => _service.reportFault(boxId, reasonCtrl.text.trim()),
        'Đã gửi báo lỗi — đội bảo trì sẽ xử lý',
      );
    }
  }

  Future<void> _openLockerDirections(Map<String, dynamic> order) async {
    final lockerId = _asInt(order['lockerId']);
    if (lockerId == null) {
      _snack('Đơn chưa có thông tin tủ.');
      return;
    }
    try {
      final locker = await _service.locker(lockerId);
      final opened = await openLockerDirections(
        latitude: _asDouble(locker['latitude']),
        longitude: _asDouble(locker['longitude']),
        address: locker['address']?.toString(),
      );
      if (!opened) _snack('Tủ chưa có vị trí để chỉ đường.');
    } catch (e) {
      _snack(LockerOpsService.errorMessage(e));
    }
  }

  void _openDetail(Map<String, dynamic> order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.95,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: _DetailSheet(
            order: order,
            onConfirmDrop: (id) async {
              Navigator.pop(ctx);
              await _runAction(
                () => _service.confirmDrop(id),
                'Đã xác nhận bỏ đồ',
              );
            },
            onComplete: (id) async {
              Navigator.pop(ctx);
              await _runAction(
                () => _service.completePickup(id),
                'Đã nhận đồ — đơn hoàn tất',
              );
            },
            onEndRental: (id) async {
              Navigator.pop(ctx);
              await _runAction(
                () => _service.endRental(id),
                'Đã kết thúc kỳ thuê',
              );
            },
            onDelegate: (id) async {
              Navigator.pop(ctx);
              await _delegateDialog(id);
            },
            onExtend: (id) async {
              Navigator.pop(ctx);
              await _extendDialog(id);
            },
            onReport: (boxId) async {
              Navigator.pop(ctx);
              await _reportDialog(boxId);
            },
            onCancel: (id) async {
              Navigator.pop(ctx);
              await _runAction(() => _service.cancelOrder(id), 'Đã hủy đơn');
            },
            onDirections: () => _openLockerDirections(order),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AISLShadcnTheme.navySurface,
      appBar: AppBar(
        title: const Text('Đơn tủ của tôi'),
        backgroundColor: AISLShadcnTheme.navyPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(LucideIcons.refreshCw)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _filterChip('ACTIVE', 'Đang hoạt động'),
                const SizedBox(width: 8),
                _filterChip('DONE', 'Đã xong'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _visible.isEmpty
                ? OpsEmptyState(
                    icon: _filter == 'ACTIVE'
                        ? LucideIcons.packageOpen
                        : LucideIcons.packageCheck,
                    title: _filter == 'ACTIVE'
                        ? 'Chưa có đơn đang hoạt động'
                        : 'Chưa có đơn đã xong',
                    subtitle: _filter == 'ACTIVE'
                        ? 'Tạo đơn Gửi hàng hoặc Thuê tủ từ màn hình chính.'
                        : null,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        return _OrderCard(
                          order: _visible[i],
                          onTap: () => _openDetail(_visible[i]),
                        ).animate().fadeIn(
                          delay: (i * 35).ms,
                          duration: 220.ms,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: opsPrimary,
      side: BorderSide(color: selected ? opsPrimary : opsBorder),
      labelStyle: TextStyle(
        color: selected ? Colors.white : opsMutedText,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

/// Compact order row card.
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = order['type'] as String?;
    final status = order['status'] as String?;
    final boxId = order['sendBoxId'] ?? order['receiveBoxId'];
    final deadline = order['pickupDeadline'];
    final overdue =
        isOverdue(deadline) && status != 'COMPLETED' && status != 'CANCELED';
    final color = statusColor(status);

    return OpsCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(typeIcon(type), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      typeLabel(type),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: opsDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${order['orderCode'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: opsMutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.grid3x3,
                      size: 13,
                      color: opsMutedText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tủ ${order['lockerId'] ?? '-'} · ô ${boxId ?? '-'}',
                      style: const TextStyle(fontSize: 12, color: opsMutedText),
                    ),
                  ],
                ),
                if (deadline != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        overdue ? LucideIcons.triangleAlert : LucideIcons.clock,
                        size: 13,
                        color: overdue ? const Color(0xFFDC2626) : opsMutedText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fmtRemaining(deadline),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: overdue
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: overdue
                              ? const Color(0xFFDC2626)
                              : opsMutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(status),
              const SizedBox(height: 8),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({
    required this.order,
    required this.onConfirmDrop,
    required this.onComplete,
    required this.onEndRental,
    required this.onDelegate,
    required this.onExtend,
    required this.onReport,
    required this.onCancel,
    required this.onDirections,
  });

  final Map<String, dynamic> order;
  final void Function(int orderId) onConfirmDrop;
  final void Function(int orderId) onComplete;
  final void Function(int orderId) onEndRental;
  final void Function(int orderId) onDelegate;
  final void Function(int orderId) onExtend;
  final void Function(int boxId) onReport;
  final void Function(int orderId) onCancel;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final id = order['id'] as int;
    final status = order['status'] as String? ?? '';
    final type = (order['type'] as String? ?? '').toUpperCase();
    final isRental = type == 'RENTAL';
    final isLaundry = type == 'LAUNDRY';
    final boxId = (order['sendBoxId'] ?? order['receiveBoxId']) as int?;
    final deadline = order['pickupDeadline'];
    final overdue =
        isOverdue(deadline) && status != 'COMPLETED' && status != 'CANCELED';
    final extraFee = order['extraFee'];
    final hasExtra =
        extraFee != null &&
        (extraFee is num ? extraFee > 0 : num.tryParse('$extraFee') != null);

    final actions = <Widget>[
      if (status == 'INITIALIZED')
        _SheetAction(
          label: 'Tôi đã bỏ đồ vào ô',
          icon: LucideIcons.packageCheck,
          primary: true,
          onTap: () => onConfirmDrop(id),
        ),
      if (status == 'RETURNED' ||
          (status == 'STORING' && !isRental && !isLaundry))
        _SheetAction(
          label: 'Tôi đã lấy đồ — hoàn tất',
          icon: LucideIcons.circleCheck,
          primary: true,
          onTap: () => onComplete(id),
        ),
      if (isRental && status == 'STORING') ...[
        _SheetAction(
          label: 'Gia hạn thuê',
          icon: LucideIcons.timer,
          onTap: () => onExtend(id),
        ),
        _SheetAction(
          label: 'Kết thúc thuê & trả ô',
          icon: LucideIcons.logOut,
          onTap: () => onEndRental(id),
        ),
      ],
      if (status == 'STORING' || status == 'RETURNED')
        _SheetAction(
          label: 'Ủy quyền người khác lấy hộ',
          icon: LucideIcons.userPlus,
          onTap: () => onDelegate(id),
        ),
      if (boxId != null && status != 'COMPLETED' && status != 'CANCELED')
        _SheetAction(
          label: 'Báo ô lỗi',
          icon: LucideIcons.triangleAlert,
          onTap: () => onReport(boxId),
        ),
      if (status == 'INITIALIZED')
        _SheetAction(
          label: 'Hủy đơn',
          icon: LucideIcons.circleX,
          danger: true,
          onTap: () => onCancel(id),
        ),
      _SheetAction(
        label: 'Chỉ đường tới tủ',
        icon: LucideIcons.map,
        onTap: onDirections,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor(status).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                typeIcon(order['type'] as String?),
                color: statusColor(status),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel(order['type'] as String?),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: opsDark,
                    ),
                  ),
                  Text(
                    '${order['orderCode'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: opsMutedText),
                  ),
                ],
              ),
            ),
            StatusChip(status),
          ],
        ),
        const SizedBox(height: 16),
        if (overdue)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: OpsBanner(
              tone: OpsBannerTone.danger,
              icon: LucideIcons.triangleAlert,
              text: 'Đơn đã quá hạn lấy — có thể phát sinh phí quá giờ.',
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: opsSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: opsBorder),
          ),
          child: Column(
            children: [
              OpsInfoRow(
                icon: LucideIcons.warehouse,
                label: 'Tủ',
                value: '${order['lockerId'] ?? '-'}',
              ),
              OpsInfoRow(
                icon: LucideIcons.grid3x3,
                label: 'Ô',
                value:
                    '${order['sendBoxId'] ?? '-'}${order['receiveBoxId'] != null ? ' → ${order['receiveBoxId']}' : ''}',
              ),
              if (deadline != null)
                OpsInfoRow(
                  icon: LucideIcons.clock,
                  label: 'Hạn',
                  value: '${fmtDateTime(deadline)} · ${fmtRemaining(deadline)}',
                  valueColor: overdue ? const Color(0xFFDC2626) : null,
                ),
              if (hasExtra)
                OpsInfoRow(
                  icon: LucideIcons.circlePlus,
                  label: 'Phí phát sinh',
                  value: fmtPrice(extraFee),
                  valueColor: const Color(0xFFB45309),
                ),
              OpsInfoRow(
                icon: LucideIcons.wallet,
                label: 'Tổng tiền',
                value: fmtPrice(order['totalPrice']),
                valueColor: opsDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (order['pinCode'] != null)
          Center(
            child: AccessCredentials(
              pin: order['pinCode'] as String?,
              qrToken: order['qrToken'] as String?,
            ),
          ),
        const SizedBox(height: 16),
        ...actions,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFDC2626) : opsPrimary;
    if (primary) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: OpsPrimaryButton(label: label, icon: icon, onPressed: onTap),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
