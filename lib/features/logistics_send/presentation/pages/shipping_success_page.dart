import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/logistics_success_entity.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/params/logistics_success_load_params.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/providers/logistics_send_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ShippingSuccessPage extends ConsumerStatefulWidget {
  const ShippingSuccessPage({super.key, this.loadParams});

  final LogisticsSuccessLoadParams? loadParams;

  @override
  ConsumerState<ShippingSuccessPage> createState() =>
      _ShippingSuccessPageState();
}

class _ShippingSuccessPageState extends ConsumerState<ShippingSuccessPage> {
  String _formatMoney(int amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(amount).replaceAll('\u00a0', ' ');
  }

  String _displayLockerLabel(String? lockerLabel) {
    if (lockerLabel == null || lockerLabel.isEmpty) return '—';
    final parts = lockerLabel.split(' x ');
    if (parts.length == 2) {
      final rowStr = parts[0].trim();
      final colStr = parts[1].trim();
      final rowNum = int.tryParse(rowStr);
      if (rowNum != null && rowNum > 0) {
        final rowChar = String.fromCharCode('A'.codeUnitAt(0) + rowNum - 1);
        return '$rowChar$colStr';
      }
    }
    return lockerLabel;
  }

  Future<void> _copyOtp(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    SmartDialog.showToast('Đã sao chép mã mở tủ');
  }

  Future<void> _openDirections(LogisticsSuccessEntity data) async {
    final lat = data.locationSendLatitude ?? data.latitude;
    final lng = data.locationSendLongitude ?? data.longitude;
    final Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
    } else {
      final q = data.directionsQuery.trim();
      if (q.isEmpty) {
        SmartDialog.showToast('Chưa có địa chỉ tủ để chỉ đường.');
        return;
      }
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SmartDialog.showToast('Không mở được bản đồ.');
    }
  }

  void _reload() {
    final p = widget.loadParams;
    if (p == null) return;
    ref.invalidate(logisticsSuccessEntityProvider(p));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.loadParams;
    if (p == null) {
      return _buildScaffold(
        context,
        AsyncValue.data(LogisticsSuccessEntity.preview),
      );
    }

    final async = ref.watch(logisticsSuccessEntityProvider(p));
    return _buildScaffold(context, async);
  }

  Widget _buildScaffold(
    BuildContext context,
    AsyncValue<LogisticsSuccessEntity> async,
  ) {
    final showReload = widget.loadParams != null;
    return async.when(
      data: (data) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.missingOtpOrLockerInfo) ...[
                    _DataWarningBanner(onReload: showReload ? _reload : null),
                    const SizedBox(height: 16),
                  ],
                  _HeaderSection(
                    orderCode: data.orderCode,
                    totalCollected: _formatMoney(data.amountVnd),
                  ),
                  const SizedBox(height: 24),
                  _OtpActionCard(
                    data: data,
                    displayLockerLabel: _displayLockerLabel(data.lockerLabel),
                    onCopy: data.otpCode != null && data.otpCode!.isNotEmpty
                        ? () => _copyOtp(context, data.otpCode!)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _LockerLocationSection(
                    data: data,
                    onDirections: () => _openDirections(data),
                  ),
                  const SizedBox(height: 20),
                  _OrderSummarySection(data: data),
                  const SizedBox(height: 28),
                  _BottomActions(
                    onHome: () => context.go(AppRouter.home),
                    onTrackOrders: () => context.go(AppRouter.orders),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                ),
                const SizedBox(height: 24),
                if (showReload)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2342),
                    ),
                    onPressed: _reload,
                    child: const Text(
                      'Tải lại dữ liệu',
                      style: TextStyle(color: Colors.white),
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

class _DataWarningBanner extends StatelessWidget {
  const _DataWarningBanner({this.onReload});

  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Chưa đủ mã OTP hoặc thông tin tủ. Vui lòng thử tải lại.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF9A3412),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onReload != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onReload,
                child: const Text('Tải lại dữ liệu'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.orderCode, required this.totalCollected});

  final String orderCode;
  final String totalCollected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 52,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Thanh toán thành công',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          orderCode,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          totalCollected,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AISLShadcnTheme.navyPrimary,
          ),
        ),
      ],
    );
  }
}

class _OtpActionCard extends StatelessWidget {
  const _OtpActionCard({
    required this.data,
    required this.displayLockerLabel,
    this.onCopy,
  });

  final LogisticsSuccessEntity data;
  final String displayLockerLabel;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final hasOtp = data.otpCode != null && data.otpCode!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.keyRound,
                size: 20,
                color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 8),
              const Text(
                'Mã mở tủ (OTP)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasOtp)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.otpCode!,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        height: 1.05,
                        color: Color(0xFF0F172A),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(LucideIcons.copy, size: 18),
                  label: const Text('Sao chép'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AISLShadcnTheme.navyPrimary,
                    side: BorderSide(
                      color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'Chưa có mã OTP. Thử tải lại hoặc kiểm tra đơn trên màn Đơn hàng.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Ô tủ: ',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                displayLockerLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Vui lòng nhập mã này tại tủ để mở ô gửi hàng.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockerLocationSection extends StatelessWidget {
  const _LockerLocationSection({
    required this.data,
    required this.onDirections,
  });

  final LogisticsSuccessEntity data;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final name = (data.locationSendName ?? data.cabinetName ?? '').trim();
    final addr = (data.cabinetAddress ?? data.pickupAddress ?? '').trim();
    final hasText = name.isNotEmpty || addr.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 20,
                color: AISLShadcnTheme.navyPrimary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ tủ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (name.isNotEmpty)
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          if (name.isNotEmpty && addr.isNotEmpty) const SizedBox(height: 8),
          if (addr.isNotEmpty)
            Text(
              addr,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
          if (!hasText)
            Text(
              'Chưa có địa chỉ tủ.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onDirections,
              icon: const Icon(LucideIcons.navigation, size: 20),
              label: const Text(
                'Chỉ đường',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection({required this.data});

  final LogisticsSuccessEntity data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Người nhận', data.receiverName),
          const SizedBox(height: 10),
          _summaryRow('Số điện thoại', data.receiverPhone),
          if (data.note != null && data.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.note!.trim(),
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onHome, required this.onTrackOrders});

  final VoidCallback onHome;
  final VoidCallback onTrackOrders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onTrackOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AISLShadcnTheme.navyPrimary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: onHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Về trang chủ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
