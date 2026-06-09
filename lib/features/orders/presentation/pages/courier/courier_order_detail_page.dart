import 'dart:async';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/locker/domain/entities/cabinet.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_provider.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_injection.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order_detail.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_injection.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_provider.dart';
import 'package:smart_laundry_locker/core/services/courier_mode_provider.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/order_status_colors.dart';
import 'package:smart_laundry_locker/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:smart_laundry_locker/core/utils/enum_translator.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/pulsing_report_icon.dart';
import 'package:smart_laundry_locker/features/maintenance/presentation/pages/create_report_page.dart';

/// Trang chi tiết đơn logistics (Courier - LOGISTICS)
class CourierOrderDetailPage extends StatefulWidget {
  final OrderWithDetails job;
  const CourierOrderDetailPage({Key? key, required this.job}) : super(key: key);

  @override
  State<CourierOrderDetailPage> createState() => _CourierOrderDetailPageState();
}

class _CourierOrderDetailPageState extends State<CourierOrderDetailPage> {
  late OrderProvider _provider;
  late final CourierDeliveryProvider _courierDeliveryProvider;
  late final LockerProvider _lockerProvider;

  Cabinet? _originCabinet;
  Cabinet? _destinationCabinet;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _provider = OrderInjection.provideOrderProvider(ApiClient());
    _courierDeliveryProvider =
        CourierDeliveryInjection.provideCourierDeliveryProvider();
    _lockerProvider = LockerInjection.provideLockerProvider(ApiClient());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_init());
    });
  }

  Future<void> _init() async {
    try {
      _initError = null;
      await _provider.fetchCourierOrderDetail(widget.job.orderId);

      final status = (_provider.selectedOrder?.status ?? widget.job.status)
          .toUpperCase();

      final hasDispatchId =
          widget.job.order.dispatchId != null &&
          widget.job.order.dispatchId!.trim().isNotEmpty;

      if ((status == 'AWAITING_COURIER' || status == 'ACTIVE') &&
          hasDispatchId) {
        if (_courierDeliveryProvider.activeOrder == null) {
          await _courierDeliveryProvider.acceptOrder(
            widget.job.order.dispatchId!,
          );
        }
      }

      if (_courierDeliveryProvider.activeOrder == null) {
        await _courierDeliveryProvider.fetchActiveDeliveryDetail();
      }

      final accessCode = _courierDeliveryProvider.activeOrder?.accessCode;
      if (accessCode != null && accessCode.trim().isNotEmpty) {
        if (_courierDeliveryProvider.destinationLockerLabel == null) {
          await _courierDeliveryProvider.pickupPackage(accessCode.trim());
        }
      }

      final currentOrder = _provider.selectedOrder ?? _fallbackOrder();
      await _loadCabinets(currentOrder);
    } catch (e, s) {
      debugPrint('CourierOrderDetailPage init error: $e\n$s');
      if (!mounted) return;
      setState(() {
        _initError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    _lockerProvider.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? d) =>
      d == null ? '--' : DateFormat('dd/MM/yyyy HH:mm').format(d.toLocal());

  String _fmtCurrency(double v) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(v);

  List<OrderDetail> _getDetails(OrderProvider provider) {
    return provider.orderDetails;
  }

  Future<void> _loadCabinets(Order order) async {
    final originId = order.originCabinetId?.trim();
    final destinationId = order.destinationCabinetId?.trim();

    setState(() {
      _originCabinet = null;
      _destinationCabinet = null;
    });

    try {
      if (originId != null && originId.isNotEmpty) {
        _originCabinet = await _lockerProvider.getCabinetById(originId);
      }

      if (destinationId != null && destinationId.isNotEmpty) {
        _destinationCabinet = await _lockerProvider.getCabinetById(
          destinationId,
        );
      }
    } catch (e, s) {
      debugPrint('CourierOrderDetailPage loadCabinets error: $e\n$s');
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: 'Chi tiết vận chuyển',
          centerTitle: true,
          showBackButton: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          foregroundColorButton: Colors.black,
          actions: [
            Consumer<OrderProvider>(
              builder: (context, provider, _) {
                final order = provider.selectedOrder ?? _fallbackOrder();
                final details = _getDetails(provider);
                return PulsingReportIcon(
                  onPressed: () => _handleReportIssue(context, order, details),
                );
              },
            ),
          ],
        ),
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<CourierDeliveryProvider>.value(
              value: _courierDeliveryProvider,
            ),
          ],
          child: Consumer<OrderProvider>(
            builder: (context, provider, child) {
              final order = provider.selectedOrder ?? _fallbackOrder();
              final details = _getDetails(provider);

              final courierProvider = context.watch<CourierDeliveryProvider>();
              final detailsSorted = [...details]
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
              final originDetail = detailsSorted.isNotEmpty
                  ? detailsSorted.first
                  : null;
              final destinationDetail = detailsSorted.isNotEmpty
                  ? detailsSorted.last
                  : null;

              final otpCode =
                  originDetail?.accessCode ??
                  destinationDetail?.accessCode ??
                  courierProvider.activeOrder?.accessCode ??
                  (detailsSorted.isNotEmpty
                      ? detailsSorted
                            .map((d) => d.accessCode)
                            .firstWhere(
                              (code) => code != null && code.trim().isNotEmpty,
                              orElse: () => null,
                            )
                      : null);
              final shipmentDetailsInOrder = <OrderDetail>[
                if (originDetail != null) originDetail,
                if (destinationDetail != null &&
                    destinationDetail.id != originDetail?.id)
                  destinationDetail,
              ];

              String? pickNonEmpty(String? v) {
                final s = v?.trim();
                if (s == null || s.isEmpty) return null;
                if (s == '-' || s == '--' || s.toLowerCase() == 'null') {
                  return null;
                }
                return s;
              }

              final originLockerLabel =
                  pickNonEmpty(originDetail?.formattedLockerLabel) ?? '-';
              final destinationLockerLabel =
                  pickNonEmpty(destinationDetail?.formattedLockerLabel) ??
                  pickNonEmpty(courierProvider.destinationLockerLabel) ??
                  '-';

              final receiverNameRaw =
                  pickNonEmpty(destinationDetail?.receiverName) ??
                  pickNonEmpty(originDetail?.receiverName) ??
                  pickNonEmpty(courierProvider.activeOrder?.recipientName);
              final receiverPhoneRaw =
                  pickNonEmpty(destinationDetail?.receiverPhone) ??
                  pickNonEmpty(originDetail?.receiverPhone) ??
                  pickNonEmpty(courierProvider.activeOrder?.recipientPhone);
              final noteTextRaw =
                  pickNonEmpty(destinationDetail?.note) ??
                  pickNonEmpty(originDetail?.note);

              final originCabinetName =
                  pickNonEmpty(_originCabinet?.name) ??
                  (order.originCabinetId ?? '-');
              final originCabinetAddress =
                  pickNonEmpty(_originCabinet?.address) ??
                  pickNonEmpty(_originCabinet?.locationName) ??
                  '-';

              final destinationCabinetName =
                  pickNonEmpty(destinationDetail?.receiverAddress) ??
                  pickNonEmpty(_destinationCabinet?.name) ??
                  (order.destinationCabinetId ?? '-');
              final destinationCabinetAddress =
                  pickNonEmpty(destinationDetail?.receiverAddress) ??
                  pickNonEmpty(_destinationCabinet?.address) ??
                  pickNonEmpty(_destinationCabinet?.locationName) ??
                  '-';

              // `/logistics/courier/accept` trả về địa chỉ người gửi (dispatch.senderAddress)
              final senderAddressRaw =
                  pickNonEmpty(courierProvider.activeOrder?.address) ??
                  originCabinetAddress;

              final senderAddress = pickNonEmpty(senderAddressRaw) ?? '--';
              final receiverName = receiverNameRaw ?? '--';
              final receiverPhone = receiverPhoneRaw ?? '--';
              final noteText = noteTextRaw ?? '--';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_initError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.25),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Lỗi load dữ liệu: $_initError',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    // Status Card
                    ShadCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              OrderStatusColors.orderBadge(order.status),
                              const SizedBox(width: 8),
                              if (order.paymentStatus != null)
                                OrderStatusColors.paymentBadge(
                                  order.paymentStatus,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            order.orderCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (order.logisticsType != null) ...[
                            const SizedBox(height: 8),
                            if (originDetail?.itemType != null &&
                                originDetail!.itemType!.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.box,
                                    size: 16,
                                    color: const Color(0xFF12355B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Loại mặt hàng: ${originDetail.itemType == 'FOOD' ? 'Đồ ăn' : 'Hàng hóa khác'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0A2342),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  order.logisticsType == 'LOCKER_TO_LOCKER'
                                      ? LucideIcons.package
                                      : LucideIcons.house,
                                  size: 16,
                                  color: Colors.blue[600],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Hình thức vận chuyển: ${EnumTranslator.translateLogisticsType(order.logisticsType)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue[700],
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            EnumTranslator.translateLogisticsType(
                              order.logisticsType,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmtDate(order.createdAt),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Route Card
                    ShadCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.route, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Tuyến đường',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 36,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0C4B53),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        LucideIcons.arrowDown,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 88,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        LucideIcons.mapPin,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tủ gửi (Origin)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            originCabinetName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            originCabinetAddress,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Ngăn tủ: $originLockerLabel',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color:
                                                  AISLShadcnTheme.navyPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tủ nhận (Destination)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            destinationCabinetName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            destinationCabinetAddress,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Ngăn tủ: $destinationLockerLabel',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color:
                                                  AISLShadcnTheme.navyPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (otpCode != null &&
                        otpCode.isNotEmpty &&
                        order.status.toUpperCase() != 'FINISHED' &&
                        order.status.toUpperCase() != 'COMPLETED' &&
                        order.status.toUpperCase() != 'CANCELLED')
                      ShadCard(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.keyRound, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Mã mở tủ (OTP)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AISLShadcnTheme.navyPrimary.withOpacity(
                                  0.06,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AISLShadcnTheme.navyPrimary
                                      .withOpacity(0.4),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  otpCode,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                    color: AISLShadcnTheme.navyPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),

                    ShadCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.receipt, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Thông tin phí',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Đơn giá',
                            _fmtCurrency(
                              order.shippingUnitPrice ?? order.currentRate,
                            ),
                          ),
                          _infoRow(
                            'Phí tích lũy',
                            _fmtCurrency(order.accumulatedFee),
                            valueColor: Colors.red,
                          ),
                          _infoRow(
                            'Tổng đã thu',
                            _fmtCurrency(order.totalCollected),
                            valueColor: Colors.red,
                          ),
                          if (order.lastBillingAt != null)
                            _infoRow(
                              'Tính phí lần cuối',
                              _fmtDate(order.lastBillingAt),
                              valueColor: Colors.red,
                            ),
                          if (order.accumulatedFee != order.totalCollected) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  unawaited(_handlePayDebt(context, order));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Thanh toán nợ phí',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    ShadCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.user, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Người gửi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Địa chỉ',
                            senderAddress,
                            valueColor: Colors.black87,
                          ),
                          if (order.logisticsType == 'LOCKER_TO_LOCKER')
                            _infoRow(
                              'Ngăn tủ',
                              originLockerLabel,
                              valueColor: AISLShadcnTheme.navyPrimary,
                              valueFontWeight: FontWeight.w900,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    ShadCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.userRound, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Người nhận',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Người nhận',
                            receiverName,
                            valueColor: Colors.black87,
                          ),
                          if (receiverPhoneRaw != null &&
                              receiverPhone.isNotEmpty) ...[
                            _infoRow(
                              'SĐT',
                              receiverPhone,
                              valueFontWeight: FontWeight.w900,
                              valueColor: Colors.black87,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final phone = receiverPhone.trim();
                                  if (phone.isEmpty) return;
                                  final uri = Uri.parse('tel:$phone');
                                  await launchUrl(uri);
                                },
                                icon: const Icon(Icons.phone),
                                label: const Text(
                                  'Gọi điện',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: BorderSide(
                                    color: AISLShadcnTheme.navyPrimary
                                        .withOpacity(0.35),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          _infoRow(
                            'Ngăn tủ',
                            destinationLockerLabel,
                            valueColor: AISLShadcnTheme.navyPrimary,
                            valueFontWeight: FontWeight.w900,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ghi chú',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            noteText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (shipmentDetailsInOrder.isNotEmpty)
                      ...shipmentDetailsInOrder.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ShadCard(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.package,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Builder(
                                            builder: (context) {
                                              final isOrigin =
                                                  originDetail != null &&
                                                  detail.id == originDetail.id;
                                              final title = isOrigin
                                                  ? 'Thông tin lấy hàng'
                                                  : 'Thông tin giao hàng';
                                              return Text(
                                                title,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    OrderStatusColors.detailBadge(
                                      detail.status,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (detail.row != null && detail.column != null)
                                  _infoRow(
                                    'Ngăn tủ',
                                    detail.formattedPosition,
                                    valueColor: AISLShadcnTheme.navyPrimary,
                                    valueFontWeight: FontWeight.w900,
                                  ),
                                if (detail.hwStatus != null &&
                                    detail.hwStatus!.isNotEmpty)
                                  _infoRow(
                                    'Trạng thái tủ',
                                    EnumTranslator.translateHwStatus(
                                      detail.hwStatus!,
                                    ),
                                  ),
                                if (detail.pickedUpAt != null)
                                  _infoRow(
                                    'Lấy hàng lúc',
                                    _fmtDate(detail.pickedUpAt),
                                  ),
                                if (detail.itemType != null)
                                  _infoRow(
                                    'Loại hàng',
                                    EnumTranslator.translateItemType(
                                      detail.itemType!,
                                    ),
                                  ),
                                if (detail.overdueFee > 0)
                                  _infoRow(
                                    'Phí quá hạn',
                                    _fmtCurrency(detail.overdueFee),
                                    valueColor: const Color(0xFFD32F2F),
                                  ),
                                Builder(
                                  builder: (context) {
                                    final isOrigin =
                                        originDetail != null &&
                                        detail.id == originDetail.id;
                                    return _buildPhotoEvidence(
                                      detail,
                                      title: isOrigin
                                          ? 'Hình ảnh lấy hàng'
                                          : 'Hình ảnh giao hàng',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._buildCourierFallbackShipmentCards(
                        courierProvider: courierProvider,
                      ),
                    _buildStatusActionButton(order, details),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Order _fallbackOrder() {
    final now = DateTime.now();
    return Order(
      id: widget.job.orderId,
      orderCode: widget.job.orderCode,
      rentalCabinetId: null,
      originCabinetId: widget.job.order.originCabinetId,
      destinationCabinetId: widget.job.order.destinationCabinetId,
      userId: widget.job.orderId,
      orderType: 'LOGISTICS',
      currentRate: widget.job.income / 2,
      accumulatedFee: widget.job.income,
      totalCollected: widget.job.income,
      lastBillingAt: widget.job.time,
      status: widget.job.status,
      paymentStatus: widget.job.status == 'COMPLETED' ? 'PAID' : 'UNPAID',
      transactionId: null,
      closedAt: null,
      plannedEndTime: null,
      isPrepaid: true,
      createdAt: widget.job.time ?? now,
      updatedAt: widget.job.time ?? now,
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: valueFontWeight ?? FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCourierFallbackShipmentCards({
    required CourierDeliveryProvider courierProvider,
  }) {
    final originLocker = courierProvider.activeOrder?.formattedPosition;
    final destinationLocker = courierProvider.destinationLockerLabel;

    String lockerOrPlaceholder(String? v) =>
        (v == null || v.trim().isEmpty || v == 'N/A') ? '--' : v.trim();

    Widget card({required String header, required String lockerLabel}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShadCard(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.package, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    header,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(
                'Ngăn tủ',
                lockerLabel,
                valueColor: AISLShadcnTheme.navyPrimary,
                valueFontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
      );
    }

    return [
      card(
        header: 'Thông tin giao nhận - Lấy hàng',
        lockerLabel: lockerOrPlaceholder(originLocker),
      ),
      card(
        header: 'Thông tin giao nhận - Giao hàng',
        lockerLabel: lockerOrPlaceholder(destinationLocker),
      ),
    ];
  }

  String? _actionLabelForStatus(String? status, {bool isCourier = true}) {
    final s = status?.toUpperCase();
    if (s == 'AWAITING_COURIER') {
      return isCourier ? 'Mở tủ lấy hàng' : 'Mở tủ tạm thời';
    }
    if (s == 'ACTIVE') {
      return isCourier ? 'Mở tủ giao hàng' : null;
    }
    return null;
  }

  Widget _buildStatusActionButton(Order order, List<OrderDetail> details) {
    final isCourierMode = context
        .watch<CourierModeProvider>()
        .isCourierModeActive;
    final label = _actionLabelForStatus(order.status, isCourier: isCourierMode);

    // Only show Hủy đơn button if order is in AWAITING_COURIER or ACTIVE status and in courier mode
    final canCancel =
        isCourierMode &&
        (order.status == 'AWAITING_COURIER' || order.status == 'ACTIVE');

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          if (label != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final deliveryProvider = context
                      .read<CourierDeliveryProvider>();
                  final lockerProvider = context.read<LockerProvider>();

                  if (order.status == 'AWAITING_COURIER') {
                    if (isCourierMode) {
                      if (widget.job.order.dispatchId == null ||
                          widget.job.order.dispatchId!.trim().isEmpty) {
                        SmartDialog.showToast('Thiếu dispatchId để nhận đơn.');
                        return;
                      }

                      if (deliveryProvider.activeOrder == null) {
                        await deliveryProvider.acceptOrder(
                          widget.job.order.dispatchId!,
                        );
                      }

                      final lockerId = deliveryProvider.lockerIdForDeposit;
                      if (lockerId == null || lockerId.trim().isEmpty) {
                        SmartDialog.showToast(
                          'Không tìm thấy lockerId để mở tủ lấy hàng.',
                        );
                        return;
                      }

                      SmartDialog.showLoading<void>(msg: 'Đang mở tủ...');
                      final ok = await deliveryProvider.openLocker(
                        lockerId,
                        orderCode: order.orderCode,
                      );
                      SmartDialog.dismiss<void>();

                      SmartDialog.showToast(
                        ok
                            ? 'Đã gửi lệnh mở tủ lấy hàng.'
                            : (deliveryProvider.error ?? 'Mở tủ thất bại.'),
                      );
                    } else {
                      // Customer role - Open source locker temporarily
                      final sourceLockerId = details.isNotEmpty
                          ? details.first.lockerId
                          : null;
                      if (sourceLockerId == null) {
                        SmartDialog.showToast(
                          'Không tìm thấy thông tin tủ gửi.',
                        );
                        return;
                      }

                      SmartDialog.showLoading<void>(msg: 'Đang mở tủ gửi...');
                      final result = await lockerProvider.openLockerTemporarily(
                        sourceLockerId,
                      );
                      SmartDialog.dismiss<void>();

                      result.fold(
                        (failure) =>
                            SmartDialog.showToast('Lỗi: ${failure.message}'),
                        (_) =>
                            SmartDialog.showToast('Đã mở tủ gửi thành công.'),
                      );
                    }
                    return;
                  }

                  if (order.status == 'ACTIVE' && isCourierMode) {
                    final sorted = [...details]
                      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    final destinationDetail = sorted.isNotEmpty
                        ? sorted.last
                        : null;

                    final lockerIdFromDetail = destinationDetail?.lockerId
                        ?.trim();
                    final lockerLabelFromDetail = destinationDetail?.lockerLabel
                        ?.trim();

                    final lockerId =
                        (lockerIdFromDetail != null &&
                            lockerIdFromDetail.isNotEmpty)
                        ? lockerIdFromDetail
                        : ((lockerLabelFromDetail != null &&
                                  lockerLabelFromDetail.isNotEmpty)
                              ? lockerLabelFromDetail
                              : deliveryProvider.destinationLockerIdForDeposit);

                    if (lockerId == null || lockerId.trim().isEmpty) {
                      SmartDialog.showToast(
                        'Không tìm thấy lockerId để mở tủ giao hàng.',
                      );
                      return;
                    }

                    SmartDialog.showLoading<void>(msg: 'Đang mở tủ...');
                    final ok = await deliveryProvider.openLocker(
                      lockerId,
                      orderCode: order.orderCode,
                    );
                    SmartDialog.dismiss<void>();

                    SmartDialog.showToast(
                      ok
                          ? 'Đã gửi lệnh mở tủ giao hàng.'
                          : (deliveryProvider.error ?? 'Mở tủ thất bại.'),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AISLShadcnTheme.navyPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (canCancel) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: const Icon(
                  LucideIcons.circleSlash,
                  color: Colors.red,
                  size: 20,
                ),
                label: const Text(
                  'Hủy đơn hàng',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final reasonCtl = TextEditingController();
    final result = await SmartDialog.show<bool>(
      builder: (ctx) => Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hủy đơn hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Xác nhận hủy đơn hàng này? Khách hàng sẽ được hoàn tiền 100%.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lý do hủy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: reasonCtl,
              placeholder: const Text(
                'Nhập lý do hủy (VD: Khách không gửi đồ quá lâu)',
              ),
              style: const TextStyle(color: Colors.black),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () => SmartDialog.dismiss(result: false),
                    child: const Text('Bỏ qua'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadButton.destructive(
                    onPressed: () {
                      if (reasonCtl.text.trim().isEmpty) {
                        SmartDialog.showToast('Vui lòng nhập lý do hủy');
                        return;
                      }
                      SmartDialog.dismiss(result: true);
                    },
                    child: const Text('Xác nhận hủy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      SmartDialog.showLoading<void>(msg: 'Đang xử lý hủy đơn...');
      final success = await _courierDeliveryProvider.cancelOrder(
        widget.job.orderId,
        reasonCtl.text.trim(),
      );
      SmartDialog.dismiss<void>();
      if (success && context.mounted) {
        SmartDialog.showToast('Đã hủy đơn hàng thành công');
        Navigator.of(context).pop();
      }
    }
    reasonCtl.dispose();
  }

  Future<void> _handlePayDebt(BuildContext context, Order order) async {
    SmartDialog.showLoading<void>(msg: 'Đang xử lý thanh toán...');
    final success = await _provider.payOverdueFee(order.id);
    SmartDialog.dismiss<void>();

    if (success) {
      SmartDialog.showToast('Thanh toán thành công!');
    } else {
      SmartDialog.showToast('Lỗi: ${_provider.error ?? "Thanh toán thất bại"}');
    }
  }

  Widget _buildPhotoEvidence(OrderDetail detail, {required String title}) {
    if (detail.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(LucideIcons.camera, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: detail.imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  detail.imageUrls[index],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: const Icon(
                      LucideIcons.image,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleReportIssue(
    BuildContext context,
    Order order,
    List<OrderDetail> details,
  ) async {
    final sorted = [...details]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final originDetail = sorted.isNotEmpty ? sorted.first : null;
    final destDetail = (sorted.length > 1) ? sorted.last : originDetail;

    final isPickingUp = order.status.toUpperCase() == 'AWAITING_COURIER';
    final activeDetail = isPickingUp ? originDetail : destDetail;
    final cabinetId = isPickingUp
        ? (order.originCabinetId ?? '')
        : (order.destinationCabinetId ?? '');

    if (activeDetail == null || activeDetail.lockerId == null) {
      SmartDialog.showToast('Không tìm thấy thông tin tủ');
      return;
    }
    if (cabinetId.isEmpty) {
      SmartDialog.showToast('Không có thông tin trạm tủ');
      return;
    }

    SmartDialog.showLoading<void>(msg: 'Đang lấy thông tin tủ...');
    final lockerId = activeDetail.lockerId!;
    final cabinet = await _lockerProvider.getCabinetById(cabinetId);
    final locker = await _lockerProvider.getLockerById(lockerId);
    SmartDialog.dismiss<void>();

    if (cabinet == null || locker == null) {
      SmartDialog.showToast('Không lấy được thông tin chi tiết tủ, sử dụng ID');
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CreateReportPage(
          cabinetId: cabinetId,
          lockerId: lockerId,
          cabinetName: cabinet?.name ?? cabinetId,
          lockerName: locker != null
              ? locker.displayPosition
              : activeDetail.lockerLabel,
          locationName: cabinet?.locationName,
        ),
      ),
    );
  }
}
