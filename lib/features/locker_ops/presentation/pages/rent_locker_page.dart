import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// RENTAL flow: pick cabinet + cell type + duration, pay-per-hour,
/// multi-use PIN until the rental deadline.
class RentLockerPage extends StatefulWidget {
  const RentLockerPage({super.key});

  @override
  State<RentLockerPage> createState() => _RentLockerPageState();
}

class _RentLockerPageState extends State<RentLockerPage> {
  static const _rates = {'STANDARD': 5000, 'XL': 10000};

  final _service = LockerOpsService();
  List<Map<String, dynamic>> _lockers = [];
  int? _lockerId;
  String _cellType = 'STANDARD';
  double _hours = 4;
  bool _loading = false;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _loadLockers();
  }

  Future<void> _loadLockers() async {
    try {
      final lockers = await _service.lockers();
      if (!mounted) return;
      setState(() {
        _lockers = lockers.where((l) => l['status'] == 'ACTIVE').toList();
        if (_lockers.isNotEmpty) _lockerId = _lockers.first['id'] as int?;
      });
    } catch (e) {
      _snack(LockerOpsService.errorMessage(e));
    }
  }

  int get _price => (_rates[_cellType] ?? 5000) * _hours.round();

  Future<void> _create() async {
    if (_lockerId == null) return;
    setState(() => _loading = true);
    try {
      final order = await _service.createRental(
        lockerId: _lockerId!,
        cellType: _cellType,
        hours: _hours.round(),
      );
      if (!mounted) return;
      setState(() => _order = order);
    } catch (e) {
      _snack(LockerOpsService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDrop() async {
    final id = _order?['id'] as int?;
    if (id == null) return;
    setState(() => _loading = true);
    try {
      final updated = await _service.confirmDrop(id);
      if (!mounted) return;
      setState(() => _order = updated);
      _snack('Bắt đầu kỳ thuê — PIN dùng nhiều lần');
    } catch (e) {
      _snack(LockerOpsService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Thuê tủ giữ đồ'),
        backgroundColor: opsDark,
        foregroundColor: Colors.white,
      ),
      body: _order == null ? _buildForm() : _buildResult(),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Chọn tủ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _lockerId,
          items: _lockers
              .map(
                (l) => DropdownMenuItem(
                  value: l['id'] as int?,
                  child: Text('${l['name'] ?? l['code']}'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _lockerId = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Loại ô', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _cellOption('STANDARD', 'Ô thường', '45×30×50cm — 5.000đ/giờ'),
            const SizedBox(width: 12),
            _cellOption('XL', 'Ô vali (XL)', '30×80×40cm — 10.000đ/giờ'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Thời gian thuê: ${_hours.round()} giờ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _hours,
          min: 1,
          max: 72,
          divisions: 71,
          activeColor: opsPrimary,
          label: '${_hours.round()}h',
          onChanged: (v) => setState(() => _hours = v),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tạm tính'),
              Text(
                '${_price ~/ 1000}.000đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _create,
          style: ElevatedButton.styleFrom(
            backgroundColor: opsPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Thuê ngay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _cellOption(String value, String title, String subtitle) {
    final selected = _cellType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _cellType = value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? opsPrimary.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? opsPrimary : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? opsPrimary : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final order = _order!;
    final status = order['status'] as String?;
    final started = status == 'STORING';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn ${order['orderCode'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    StatusChip(status),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  started
                      ? 'Kỳ thuê đang chạy — PIN mở ô nhiều lần tới ${order['pickupDeadline'] ?? ''}'
                      : 'Ô số ${order['sendBoxId']} đã giữ chỗ. Mở ô bằng PIN và bỏ đồ vào.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                AccessCredentials(
                  pin: order['pinCode'] as String?,
                  qrToken: order['qrToken'] as String?,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!started)
          ElevatedButton(
            onPressed: _loading ? null : _confirmDrop,
            style: ElevatedButton.styleFrom(
              backgroundColor: opsPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tôi đã bỏ đồ — bắt đầu kỳ thuê',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Xong — xem trong Đơn của tôi'),
          ),
      ],
    );
  }
}
