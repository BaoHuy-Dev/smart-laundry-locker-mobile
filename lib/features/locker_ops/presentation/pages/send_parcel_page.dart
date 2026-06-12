import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// SEND flow — stage 1: create order + drop PIN; stage 2: confirm drop,
/// receiver PIN is issued and pushed to the receiver's account.
class SendParcelPage extends StatefulWidget {
  const SendParcelPage({super.key});

  @override
  State<SendParcelPage> createState() => _SendParcelPageState();
}

class _SendParcelPageState extends State<SendParcelPage> {
  final _service = LockerOpsService();
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<Map<String, dynamic>> _lockers = [];
  int? _lockerId;
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

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false) || _lockerId == null) {
      return;
    }
    setState(() => _loading = true);
    try {
      final order = await _service.createSend(
        lockerId: _lockerId!,
        receiverPhone: _phoneCtrl.text.trim(),
        receiverName: _nameCtrl.text.trim().isEmpty
            ? null
            : _nameCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
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
      _snack('Đã gửi PIN nhận hàng tới người nhận');
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
        title: const Text('Gửi hàng qua tủ'),
        backgroundColor: opsDark,
        foregroundColor: Colors.white,
      ),
      body: _order == null ? _buildForm() : _buildResult(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
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
            decoration: _input('Tủ gần bạn'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Số điện thoại người nhận',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _input('VD: 0900000000'),
            validator: (v) => (v == null || v.trim().length < 9)
                ? 'Nhập số điện thoại hợp lệ'
                : null,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tên người nhận (tùy chọn)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            decoration: _input('Nguyễn Văn A'),
          ),
          const SizedBox(height: 16),
          const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _noteCtrl,
            decoration: _input('Hàng dễ vỡ...'),
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
                    'Tạo đơn & lấy PIN bỏ hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final order = _order!;
    final status = order['status'] as String?;
    final isDropped = status == 'STORING';
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
                if (!isDropped) ...[
                  const Text(
                    'Bước 1 — Bỏ hàng vào ô',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đến tủ, nhập PIN dưới đây để mở ô số ${order['sendBoxId']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ] else ...[
                  const Text(
                    'Bước 2 — Đã bỏ hàng xong',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PIN nhận hàng đã gửi tới ${order['receiverId'] != null ? 'tài khoản người nhận' : 'bạn — hãy chuyển cho người nhận'}:',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
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
        if (!isDropped)
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
              'Tôi đã bỏ hàng vào ô',
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
            child: const Text('Hoàn tất'),
          ),
      ],
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  );

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
