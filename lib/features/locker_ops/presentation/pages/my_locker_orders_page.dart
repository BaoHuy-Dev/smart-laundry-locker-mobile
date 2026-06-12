import 'package:flutter/material.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// All locker orders of the signed-in customer, with the full action set:
/// confirm drop, pickup, delegate, extend/end rental, cancel.
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        title: const Text('Ủy quyền lấy hộ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'SĐT người lấy hộ'),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên (tùy chọn)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
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
        'Đã ủy quyền — PIN mới được gửi cho cả hai bên',
      );
    }
  }

  Future<void> _extendDialog(int orderId) async {
    double hours = 2;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => AlertDialog(
          title: const Text('Gia hạn thuê'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Thêm ${hours.round()} giờ'),
              Slider(
                value: hours,
                min: 1,
                max: 24,
                divisions: 23,
                onChanged: (v) => setSheet(() => hours = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
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

  void _openDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
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
            onCancel: (id) async {
              Navigator.pop(ctx);
              await _runAction(() => _service.cancelOrder(id), 'Đã hủy đơn');
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Đơn tủ của tôi'),
        backgroundColor: opsDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                ? const Center(
                    child: Text(
                      'Không có đơn nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: _visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final o = _visible[i];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            onTap: () => _openDetail(o),
                            title: Text(
                              '${typeLabel(o['type'] as String?)} · ${o['orderCode'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Tủ ${o['lockerId'] ?? '-'} · ô ${o['sendBoxId'] ?? o['receiveBoxId'] ?? '-'}'
                              '${o['pickupDeadline'] != null ? '\nHạn: ${o['pickupDeadline']}' : ''}',
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
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: opsPrimary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? opsPrimary : Colors.grey,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _filter = value),
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
    required this.onCancel,
  });

  final Map<String, dynamic> order;
  final void Function(int orderId) onConfirmDrop;
  final void Function(int orderId) onComplete;
  final void Function(int orderId) onEndRental;
  final void Function(int orderId) onDelegate;
  final void Function(int orderId) onExtend;
  final void Function(int orderId) onCancel;

  @override
  Widget build(BuildContext context) {
    final id = order['id'] as int;
    final status = order['status'] as String? ?? '';
    final type = (order['type'] as String? ?? '').toUpperCase();
    final isRental = type == 'RENTAL';

    final actions = <Widget>[
      if (status == 'INITIALIZED')
        _action(
          'Tôi đã bỏ đồ vào ô',
          Icons.inventory_2,
          () => onConfirmDrop(id),
        ),
      if (status == 'RETURNED' ||
          (status == 'STORING' && !isRental && type != 'LAUNDRY'))
        _action(
          'Tôi đã lấy đồ — hoàn tất',
          Icons.check_circle,
          () => onComplete(id),
        ),
      if (isRental && status == 'STORING') ...[
        _action('Gia hạn thuê', Icons.more_time, () => onExtend(id)),
        _action('Kết thúc thuê & trả ô', Icons.logout, () => onEndRental(id)),
      ],
      if (status == 'STORING' || status == 'RETURNED')
        _action(
          'Ủy quyền người khác lấy hộ',
          Icons.group_add,
          () => onDelegate(id),
        ),
      if (status == 'INITIALIZED')
        _action(
          'Hủy đơn',
          Icons.cancel_outlined,
          () => onCancel(id),
          danger: true,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${typeLabel(order['type'] as String?)} · ${order['orderCode'] ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            StatusChip(status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tủ ${order['lockerId'] ?? '-'} · ô gửi ${order['sendBoxId'] ?? '-'}'
          '${order['receiveBoxId'] != null ? ' · ô nhận ${order['receiveBoxId']}' : ''}'
          '${order['pickupDeadline'] != null ? '\nHạn: ${order['pickupDeadline']}' : ''}'
          '${order['totalPrice'] != null ? '\nTổng tiền: ${order['totalPrice']}đ' : ''}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Center(
          child: AccessCredentials(
            pin: order['pinCode'] as String?,
            qrToken: order['qrToken'] as String?,
          ),
        ),
        const SizedBox(height: 16),
        ...actions,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _action(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: danger ? Colors.red : opsPrimary),
        label: Text(
          label,
          style: TextStyle(color: danger ? Colors.red : opsPrimary),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          side: BorderSide(
            color: danger ? Colors.red.shade200 : const Color(0xFFB6DCEF),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
