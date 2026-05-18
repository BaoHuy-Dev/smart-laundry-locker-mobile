import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/models/locker.dart';
import '../../../../core/models/store.dart';
import '../../../../core/services/locker_service.dart';
import '../../../../core/services/store_service.dart';
import '../../../../core/storage/local_favorites_service.dart';

enum _LockerViewMode { stores, lockers }

class LockersScreen extends ConsumerStatefulWidget {
  const LockersScreen({super.key});

  @override
  ConsumerState<LockersScreen> createState() => _LockersScreenState();
}

class _LockersScreenState extends ConsumerState<LockersScreen> {
  final _searchController = TextEditingController();

  _LockerViewMode _viewMode = _LockerViewMode.stores;
  Store? _selectedStore;
  List<Store> _stores = [];
  List<Locker> _lockers = [];
  Map<int, Store> _favoriteStores = {};
  Map<int, Locker> _favoriteLockers = {};
  bool _isLoading = true;
  bool _isLoadingLockers = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storesResponse = await StoreService.getAllStores();
      final favoriteStores = await LocalFavoritesService.getFavoriteStores();
      final favoriteLockers = await LocalFavoritesService.getFavoriteLockers();
      if (mounted) {
        setState(() {
          _stores = storesResponse.data;
          _favoriteStores = favoriteStores;
          _favoriteLockers = favoriteLockers;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải danh sách cửa hàng');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStore(Store store) async {
    setState(() {
      _selectedStore = store;
      _viewMode = _LockerViewMode.lockers;
      _isLoadingLockers = true;
      _error = null;
      _lockers = [];
    });

    try {
      final response = await LockerService.getLockersByStore(store.id);
      if (mounted) setState(() => _lockers = response.data);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải locker của cửa hàng');
    } finally {
      if (mounted) setState(() => _isLoadingLockers = false);
    }
  }

  Future<void> _toggleStoreFavorite(Store store) async {
    final favorites = await LocalFavoritesService.toggleStore(store);
    if (mounted) setState(() => _favoriteStores = favorites);
  }

  Future<void> _toggleLockerFavorite(Locker locker) async {
    final favorites = await LocalFavoritesService.toggleLocker(locker);
    if (mounted) setState(() => _favoriteLockers = favorites);
  }

  Future<void> _showBoxes(Locker locker) async {
    final boxesFuture = LockerService.getBoxesByLocker(locker.id);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FutureBuilder(
        future: boxesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const SizedBox(
              height: 260,
              child: Center(child: Text('Không thể tải danh sách ngăn tủ')),
            );
          }
          final boxes = snapshot.data!.data;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locker.name,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Chọn ngăn tủ còn trống để tạo đơn'),
                const SizedBox(height: 16),
                if (boxes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('Locker này chưa có ngăn tủ')),
                  )
                else
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: boxes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.1,
                          ),
                      itemBuilder: (context, index) {
                        final box = boxes[index];
                        final available = box.status == BoxStatus.available;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: available
                              ? () {
                                  Navigator.of(context).pop();
                                  _goCreateOrder(locker, box);
                                }
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: available
                                  ? AppColors.accent.withValues(alpha: 0.16)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: available
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  color: available
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Số ${box.boxNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  boxStatusLabel(box.status),
                                  style: AppTypography.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _reportLocker(locker);
                  },
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Báo cáo locker gặp sự cố'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goCreateOrder(Locker locker, Box box) {
    final store = _selectedStore;
    if (store == null) return;
    context.pushNamed(
      'create-order',
      queryParameters: {
        'storeId': store.id.toString(),
        'storeName': store.name,
        'lockerId': locker.id.toString(),
        'lockerName': locker.name,
        'boxId': box.id.toString(),
        'boxNumber': box.boxNumber,
      },
    );
  }

  Future<void> _reportLocker(Locker locker) async {
    final controller = TextEditingController();
    final description = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo sự cố'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Mô tả tình trạng locker',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (description == null || description.trim().isEmpty) return;
    try {
      await LockerService.reportLocker(locker.id, {
        'description': description.trim(),
      });
      _showMessage('Đã gửi báo cáo sự cố');
    } catch (_) {
      _showMessage('Không thể gửi báo cáo lúc này');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Store> get _filteredStores {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _stores;
    return _stores
        .where(
          (store) =>
              store.name.toLowerCase().contains(query) ||
              store.address.toLowerCase().contains(query),
        )
        .toList();
  }

  List<Locker> get _filteredLockers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _lockers;
    return _lockers
        .where(
          (locker) =>
              locker.name.toLowerCase().contains(query) ||
              (locker.location ?? '').toLowerCase().contains(query) ||
              (locker.code ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isStoresMode = _viewMode == _LockerViewMode.stores;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        leading: isStoresMode
            ? null
            : IconButton(
                onPressed: () => setState(() {
                  _viewMode = _LockerViewMode.stores;
                  _selectedStore = null;
                  _searchController.clear();
                }),
                icon: const Icon(Icons.arrow_back),
              ),
        title: Text(
          isStoresMode ? 'Lock.R Locker' : _selectedStore?.name ?? 'Locker',
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/user/favorites'),
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: isStoresMode
                  ? _loadStores
                  : () => _selectStore(_selectedStore!),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: isStoresMode
                          ? 'Tìm cửa hàng'
                          : 'Tìm locker trong cửa hàng',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    _ErrorBanner(message: _error!)
                  else if (isStoresMode)
                    ..._filteredStores.map(_buildStoreCard)
                  else if (_isLoadingLockers)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_filteredLockers.isEmpty)
                    const _EmptyState(message: 'Không có locker nào')
                  else
                    ..._filteredLockers.map(_buildLockerCard),
                ],
              ),
            ),
    );
  }

  Widget _buildStoreCard(Store store) {
    final favorite = _favoriteStores.containsKey(store.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.storefront, color: Colors.white),
        ),
        title: Text(
          store.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(store.address),
        trailing: IconButton(
          onPressed: () => _toggleStoreFavorite(store),
          icon: Icon(
            favorite ? Icons.favorite : Icons.favorite_border,
            color: favorite ? Colors.pink : AppColors.primary,
          ),
        ),
        onTap: () => _selectStore(store),
      ),
    );
  }

  Widget _buildLockerCard(Locker locker) {
    final favorite = _favoriteLockers.containsKey(locker.id);
    final active = locker.status == LockerStatus.active;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: active
                      ? AppColors.accent.withValues(alpha: 0.22)
                      : Colors.grey.shade200,
                  foregroundColor: active ? AppColors.primary : Colors.grey,
                  child: const Icon(Icons.inventory_2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locker.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(locker.location ?? 'Chưa cập nhật địa chỉ'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleLockerFavorite(locker),
                  icon: Icon(
                    favorite ? Icons.favorite : Icons.favorite_border,
                    color: favorite ? Colors.pink : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  active ? Icons.check_circle : Icons.warning,
                  color: active
                      ? AppColors.successColor
                      : AppColors.warningColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    active
                        ? 'Sẵn sàng (${locker.availableBoxes} ngăn trống)'
                        : lockerStatusLabel(locker.status),
                  ),
                ),
                FilledButton(
                  onPressed: active ? () => _showBoxes(locker) : null,
                  child: const Text('Chọn'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.errorColor)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
