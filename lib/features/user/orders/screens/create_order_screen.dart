import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/models/service.dart';
import '../../../../core/services/laundry_service_api.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({
    super.key,
    this.storeId,
    this.storeName,
    this.lockerId,
    this.lockerName,
    this.boxId,
    this.boxNumber,
  });

  final int? storeId;
  final String? storeName;
  final int? lockerId;
  final String? lockerName;
  final int? boxId;
  final String? boxNumber;

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  ServiceCategory _category = ServiceCategory.laundry;
  List<LaundryService> _services = [];
  final Set<int> _selectedServices = {};
  bool _isLoading = true;
  String? _error;

  bool get _hasLockerContext =>
      widget.storeId != null && widget.lockerId != null && widget.boxId != null;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedServices.clear();
    });

    try {
      final response = widget.storeId != null
          ? await LaundryServiceAPI.getServicesByStoreAndCategory(
              widget.storeId!,
              _category,
            )
          : await LaundryServiceAPI.getServicesByCategory(_category);

      final filtered = response.data.where(_matchesCategory).toList();
      if (mounted) setState(() => _services = filtered);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải danh sách dịch vụ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _matchesCategory(LaundryService service) {
    if (service.category != null) return service.category == _category;
    final type = service.serviceType;
    if (type == ServiceType.standardDropoff ||
        type == ServiceType.overnight ||
        type == ServiceType.express2h ||
        type == ServiceType.monthlyStudent ||
        type == ServiceType.monthlyShipper) {
      return _category == ServiceCategory.storage;
    }
    return _category == ServiceCategory.laundry;
  }

  void _switchCategory(ServiceCategory category) {
    if (_category == category) return;
    setState(() => _category = category);
    _fetchServices();
  }

  void _toggleService(int id) {
    setState(() {
      if (_selectedServices.contains(id)) {
        _selectedServices.remove(id);
      } else {
        _selectedServices.add(id);
      }
    });
  }

  void _continue() {
    if (!_hasLockerContext) {
      _showMessage('Vui lòng chọn locker và ngăn tủ trước');
      context.go('/user/lockers');
      return;
    }
    if (_selectedServices.isEmpty) {
      _showMessage('Vui lòng chọn ít nhất 1 dịch vụ');
      return;
    }

    context.pushNamed(
      'confirm-order',
      queryParameters: {
        'storeId': widget.storeId.toString(),
        'storeName': widget.storeName ?? '',
        'lockerId': widget.lockerId.toString(),
        'lockerName': widget.lockerName ?? '',
        'boxId': widget.boxId.toString(),
        'boxNumber': widget.boxNumber ?? '',
        'selectedCategory': serviceCategoryValue(_category),
        'serviceIds': _selectedServices.join(','),
      },
    );
  }

  double get _subtotal {
    return _services
        .where((service) => _selectedServices.contains(service.id))
        .fold<double>(0, (sum, service) => sum + service.price);
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
      appBar: AppBar(title: const Text('Tạo đơn mới')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng ước tính',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                    Text(
                      formatCurrency(_subtotal),
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _isLoading ? null : _continue,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Tiếp tục'),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ContextCard(widget: widget),
          const SizedBox(height: 16),
          SegmentedButton<ServiceCategory>(
            segments: const [
              ButtonSegment(
                value: ServiceCategory.laundry,
                icon: Icon(Icons.local_laundry_service),
                label: Text('Giặt đồ'),
              ),
              ButtonSegment(
                value: ServiceCategory.storage,
                icon: Icon(Icons.inventory_2),
                label: Text('Gửi đồ'),
              ),
            ],
            selected: {_category},
            onSelectionChanged: (selection) => _switchCategory(selection.first),
          ),
          const SizedBox(height: 12),
          _CategoryNote(category: _category),
          const SizedBox(height: 16),
          Text(
            'Chọn dịch vụ',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ErrorPanel(message: _error!, onRetry: _fetchServices)
          else if (_services.isEmpty)
            const _EmptyServices()
          else
            ..._services.map(_serviceCard),
        ],
      ),
    );
  }

  Widget _serviceCard(LaundryService service) {
    final selected = _selectedServices.contains(service.id);
    final displayPrice = service.pricePerUnit ?? service.price;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleService(service.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => _toggleService(service.id),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (service.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(service.description!),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${formatCurrency(displayPrice)}/${serviceUnitLabel(service.unit)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (service.maxPrice != null)
                      Text('Tối đa: ${formatCurrency(service.maxPrice)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.widget});

  final CreateOrderScreen widget;

  @override
  Widget build(BuildContext context) {
    final hasContext = widget.storeId != null;
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
            hasContext ? widget.storeName ?? 'Cửa hàng' : 'Chưa chọn locker',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasContext
                ? '${widget.lockerName ?? 'Locker'} - Ngăn số ${widget.boxNumber ?? ''}'
                : 'Hãy chọn cửa hàng, locker và ngăn tủ trước khi tạo đơn',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryNote extends StatelessWidget {
  const _CategoryNote({required this.category});

  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    final isLaundry = category == ServiceCategory.laundry;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLaundry
                  ? 'Giá tính theo kg; nhân viên sẽ cân và cập nhật giá chính xác sau khi thu gom.'
                  : 'Giá cố định; thanh toán trước khi gửi đồ vào tủ.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, style: const TextStyle(color: AppColors.errorColor)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(child: Text('Không có dịch vụ nào trong danh mục này')),
    );
  }
}
