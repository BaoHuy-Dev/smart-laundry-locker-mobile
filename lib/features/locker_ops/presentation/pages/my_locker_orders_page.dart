import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/utils/locker_maps.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

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
  String _typeFilter = 'ALL';

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
    return _orders.where((o) {
      final type = (o['type'] as String? ?? '').toUpperCase();
      return _typeFilter == 'ALL' || type == _typeFilter;
    }).toList();
  }

  static DateTime? _parseOrderDate(Map<String, dynamic> o) {
    final raw = o['createdAt'] ?? o['updatedAt'] ?? o['pickupDeadline'];
    if (raw == null) return null;
    return DateTime.tryParse('$raw')?.toLocal();
  }

  static String _dateGroupLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${d.day} tháng ${d.month}, ${d.year}';
  }

  /// Orders grouped by date label, sorted newest-first within each group.
  List<MapEntry<String, List<Map<String, dynamic>>>> get _groupedOrders {
    final sorted = List<Map<String, dynamic>>.from(_visible)
      ..sort((a, b) {
        final da = _parseOrderDate(a);
        final db = _parseOrderDate(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

    final map = <String, List<Map<String, dynamic>>>{};
    for (final o in sorted) {
      final d = _parseOrderDate(o);
      final key = d == null ? 'Không rõ ngày' : _dateGroupLabel(d);
      (map[key] ??= []).add(o);
    }
    return map.entries.toList();
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
    final topPad = MediaQuery.of(context).padding.top;
    final groups = _groupedOrders;

    // Flatten groups into a mixed list of date-headers + order items
    final items = <_ListItem>[];
    for (final entry in groups) {
      items.add(_ListItem.header(entry.key));
      for (var i = 0; i < entry.value.length; i++) {
        items.add(_ListItem.order(entry.value[i]));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          // ── Simple Grab-style header ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hoạt động',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _load,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.refreshCw,
                      size: 18,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Service type chips ───────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
                children: [
                  _TypeChip(
                    label: 'Tất cả',
                    count: _orders.length,
                    selected: _typeFilter == 'ALL',
                    onTap: () => setState(() => _typeFilter = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Thuê tủ',
                    selected: _typeFilter == 'RENTAL',
                    onTap: () => setState(() => _typeFilter = 'RENTAL'),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Gửi hàng',
                    selected: _typeFilter == 'SEND',
                    onTap: () => setState(() => _typeFilter = 'SEND'),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Giặt ủi',
                    selected: _typeFilter == 'LAUNDRY',
                    onTap: () => setState(() => _typeFilter = 'LAUNDRY'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ── Grouped list ─────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AislBrand.navy),
                  )
                : _visible.isEmpty
                ? OpsEmptyState(
                    icon: LucideIcons.packageOpen,
                    title: 'Chưa có đơn nào',
                    subtitle: 'Tạo đơn Gửi hàng hoặc Thuê tủ từ màn hình chính.',
                  )
                : RefreshIndicator(
                    color: AislBrand.navy,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        if (item.isHeader) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Text(
                              item.header!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.3,
                              ),
                            ),
                          );
                        }
                        final order = item.order!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _OrderCard(
                            order: order,
                            onTap: () => _openDetail(order),
                          ).animate().fadeIn(
                            delay: (i * 30).ms,
                            duration: 200.ms,
                          ).slideY(
                            begin: 0.05,
                            end: 0,
                            delay: (i * 30).ms,
                            duration: 200.ms,
                            curve: Curves.easeOut,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── List item discriminated union ─────────────────────────────────────────────

class _ListItem {
  const _ListItem._({this.header, this.order});
  factory _ListItem.header(String h) => _ListItem._(header: h);
  factory _ListItem.order(Map<String, dynamic> o) => _ListItem._(order: o);

  final String? header;
  final Map<String, dynamic>? order;
  bool get isHeader => header != null;
}

// ── Service type chip ─────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111827) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 5),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Order card (Grab style) ───────────────────────────────────────────────────

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
    final sColor = statusColor(status);
    final isDone =
        status == 'COMPLETED' || status == 'CANCELED';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service type + time
                        Row(
                          children: [
                            Text(
                              typeLabel(type),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (deadline != null) ...[
                              const Text(
                                '  ·  ',
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                              Text(
                                fmtDateTime(deadline),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Status label
                            Text(
                              statusLabel(status),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDone
                                    ? const Color(0xFF16A34A)
                                    : overdue
                                    ? const Color(0xFFDC2626)
                                    : sColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Route: Tủ and Ô
                        _RouteRow(
                          isOrigin: true,
                          text: 'Tủ ${order['lockerId'] ?? '-'}',
                        ),
                        const SizedBox(height: 8),
                        _RouteRow(
                          isOrigin: false,
                          text: 'Ô ${boxId ?? '-'}',
                        ),
                        const SizedBox(height: 14),
                        // Price + action
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              fmtPrice(order['totalPrice']),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: onTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Xem lại',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Right: service icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon(type), color: sColor, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Overdue banner
            if (overdue)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: const Color(0xFFFEF2F2),
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.triangleAlert,
                      size: 13,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Đơn đã quá hạn — có thể phát sinh phí',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.isOrigin, required this.text});
  final bool isOrigin;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Center(
            child: isOrigin
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF9CA3AF),
                        width: 2,
                      ),
                    ),
                  )
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
