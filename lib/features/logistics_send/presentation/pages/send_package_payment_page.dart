import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/params/logistics_success_load_params.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/widgets/finding_courier_sheet.dart';
import 'package:smart_laundry_locker/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SendPackagePaymentPage extends StatelessWidget {
  const SendPackagePaymentPage({
    super.key,
    required this.dispatchId,
    this.orderId,
    required this.recipientName,
    required this.recipientPhone,
    required this.feeAmountVnd,
    this.dispatchStatus,
    this.note,
  });

  final String dispatchId;
  final String? orderId;
  final String recipientName;
  final String recipientPhone;
  final int feeAmountVnd;
  final String? dispatchStatus;
  final String? note;

  String _formatMoney(int amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(amount).replaceAll('\u00a0', ' ');
  }

  Future<void> _onSend(BuildContext context) async {
    // Save dispatchId for persistence fallback
    TokenService.saveActiveDispatchId(dispatchId);

    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FindingCourierSheet(
        dispatchId: dispatchId,
        onCourierFound: (newOrderId) => _navigateToSuccess(context, newOrderId),
      ),
    );
  }

  void _navigateToSuccess(BuildContext context, String newOrderId) {
    if (!context.mounted) return;
    final loadParams = LogisticsSuccessLoadParams(
      orderId: newOrderId.isNotEmpty ? newOrderId : orderId,
      dispatchId: dispatchId,
      totalCollectedVnd: feeAmountVnd,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      note: note,
      courierHints: null,
    );
    context.go(AppRouter.shippingSuccess, extra: loadParams);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final shortId = dispatchId.length > 12
        ? '${dispatchId.substring(0, 8)}…'
        : dispatchId;

    const titleStyle = TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 24,
      letterSpacing: -0.4,
      color: Color(0xFF0F172A),
    );
    const labelStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 17,
      height: 1.4,
      fontWeight: FontWeight.w600,
    );
    const valueStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      height: 1.35,
      color: Color(0xFF0F172A),
    );

    final balanceAfterPayment = (wallet.balance - feeAmountVnd).round();
    final afterPaymentStyle = balanceAfterPayment < 0
        ? valueStyle.copyWith(color: const Color(0xFFB91C1C))
        : valueStyle;

    return Scaffold(
      backgroundColor: AISLShadcnTheme.navySurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'THANH TOÁN GỬI HÀNG',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.35,
            color: Colors.black87,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Chi tiết yêu cầu', style: titleStyle),
                      const SizedBox(height: 8),
                      Text(
                        'Kiểm tra thông tin trước khi thanh toán',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _DetailRow(
                        label: 'Mã yêu cầu',
                        value: shortId,
                        labelStyle: labelStyle,
                        valueStyle: valueStyle,
                      ),
                      if (dispatchStatus != null &&
                          dispatchStatus!.trim().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _DetailRow(
                          label: 'Trạng thái',
                          value: dispatchStatus!.trim(),
                          labelStyle: labelStyle,
                          valueStyle: valueStyle,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _DetailRow(
                        label: 'Người nhận',
                        value: recipientName,
                        labelStyle: labelStyle,
                        valueStyle: valueStyle,
                      ),
                      const SizedBox(height: 20),
                      _DetailRow(
                        label: 'Số điện thoại',
                        value: recipientPhone,
                        labelStyle: labelStyle,
                        valueStyle: valueStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Text(
                              'Phí gửi hàng',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          Text(
                            _formatMoney(feeAmountVnd),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                              letterSpacing: -0.6,
                              color: AISLShadcnTheme.navyPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _DetailRow(
                        label: 'Số dư ví sau thanh toán',
                        value: wallet.isLoading
                            ? 'Đang tải…'
                            : _formatMoney(balanceAfterPayment),
                        labelStyle: labelStyle,
                        valueStyle: wallet.isLoading
                            ? valueStyle.copyWith(fontSize: 19)
                            : afterPaymentStyle.copyWith(fontSize: 21),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Text(
                          'Lưu ý: Nếu bạn không bỏ hàng vào tủ, đơn sẽ bị hủy sau 15 phút.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _onSend(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AISLShadcnTheme.navyPrimary,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: AISLShadcnTheme.navyPrimary.withOpacity(0.4),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Gửi hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(flex: 12, child: Text(label, style: labelStyle)),
        Expanded(
          flex: 13,
          child: Text(value, style: valueStyle, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
