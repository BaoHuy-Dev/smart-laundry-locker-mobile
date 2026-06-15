import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';

/// Compute the discount (in VND) a validated [promotion] grants on [total].
/// Mirrors the order-service Promotion model (discountType / discountValue /
/// maxDiscountAmount / minOrderAmount).
int computePromotionDiscount(Map<String, dynamic>? promotion, int total) {
  if (promotion == null) return 0;
  final type = (promotion['discountType'] as String?) ?? 'FIXED_AMOUNT';
  final value = (promotion['discountValue'] as num?)?.toDouble() ?? 0;
  final maxDiscount = (promotion['maxDiscountAmount'] as num?)?.toDouble();
  final minOrder = (promotion['minOrderAmount'] as num?)?.toDouble() ?? 0;
  if (total < minOrder) return 0;
  double discount;
  if (type == 'PERCENT' || type == 'PERCENTAGE') {
    discount = total * value / 100;
    if (maxDiscount != null && discount > maxDiscount) discount = maxDiscount;
  } else {
    discount = value;
  }
  if (discount > total) discount = total.toDouble();
  if (discount < 0) discount = 0;
  return discount.round();
}

/// A promo-code input that validates against `/api/promotions/validate/{code}`
/// and reports the applied discount + code back to the parent.
class PromoCodeField extends StatefulWidget {
  const PromoCodeField({
    super.key,
    required this.orderTotal,
    required this.onChanged,
  });

  /// Current order subtotal (VND), used to compute percentage discounts.
  final int orderTotal;

  /// Called with the applied discount (VND) and the code (null when cleared).
  final void Function(int discount, String? code) onChanged;

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final _service = LockerOpsService();
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _appliedCode;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.validatePromotion(code);
      final valid = res['valid'] == true;
      final promotion = res['promotion'] as Map<String, dynamic>?;
      if (!valid || promotion == null) {
        setState(() {
          _error = 'Mã không hợp lệ hoặc đã hết hạn';
          _appliedCode = null;
        });
        widget.onChanged(0, null);
        return;
      }
      final discount = computePromotionDiscount(promotion, widget.orderTotal);
      if (discount <= 0) {
        setState(() {
          _error = 'Đơn chưa đủ điều kiện áp mã này';
          _appliedCode = null;
        });
        widget.onChanged(0, null);
        return;
      }
      setState(() => _appliedCode = code);
      widget.onChanged(discount, code);
    } catch (e) {
      setState(() => _error = LockerOpsService.errorMessage(e));
      widget.onChanged(0, null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clear() {
    setState(() {
      _appliedCode = null;
      _error = null;
      _ctrl.clear();
    });
    widget.onChanged(0, null);
  }

  @override
  Widget build(BuildContext context) {
    if (_appliedCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.badgeCheck, color: Color(0xFF16A34A), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã áp mã "$_appliedCode"',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
            ),
            TextButton(
              onPressed: _clear,
              child: const Text('Bỏ'),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                ],
                decoration: InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  prefixIcon:
                      const Icon(LucideIcons.ticket, size: 18, color: opsMutedText),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: opsBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: opsBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: opsPrimary, width: 1.6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: opsDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Áp dụng'),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5),
          ),
        ],
      ],
    );
  }
}

/// Small informational chip showing the user's loyalty points balance.
class LoyaltyPointsHint extends StatefulWidget {
  const LoyaltyPointsHint({super.key});

  @override
  State<LoyaltyPointsHint> createState() => _LoyaltyPointsHintState();
}

class _LoyaltyPointsHintState extends State<LoyaltyPointsHint> {
  final _service = LockerOpsService();
  int? _points;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _service.loyaltyPoints();
      if (!mounted) return;
      setState(() => _points = (res['points'] as num?)?.toInt());
    } catch (_) {
      // Loyalty is optional — stay silent if unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_points == null) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(LucideIcons.sparkles, size: 15, color: Color(0xFFCA8A04)),
        const SizedBox(width: 6),
        Text(
          'Bạn đang có $_points điểm tích lũy',
          style: const TextStyle(
            fontSize: 12.5,
            color: opsMutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Fetches the order's payments and renders the latest payment status.
class PaymentStatusChip extends StatefulWidget {
  const PaymentStatusChip({super.key, required this.orderId});

  final int orderId;

  @override
  State<PaymentStatusChip> createState() => _PaymentStatusChipState();
}

class _PaymentStatusChipState extends State<PaymentStatusChip> {
  final _service = LockerOpsService();
  bool _loading = true;
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final payments = await _service.paymentsByOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _status = payments.isEmpty
            ? null
            : payments.first['status'] as String?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  ({Color color, String label, IconData icon}) _style(String? status) {
    switch (status) {
      case 'PAID':
      case 'SUCCESS':
      case 'COMPLETED':
        return (
          color: const Color(0xFF16A34A),
          label: 'Đã thanh toán',
          icon: LucideIcons.circleCheck,
        );
      case 'PENDING':
      case 'PROCESSING':
        return (
          color: const Color(0xFFCA8A04),
          label: 'Chờ thanh toán',
          icon: LucideIcons.clock,
        );
      case 'FAILED':
      case 'CANCELED':
        return (
          color: const Color(0xFFDC2626),
          label: 'Thanh toán lỗi',
          icon: LucideIcons.circleX,
        );
      default:
        return (
          color: opsMutedText,
          label: 'Chưa có thanh toán',
          icon: LucideIcons.wallet,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final s = _style(_status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14, color: s.color),
          const SizedBox(width: 6),
          Text(
            s.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: s.color,
            ),
          ),
        ],
      ),
    );
  }
}
