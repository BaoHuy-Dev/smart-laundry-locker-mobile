import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

const opsPrimary = Color(0xFF0077B6);
const opsDark = Color(0xFF003D5B);

Color statusColor(String? status) => switch (status) {
  'AVAILABLE' => const Color(0xFF16A34A),
  'RESERVED' => const Color(0xFF2563EB),
  'OCCUPIED' => const Color(0xFFEA580C),
  'FAULT' => const Color(0xFFDC2626),
  'INITIALIZED' => const Color(0xFF2563EB),
  'STORING' => const Color(0xFFEA580C),
  'RETURNED' => const Color(0xFF9333EA),
  'COMPLETED' => const Color(0xFF16A34A),
  'CANCELED' => const Color(0xFF6B7280),
  'OPEN' => const Color(0xFFDC2626),
  'IN_PROGRESS' => const Color(0xFFD97706),
  'RESOLVED' => const Color(0xFF16A34A),
  _ => const Color(0xFF475569),
};

String statusLabel(String? status) => switch (status) {
  'AVAILABLE' => 'Trống',
  'RESERVED' => 'Đã giữ chỗ',
  'OCCUPIED' => 'Có đồ',
  'FAULT' => 'Hỏng',
  'INITIALIZED' => 'Chờ bỏ đồ',
  'STORING' => 'Đang trong tủ',
  'COLLECTED' => 'Đã thu gom',
  'PROCESSING' => 'Đang xử lý',
  'READY' => 'Sẵn sàng trả',
  'RETURNED' => 'Chờ lấy',
  'COMPLETED' => 'Hoàn tất',
  'CANCELED' => 'Đã hủy',
  'OPEN' => 'Mới',
  'IN_PROGRESS' => 'Đang xử lý',
  'RESOLVED' => 'Đã xong',
  _ => status ?? '',
};

String typeLabel(String? type) => switch (type) {
  'LAUNDRY' => 'Giặt ủi',
  'SEND' => 'Gửi hàng',
  'RENTAL' => 'Thuê tủ',
  'STORAGE' => 'Gửi đồ',
  'PARCEL' => 'Nhận hàng',
  _ => type ?? '',
};

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// PIN + QR block shown after an order is created / while it is active.
class AccessCredentials extends StatelessWidget {
  const AccessCredentials({super.key, required this.pin, this.qrToken});
  final String? pin;
  final String? qrToken;

  @override
  Widget build(BuildContext context) {
    if (pin == null || pin!.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        if (qrToken != null && qrToken!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: QrImageView(data: qrToken!, size: 170),
          ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: pin!));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã sao chép PIN')));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: opsDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pin!.split('').join(' '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Nhập PIN hoặc quét QR tại màn hình tủ để mở ô',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
