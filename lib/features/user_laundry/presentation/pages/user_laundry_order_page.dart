import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/models/user_laundry_models.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_laundry_service.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_locker_service.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_order_service.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UserLaundryOrderPage extends StatefulWidget {
  const UserLaundryOrderPage({super.key});

  @override
  State<UserLaundryOrderPage> createState() => _UserLaundryOrderPageState();
}

class _UserLaundryOrderPageState extends State<UserLaundryOrderPage> {
  final _noteController = TextEditingController();
  final _promoController = TextEditingController();

  late final UserLockerService _lockerService;
  late final UserLaundryService _laundryService;
  late final UserOrderService _orderService;
  late final UserPaymentService _paymentService;

  List<UserLaundryStore> _stores = const [];
  List<UserLaundryLocker> _lockers = const [];
  List<UserLaundryBox> _boxes = const [];
  List<UserLaundryServiceItem> _services = const [];

  UserLaundryStore? _selectedStore;
  UserLaundryLocker? _selectedLocker;
  UserLaundryBox? _selectedBox;
  final Set<int> _selectedServiceIds = {};
  String _category = 'LAUNDRY';

  UserLaundryOrder? _createdOrder;
  UserLaundryPayment? _payment;

  bool _loadingStores = false;
  bool _loadingLockers = false;
  bool _loadingBoxes = false;
  bool _loadingServices = false;
  bool _submitting = false;
  bool _checkingStatus = false;

