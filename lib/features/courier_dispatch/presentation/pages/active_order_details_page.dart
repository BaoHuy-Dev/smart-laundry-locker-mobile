import 'dart:async';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/locker/domain/entities/cabinet.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_provider.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_injection.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order_detail.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_injection.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_provider.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/order_status_colors.dart';
import 'package:smart_laundry_locker/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;
import 'package:url_launcher/url_launcher.dart';

class ActiveOrderDetailsPage extends StatefulWidget {
  final CourierOrder courierOrder;
  const ActiveOrderDetailsPage({Key? key, required this.courierOrder})
    : super(key: key);

  @override
  State<ActiveOrderDetailsPage> createState() => _ActiveOrderDetailsPageState();
}

class _ActiveOrderDetailsPageState extends State<ActiveOrderDetailsPage> {
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
      await _provider.fetchOrderDetail(widget.courierOrder.orderId);

      final status =
          (_provider.selectedOrder?.status ?? widget.courierOrder.status)
              .toUpperCase();

      final hasDispatchId =
          widget.courierOrder.dispatchId != null &&
          widget.courierOrder.dispatchId!.trim().isNotEmpty;

      if ((status == 'AWAITING_COURIER' || status == 'ACTIVE') &&
          hasDispatchId) {
        if (_courierDeliveryProvider.activeOrder == null) {
          await _courierDeliveryProvider.acceptOrder(
            widget.courierOrder.dispatchId!,
          );
        }
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
      debugPrint('ActiveOrderDetailsPage init error: $e\n$s');
      if (!mounted) return;
      setState(() {
        _initError = e.toString();
      });
    }
  }

  Future<void> _loadCabinets(Order order) async {
    final originId = order.originCabinetId?.trim();
    final destinationId = order.destinationCabinetId?.trim();

    try {
      if (originId != null && originId.isNotEmpty) {
        _originCabinet = await _lockerProvider.getCabinetById(originId);
      }
      if (destinationId != null && destinationId.isNotEmpty) {
        _destinationCabinet = await _lockerProvider.getCabinetById(
          destinationId,
        );
      }
    } catch (e) {
      debugPrint('ActiveOrderDetailsPage _loadCabinets error: $e');
    }

    if (!mounted) return;
    setState(() {});
  }

  Order _fallbackOrder() {
    final now = DateTime.now();
    return Order(
      id: widget.courierOrder.orderId,
      orderCode: widget.courierOrder.orderCode,
      rentalCabinetId: null,
      originCabinetId: widget.courierOrder.originCabinetId,
      destinationCabinetId: widget.courierOrder.destinationCabinetId,
      userId: widget.courierOrder.orderId,
      orderType: 'LOGISTICS',
      currentRate: widget.courierOrder.income / 2,
      accumulatedFee: widget.courierOrder.income,
      totalCollected: widget.courierOrder.income,
      lastBillingAt: widget.courierOrder.time,
      status: widget.courierOrder.status,
      paymentStatus: widget.courierOrder.status == 'COMPLETED'
          ? 'PAID'
          : 'UNPAID',
      transactionId: null,
      closedAt: null,
      plannedEndTime: null,
      isPrepaid: true,
      createdAt: widget.courierOrder.time ?? now,
      updatedAt: widget.courierOrder.time ?? now,
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    _lockerProvider.dispose();
    super.dispose();
  }

  List<OrderDetail> _getDetails(OrderProvider provider) {
    return provider.orderDetails;
  }

  // _handlePayDebt removed as unused
  // _translateHwStatus removed as unused

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CustomAppBar(
          title: 'Chi tiết đơn hiện tại',
          centerTitle: true,
          showBackButton: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          foregroundColorButton: Colors.black,
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

              final detailsSorted = [...details]
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
              final originDetail = detailsSorted.isNotEmpty
                  ? detailsSorted.first
                  : null;
              final destinationDetail = detailsSorted.isNotEmpty
                  ? detailsSorted.last
                  : null;

              final courierProvider = context.watch<CourierDeliveryProvider>();
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

              String? pickNonEmpty(String? v) {
                final s = v?.trim();
                if (s == null || s.isEmpty) return null;
                if (s == '-' || s == '--' || s.toLowerCase() == 'null') {
                  return null;
                }
                return s;
              }

              final originLockerLabel =
                  pickNonEmpty(originDetail?.formattedLockerLabel) ??
                  pickNonEmpty(courierProvider.activeOrder?.lockerLabel) ??
                  '-';
              final destinationLockerLabel =
                  pickNonEmpty(destinationDetail?.formattedLockerLabel) ??
                  pickNonEmpty(courierProvider.destinationLockerLabel) ??
                  '-';

              final receiverNameRaw =
                  pickNonEmpty(destinationDetail?.receiverName) ??
                  pickNonEmpty(originDetail?.receiverName) ??
                  pickNonEmpty(courierProvider.activeOrder?.recipientName);
              final receiverPhoneRaw =
                  pickNonEmpty(destinationDetail?.receiverEmail) ??
                  pickNonEmpty(originDetail?.receiverEmail) ??
                  pickNonEmpty(courierProvider.activeOrder?.recipientPhone);
              final noteTextRaw =
                  pickNonEmpty(destinationDetail?.note) ??
                  pickNonEmpty(originDetail?.note);

              final originCabinetName =
                  (_originCabinet?.name.trim().isNotEmpty ?? false)
                  ? _originCabinet!.name.trim()
                  : pickNonEmpty(order.originCabinetId) ?? '-';
              final originCabinetAddress =
                  (_originCabinet?.address?.trim().isNotEmpty ?? false)
                  ? _originCabinet!.address!.trim()
                  : (_originCabinet?.locationName?.trim().isNotEmpty ?? false)
                  ? _originCabinet!.locationName!.trim()
                  : '-';

              final destinationCabinetName =
                  (_destinationCabinet?.name.trim().isNotEmpty ?? false)
                  ? _destinationCabinet!.name.trim()
                  : pickNonEmpty(order.destinationCabinetId) ?? '-';
              final destinationCabinetAddress =
                  (_destinationCabinet?.address?.trim().isNotEmpty ?? false)
                  ? _destinationCabinet!.address!.trim()
                  : (_destinationCabinet?.locationName?.trim().isNotEmpty ??
                        false)
                  ? _destinationCabinet!.locationName!.trim()
                  : '-';

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

                    shad.ShadCard(
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
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đơn đang thực hiện',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    shad.ShadCard(
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRouteInfo(
                            originCabinetName,
                            originCabinetAddress,
                            originLockerLabel,
                            destinationCabinetName,
                            destinationCabinetAddress,
                            destinationLockerLabel,
                          ),
                        ],
                      ),
                    ),

                    if (otpCode != null &&
                        otpCode.isNotEmpty &&
                        order.status.toUpperCase() != 'FINISHED' &&
                        order.status.toUpperCase() != 'COMPLETED') ...[
                      const SizedBox(height: 12),
                      shad.ShadCard(
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
                    ],

                    const SizedBox(height: 12),
                    _buildContactCard('Người gửi', senderAddress, null),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      'Người nhận',
                      receiverName,
                      receiverPhone,
                      note: noteText,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo(
    String originName,
    String originAddr,
    String originLocker,
    String destName,
    String destAddr,
    String destLocker,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              const Icon(LucideIcons.circleDot, size: 20, color: Colors.blue),
              Container(width: 2, height: 50, color: Colors.grey[200]),
              const Icon(LucideIcons.mapPin, size: 20, color: Colors.red),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                originName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                originAddr,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Ngăn: $originLocker',
                style: const TextStyle(
                  fontSize: 12,
                  color: AISLShadcnTheme.navyPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                destName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                destAddr,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Ngăn: $destLocker',
                style: const TextStyle(
                  fontSize: 12,
                  color: AISLShadcnTheme.navyPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    String title,
    String name,
    String? phone, {
    String? note,
  }) {
    return shad.ShadCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'SĐT:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                ),
              ],
            ),
          ],
          if (note != null && note.isNotEmpty && note != '--') ...[
            const Divider(),
            Text(
              'Ghi chú:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(note, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
