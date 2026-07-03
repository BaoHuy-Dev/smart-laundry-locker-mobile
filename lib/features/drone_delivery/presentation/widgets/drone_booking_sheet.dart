import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_laundry_locker/features/drone_delivery/data/drone_delivery_store.dart';
import 'package:smart_laundry_locker/features/drone_delivery/domain/entities/drone_order.dart';
import 'package:smart_laundry_locker/features/drone_delivery/presentation/pages/drone_tracking_page.dart';

class DroneBookingSheet extends StatefulWidget {
  const DroneBookingSheet({
    super.key,
    required this.cell,
    required this.lockerName,
    required this.origin,
  });

  final Map<String, dynamic> cell;
  final String lockerName;
  final LatLng origin;

  @override
  State<DroneBookingSheet> createState() => _DroneBookingSheetState();
}

class _DroneBookingSheetState extends State<DroneBookingSheet> {
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _confirm() {
    final order = DroneOrder(
      id: 'DRN-${DateTime.now().millisecondsSinceEpoch}',
      lockerName: widget.lockerName,
      boxNumber: (widget.cell['boxNumber'] as int?) ?? 0,
      origin: widget.origin,
      createdAt: DateTime.now(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    DroneDeliveryStore.instance.placeOrder(order);

    Navigator.pop(context);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => DroneTrackingPage(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxNumber = (widget.cell['boxNumber'] as int?) ?? 0;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight,
                  color: Color(0xFF6366F1),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đặt ô Drone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Ô #$boxNumber · ${widget.lockerName}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drone sẽ được quản lý điều phối và bay tới ô tủ để thả hàng. '
                    'Bạn có thể theo dõi tiến trình theo thời gian thực.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description input
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Mô tả hàng hóa (tùy chọn)',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),

          // Fee row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phí dịch vụ:', style: TextStyle(color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Miễn phí (Demo)',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Xác nhận đặt ô Drone',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
