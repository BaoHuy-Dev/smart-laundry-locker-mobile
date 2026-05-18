import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/core.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/payment.dart';
import '../../../../core/models/service.dart';
import '../../../../core/services/laundry_service_api.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/promotion_service.dart';

class ConfirmOrderScreen extends ConsumerStatefulWidget {
  const ConfirmOrderScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.lockerId,
    required this.lockerName,
    required this.boxId,
    required this.boxNumber,
    required this.category,
    required this.serviceIds,
    this.prefilledPromoCode,
  });

  final int storeId;
  final String storeName;
  final int lockerId;
  final String lockerName;
  final int boxId;
  final String boxNumber;
  final ServiceCategory category;
  final List<int> serviceIds;
  final String? prefilledPromoCode;

  @override
  ConsumerState<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends ConsumerState<ConfirmOrderScreen> {
  final _noteController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _estimatedWeightController = TextEditingController();
  final _promotionController = TextEditingController();

  List<LaundryService> _services = [];
  List<PromotionValidateResponse> _promotions = [];
  PromotionValidateResponse? _appliedPromotion;
  double _promotionDiscount = 0;
  bool _sendToOther = false;
  DateTime? _intendedReceiveAt;
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;

  bool get _isStorage => widget.category == ServiceCategory.storage;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledPromoCode?.isNotEmpty == true) {
      _promotionController.text = widget.prefilledPromoCode!;
    }
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _estimatedWeightController.dispose();
    _promotionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final serviceResponse = await LaundryServiceAPI.getServicesByCategory(
        widget.category,
      );
      var promotions = <PromotionValidateResponse>[];
      try {
        final promotionResponse = await PromotionService.getActivePromotions();
        promotions = promotionResponse.data;
      } catch (_) {
        // Promotions are optional on the confirm screen.
      }

      final allServices = serviceResponse.data;
      final selected = allServices
          .where((service) => widget.serviceIds.contains(service.id))
          .toList();

      DateTime? intended;
      final mainService = selected.isNotEmpty ? selected.first : null;
      final fixedHours =
          mainService?.estimatedTime ?? mainService?.estimatedHours;
      if (fixedHours != null && fixedHours > 0) {
        intended = DateTime.now().add(Duration(hours: fixedHours));
      }

      if (mounted) {
        setState(() {
          _services = selected;
          _promotions = promotions;
          _intendedReceiveAt = intended;
        });
      }

      if (_promotionController.text.trim().isNotEmpty) {
        await _applyPromotion();
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải thông tin đơn hàng');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _subtotal =>
      _services.fold(0, (sum, service) => sum + service.price);
  double get _total =>
      (_subtotal - _promotionDiscount).clamp(0.0, double.infinity).toDouble();

  Future<void> _applyPromotion([PromotionValidateResponse? selected]) async {
    final code = selected?.code ?? _promotionController.text.trim();
    if (code.isEmpty) return;

    try {
      final promo =
          selected ?? (await PromotionService.validatePromotionCode(code)).data;
      if (promo.minOrderAmount != null && _subtotal < promo.minOrderAmount!) {
        _showMessage(
          'Đơn tối thiểu ${formatCurrency(promo.minOrderAmount)} để áp dụng mã này',
        );
        return;
      }
      setState(() {
        _promotionController.text = promo.code;
        _appliedPromotion = promo;
        _promotionDiscount = PromotionService.calculateDiscount(
          promo,
          _subtotal,
        );
      });
    } catch (_) {
      _showMessage('Mã khuyến mãi không hợp lệ');
    }
  }

  void _removePromotion() {
    setState(() {
      _promotionController.clear();
      _appliedPromotion = null;
      _promotionDiscount = 0;
    });
  }

  Future<void> _pickReceiveDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate:
          _intendedReceiveAt ?? DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_intendedReceiveAt ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _intendedReceiveAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createOrder() async {
    if (_services.isEmpty) {
      _showMessage('Không có dịch vụ được chọn');
      return;
    }
    if (_isStorage && _sendToOther) {
      if (_receiverNameController.text.trim().isEmpty ||
          _receiverPhoneController.text.trim().isEmpty) {
        _showMessage('Vui lòng nhập thông tin người nhận');
        return;
      }
    }

    setState(() => _isCreating = true);
    try {
      final estimatedWeight = double.tryParse(
        _estimatedWeightController.text.trim(),
      );
      final payload = OrderService.createOrderPayload(
        type: _isStorage ? OrderType.storage : OrderType.laundry,
        lockerId: widget.lockerId,
        boxId: widget.boxId,
        serviceIds: widget.serviceIds,
        customerNote: _noteController.text,
        promotionCode: _appliedPromotion?.code,
        estimatedWeight: _isStorage ? null : estimatedWeight,
        intendedReceiveAt: _isStorage ? _intendedReceiveAt : null,
        receiverName: _sendToOther ? _receiverNameController.text : null,
        receiverPhone: _sendToOther ? _receiverPhoneController.text : null,
      );

      final response = await OrderService.createOrder(payload);
      final order = response.data;

      try {
        await OrderService.confirmOrder(order.id);
      } catch (_) {
        // Same best-effort behavior as the RN flow.
      }

      if (mounted) await _showCreatedDialog(order);
    } catch (_) {
      _showMessage('Không thể tạo đơn hàng. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _showCreatedDialog(Order order) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tạo đơn thành công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã đơn: #${order.id}'),
            if ((order.pinCode ?? order.pin)?.isNotEmpty == true)
              Text('Mã PIN: ${order.pinCode ?? order.pin}'),
            const SizedBox(height: 12),
            const Text(
              'Bạn có thể thanh toán ngay hoặc xem lại trong Đơn hàng.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/user/orders');
            },
            child: const Text('Xem đơn hàng'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _payMomo(order.id);
            },
            child: const Text('Thanh toán MoMo'),
          ),
        ],
      ),
    );
  }

  Future<void> _payMomo(int orderId) async {
    try {
      final response = await PaymentService.createPayment(
        orderId,
        PaymentMethod.momo,
      );
      final url = response.data.paymentUrl;
      if (url == null || url.isEmpty) {
        _showMessage('Đã tạo thanh toán nhưng chưa có URL');
        return;
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      _showMessage('Không thể tạo thanh toán MoMo');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(title: const Text('Xác nhận & thanh toán')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_promotionDiscount > 0)
                      Text(
                        formatCurrency(_subtotal),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      formatCurrency(_total),
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _isCreating || _isLoading ? null : _createOrder,
                child: _isCreating
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tạo đơn'),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _SummaryCard(widget: widget),
                const SizedBox(height: 16),
                _sectionTitle('Dịch vụ đã chọn'),
                ..._services.map(_serviceTile),
                const SizedBox(height: 16),
                _sectionTitle('Thông tin bổ sung'),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú cho đơn hàng',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (!_isStorage) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _estimatedWeightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ước tính khối lượng (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (_isStorage) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _sendToOther,
                    onChanged: (value) => setState(() => _sendToOther = value),
                    title: const Text('Gửi cho người khác nhận'),
                  ),
                  if (_sendToOther) ...[
                    TextField(
                      controller: _receiverNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên người nhận',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _receiverPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại người nhận',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickReceiveDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _intendedReceiveAt == null
                          ? 'Chọn thời gian nhận'
                          : formatDateTimeText(
                              _intendedReceiveAt!.toIso8601String(),
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _sectionTitle('Voucher'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promotionController,
                        enabled: _appliedPromotion == null,
                        decoration: const InputDecoration(
                          labelText: 'Mã khuyến mãi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _appliedPromotion == null
                        ? FilledButton(
                            onPressed: _applyPromotion,
                            child: const Text('Áp dụng'),
                          )
                        : IconButton(
                            onPressed: _removePromotion,
                            icon: const Icon(Icons.close),
                          ),
                  ],
                ),
                if (_appliedPromotion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Đã áp dụng ${_appliedPromotion!.code}: -${formatCurrency(_promotionDiscount)}',
                      style: const TextStyle(color: AppColors.successColor),
                    ),
                  ),
                if (_promotions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _promotions
                        .take(6)
                        .map(
                          (promo) => ActionChip(
                            label: Text(promo.code),
                            onPressed: () => _applyPromotion(promo),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _serviceTile(LaundryService service) {
    return Card(
      child: ListTile(
        title: Text(service.name),
        subtitle: Text(service.description ?? serviceUnitLabel(service.unit)),
        trailing: Text(
          formatCurrency(service.price),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.widget});

  final ConfirmOrderScreen widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.storeName,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.lockerName} - Ngăn số ${widget.boxNumber}',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.category == ServiceCategory.laundry ? 'Giặt đồ' : 'Gửi đồ',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