  String? _pageError;
  String? _serviceWarning;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _lockerService = UserLockerService(apiClient);
    _laundryService = UserLaundryService(apiClient);
    _orderService = UserOrderService(apiClient);
    _paymentService = UserPaymentService(apiClient);
    _loadInitialData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _services
        .where((service) => _selectedServiceIds.contains(service.id))
        .fold<double>(0, (sum, service) => sum + service.price);
  }

  bool get _canCreateOrder {
    return !_submitting &&
        _selectedStore != null &&
        _selectedLocker != null &&
        _selectedBox != null &&
        _selectedServiceIds.isNotEmpty;
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadStores(), _loadServices()]);
  }

  Future<void> _loadStores() async {
    setState(() {
      _loadingStores = true;
      _pageError = null;
    });

    try {
      final stores = await _lockerService.getStores();
      if (!mounted) return;
      setState(() => _stores = stores);
    } catch (error) {
      if (!mounted) return;
      setState(() => _pageError = 'Khong tai duoc danh sach cua hang.');
    } finally {
      if (mounted) setState(() => _loadingStores = false);
    }
  }

  Future<void> _loadLockers(UserLaundryStore store) async {
    setState(() {
      _selectedStore = store;
      _selectedLocker = null;
      _selectedBox = null;
      _lockers = const [];
      _boxes = const [];
      _loadingLockers = true;
      _pageError = null;
    });

    try {
      final lockers = await _lockerService.getLockersByStore(store.id);
      if (!mounted) return;
      setState(() => _lockers = lockers);
      await _loadServices();
    } catch (error) {
      if (!mounted) return;
      setState(() => _pageError = 'Khong tai duoc locker cua cua hang nay.');
    } finally {
      if (mounted) setState(() => _loadingLockers = false);
    }
  }

  Future<void> _loadBoxes(UserLaundryLocker locker) async {
    setState(() {
      _selectedLocker = locker;
      _selectedBox = null;
      _boxes = const [];
      _loadingBoxes = true;
      _pageError = null;
    });

    try {
      final boxes = await _lockerService.getAvailableBoxes(locker.id);
      if (!mounted) return;
      setState(() => _boxes = boxes);
    } catch (error) {
      if (!mounted) return;
      setState(() => _pageError = 'Khong tai duoc box con trong.');
    } finally {
      if (mounted) setState(() => _loadingBoxes = false);
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _serviceWarning = null;
      _selectedServiceIds.clear();
    });

    try {
      final services = await _laundryService.getServices(
        category: _category,
        storeId: _selectedStore?.id,
      );
      if (!mounted) return;
      setState(() => _services = services);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _services = const [];
        _serviceWarning =
            'Backend chua tra ve danh muc dich vu qua /api/services.';
      });
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  Future<void> _createOrder() async {
    final store = _selectedStore;
    final locker = _selectedLocker;
    final box = _selectedBox;
    if (store == null || locker == null || box == null) return;

    setState(() {
      _submitting = true;
      _pageError = null;
    });

    try {
      var order = await _orderService.createLaundryOrder(
        storeId: store.id,
        lockerId: locker.id,
        sendBoxId: box.id,
        serviceCategory: _category,
        type: _category,
        serviceIds: _selectedServiceIds.toList(),
        customerNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        promotionCode: _promoController.text.trim().isEmpty
            ? null
            : _promoController.text.trim(),
        totalPrice: _subtotal > 0 ? _subtotal : null,
      );

      try {
        order = await _orderService.confirmOrder(order.id);
      } catch (_) {
        // Some backend states do not require a separate confirm call.
      }

      if (!mounted) return;
      setState(() => _createdOrder = order);
      SmartDialog.showToast('Da tao don USER thanh cong.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _pageError = 'Khong tao duoc don. Vui long kiem tra API.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _createPayment() async {
    final order = _createdOrder;
    if (order == null) return;
    final amount = order.totalPrice ?? _subtotal;
    if (amount <= 0) {
      SmartDialog.showToast('Don hang chua co so tien thanh toan.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final payment = await _paymentService.createPayment(
        orderId: order.id,
        amount: amount,
        method: 'MOMO',
        description: 'Thanh toan don ${order.orderCode ?? order.id}',
      );
      if (!mounted) return;
      setState(() => _payment = payment);
      await _openPayment(payment);
    } catch (error) {
      SmartDialog.showToast('Khong tao duoc thanh toan.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openPayment(UserLaundryPayment payment) async {
    final target = payment.deeplink ?? payment.paymentUrl;
    if (target == null || target.isEmpty) return;
    final uri = Uri.tryParse(target);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _refreshOrderStatus() async {
    final order = _createdOrder;
    if (order == null) return;

    setState(() => _checkingStatus = true);
    try {
      final next = await _orderService.getOrderStatus(order.id);
      if (!mounted) return;
      setState(() => _createdOrder = next);
    } catch (error) {
      SmartDialog.showToast('Khong cap nhat duoc trang thai don.');
    } finally {
      if (mounted) setState(() => _checkingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AISLShadcnTheme.navySurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tao don giat',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildHeader(),
            if (_pageError != null) ...[
              const SizedBox(height: 12),
              _buildMessage(_pageError!, isError: true),
            ],
            const SizedBox(height: 16),
            _buildStoreSection(),
            const SizedBox(height: 16),
            _buildLockerSection(),
            const SizedBox(height: 16),
            _buildBoxSection(),
            const SizedBox(height: 16),
            _buildServiceSection(),
            const SizedBox(height: 16),
            _buildNoteSection(),
            const SizedBox(height: 16),
            _buildSummarySection(),
            if (_createdOrder != null) ...[
              const SizedBox(height: 16),
              _buildCreatedOrderSection(_createdOrder!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AISLShadcnTheme.navyPrimary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.washingMachine, color: Colors.white, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'USER laundry flow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Store, locker, box, service, order, payment.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection() {
    return _Section(
      icon: LucideIcons.store,
      title: '1. Chon cua hang',
      trailing: _loadingStores ? const _TinyLoader() : null,
      child: _stores.isEmpty && !_loadingStores
          ? _buildEmpty('Chua co cua hang tu /api/stores.')
          : Column(
              children: _stores
                  .map(
                    (store) => _SelectableTile(
                      selected: _selectedStore?.id == store.id,
                      title: store.name,
                      subtitle: store.address ?? store.contactPhone ?? '',
                      icon: LucideIcons.store,
                      onTap: () => _loadLockers(store),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildLockerSection() {
    return _Section(
      icon: LucideIcons.box,
      title: '2. Chon locker',
      trailing: _loadingLockers ? const _TinyLoader() : null,
      child: _selectedStore == null
          ? _buildEmpty('Chon cua hang truoc.')
          : _lockers.isEmpty && !_loadingLockers
          ? _buildEmpty('Cua hang nay chua co locker.')
          : Column(
              children: _lockers
                  .map(
                    (locker) => _SelectableTile(
                      selected: _selectedLocker?.id == locker.id,
                      title: locker.name,
                      subtitle: '${locker.code} - ${locker.status}',
                      icon: LucideIcons.archive,
                      onTap: () => _loadBoxes(locker),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildBoxSection() {
    return _Section(
      icon: LucideIcons.packageOpen,
      title: '3. Chon box trong',
      trailing: _loadingBoxes ? const _TinyLoader() : null,
      child: _selectedLocker == null
          ? _buildEmpty('Chon locker truoc.')
          : _boxes.isEmpty && !_loadingBoxes
          ? _buildEmpty('Locker nay khong con box trong.')
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _boxes
                  .map(
                    (box) => ChoiceChip(
                      selected: _selectedBox?.id == box.id,
                      label: Text('${box.displayName} - ${box.size}'),
                      onSelected: (_) => setState(() => _selectedBox = box),
                      selectedColor: AISLShadcnTheme.navyPrimary,
                      labelStyle: TextStyle(
                        color: _selectedBox?.id == box.id
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildServiceSection() {
    return _Section(
      icon: LucideIcons.listChecks,
      title: '4. Chon dich vu',
      trailing: _loadingServices ? const _TinyLoader() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                selected: _category == 'LAUNDRY',
                label: const Text('Laundry'),
                onSelected: (_) {
                  setState(() => _category = 'LAUNDRY');
                  _loadServices();
                },
              ),
              ChoiceChip(
                selected: _category == 'STORAGE',
                label: const Text('Storage'),
                onSelected: (_) {
                  setState(() => _category = 'STORAGE');
                  _loadServices();
                },
              ),
            ],
          ),
          if (_serviceWarning != null) ...[
            const SizedBox(height: 12),
            _buildMessage(_serviceWarning!, isError: false),
          ],
          if (_services.isEmpty && !_loadingServices) ...[
            const SizedBox(height: 12),
            _buildEmpty('Chua co dich vu cho category $_category.'),
          ],
          ..._services.map(_buildServiceTile),
        ],
      ),
    );
  }

  Widget _buildServiceTile(UserLaundryServiceItem service) {
    final selected = _selectedServiceIds.contains(service.id);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          selected
              ? _selectedServiceIds.remove(service.id)
              : _selectedServiceIds.add(service.id);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AISLShadcnTheme.navyPrimary.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AISLShadcnTheme.navyPrimary
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              color: selected ? AISLShadcnTheme.navyPrimary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  if (service.description != null &&
                      service.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        service.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _currencyFormatter.format(service.price),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AISLShadcnTheme.navyPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return _Section(
      icon: LucideIcons.notepadText,
      title: '5. Ghi chu va uu dai',
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            decoration: _inputDecoration('Ghi chu cho cua hang'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promoController,
            decoration: _inputDecoration('Ma khuyen mai neu co'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return _Section(
      icon: LucideIcons.receiptText,
      title: '6. Xac nhan don',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Cua hang', value: _selectedStore?.name ?? '-'),
          _SummaryRow(label: 'Locker', value: _selectedLocker?.name ?? '-'),
          _SummaryRow(label: 'Box', value: _selectedBox?.displayName ?? '-'),
          _SummaryRow(label: 'Dich vu', value: '${_selectedServiceIds.length}'),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Tam tinh',
            value: _currencyFormatter.format(_subtotal),
            bold: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canCreateOrder ? _createOrder : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.send, size: 18),
              label: const Text('Tao don'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AISLShadcnTheme.navyPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildCreatedOrderSection(UserLaundryOrder order) {
    return _Section(
      icon: LucideIcons.packageCheck,
      title: 'Don vua tao',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Ma don', value: order.orderCode ?? '${order.id}'),
          _SummaryRow(label: 'Trang thai', value: order.status, bold: true),
          if (order.pinCode != null)
            _SummaryRow(label: 'PIN', value: order.pinCode!),
          if (order.nextActionMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildMessage(order.nextActionMessage!, isError: false),
            ),
          if (_payment != null) ...[
            const Divider(height: 24),
            _SummaryRow(label: 'Thanh toan', value: _payment!.status),
            if (_payment!.paymentUrl != null)
              Text(
                _payment!.paymentUrl!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _checkingStatus ? null : _refreshOrderStatus,
                  icon: _checkingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Cap nhat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _createPayment,
                  icon: const Icon(LucideIcons.creditCard, size: 16),
                  label: const Text('Thanh toan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AISLShadcnTheme.navyPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AISLShadcnTheme.navyPrimary),
      ),
    );
  }

  Widget _buildEmpty(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  Widget _buildMessage(String text, {required bool isError}) {
    final color = isError ? Colors.red.shade700 : Colors.orange.shade700;
    final bg = isError ? Colors.red.shade50 : Colors.orange.shade50;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? LucideIcons.circleAlert : LucideIcons.info,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AISLShadcnTheme.navyPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AISLShadcnTheme.navyPrimary.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AISLShadcnTheme.navyPrimary
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AISLShadcnTheme.navyPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.chevronRight,
              color: selected ? AISLShadcnTheme.navyPrimary : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyLoader extends StatelessWidget {
  const _TinyLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
