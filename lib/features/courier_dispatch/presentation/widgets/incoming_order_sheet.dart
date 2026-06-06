import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IncomingOrderSheet extends StatefulWidget {
  final Map<String, dynamic> dispatchData;
  final FutureOr<void> Function() onAccept;
  final FutureOr<void> Function() onDecline;

  const IncomingOrderSheet({
    super.key,
    required this.dispatchData,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<IncomingOrderSheet> createState() => _IncomingOrderSheetState();
}

class _IncomingOrderSheetState extends State<IncomingOrderSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const progressColor = CupertinoColors.activeOrange;

    final logisticsType =
        widget.dispatchData['logisticsType']?.toString() ?? 'LOCKER_TO_LOCKER';
    final isHomePickup = logisticsType == 'HOME_TO_LOCKER';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: const Border(top: BorderSide(color: progressColor, width: 4)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle for bottom sheet
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(
                  CupertinoIcons.bell_fill,
                  color: CupertinoColors.activeOrange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ĐƠN HÀNG MỚI!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isHomePickup
                    ? CupertinoColors.activeBlue.withOpacity(0.1)
                    : CupertinoColors.activeOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHomePickup
                      ? CupertinoColors.activeBlue.withOpacity(0.3)
                      : CupertinoColors.activeOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHomePickup
                        ? CupertinoIcons.house_fill
                        : CupertinoIcons.archivebox_fill,
                    size: 16,
                    color: isHomePickup
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.activeOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHomePickup ? 'LẤY HÀNG TẠI NHÀ' : 'LẤY HÀNG TẠI TỦ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isHomePickup
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.activeOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLocationItem(
              isHomePickup
                  ? CupertinoIcons.house_fill
                  : CupertinoIcons.location_solid,
              isHomePickup ? 'Địa chỉ khách hàng' : 'Điểm lấy hàng (Tủ)',
              widget.dispatchData['senderAddress']?.toString() ?? 'Không rõ',
              isHomePickup
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.activeBlue,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: SizedBox(
                height: 20,
                child: VerticalDivider(
                  color: CupertinoColors.systemGrey4,
                  thickness: 2,
                ),
              ),
            ),
            _buildLocationItem(
              CupertinoIcons.flag_fill,
              'Điểm giao hàng (Đích)',
              widget.dispatchData['receiverAddress']?.toString() ?? 'Không rõ',
              CupertinoColors.activeGreen,
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onDecline();
                          },
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.systemGrey5,
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    onPressed: isLoading ? null : _handleAccept,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.activeOrange,
                    child: isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : const Text(
                            'Nhận đơn',
                            style: TextStyle(
                              color: CupertinoColors.white,
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

  bool isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => isLoading = true);
    try {
      await widget.onAccept();
    } catch (e) {
      debugPrint('Accept error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildLocationItem(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
