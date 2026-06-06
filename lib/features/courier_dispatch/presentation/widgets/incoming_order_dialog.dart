import 'dart:async';
import 'package:flutter/material.dart';

class IncomingOrderDialog extends StatefulWidget {
  final Map<String, dynamic> dispatchData;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingOrderDialog({
    super.key,
    required this.dispatchData,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<IncomingOrderDialog> createState() => _IncomingOrderDialogState();
}

class _IncomingOrderDialogState extends State<IncomingOrderDialog>
    with SingleTickerProviderStateMixin {
  static const int _timeoutSeconds = 30;
  int _secondsLeft = _timeoutSeconds;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Setup alarming pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        widget.onDecline(); // Auto-decline when timer runs out
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine progress color based on remaining time
    final progressColor = _secondsLeft > 10 ? Colors.green : Colors.red;

    final logisticsType =
        widget.dispatchData['logisticsType']?.toString() ?? 'LOCKER_TO_LOCKER';
    final isHomePickup = logisticsType == 'HOME_TO_LOCKER';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ringer icon and Title
            ScaleTransition(
              scale: _pulseAnimation,
              child: const Icon(
                Icons.notifications_active,
                color: Colors.redAccent,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'GIAO HÀNG MỚI!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Logistics Type Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isHomePickup
                    ? Colors.blue.withOpacity(0.1)
                    : const Color(0xFF0A2342).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHomePickup
                      ? Colors.blue.withOpacity(0.3)
                      : const Color(0xFF0A2342).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isHomePickup ? Icons.home : Icons.archive,
                    size: 16,
                    color: isHomePickup ? Colors.blue : const Color(0xFF0A2342),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHomePickup ? 'LẤY HÀNG TẠI NHÀ' : 'LẤY HÀNG TẠI TỦ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isHomePickup
                          ? Colors.blue
                          : const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Map data
            _buildInfoRow(
              isHomePickup ? Icons.home : Icons.location_on,
              isHomePickup ? 'Địa Chỉ Khách Hàng' : 'Điểm Lấy Hàng (Tủ)',
              widget.dispatchData['senderAddress']?.toString() ?? 'Đang tải...',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.sports_score,
              'Điểm Giao Hàng (Đích)',
              widget.dispatchData['receiverAddress']?.toString() ??
                  'Đang tải...',
              Colors.green,
            ),
            const SizedBox(height: 24),

            // Progress Bar
            Text(
              'Tự động huỷ sau $_secondsLeft giây',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _secondsLeft / _timeoutSeconds,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      widget.onDecline();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'BỎ QUA',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      widget.onAccept();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'NHẬN ĐƠN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
