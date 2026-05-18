import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/models/store.dart';
import '../../../../core/services/store_service.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  List<Store> _stores = [];

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores({bool refresh = false}) async {
    setState(() {
      _error = null;
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await StoreService.getAllStores();
      if (!response.success) {
        throw StateError(
          response.message ?? 'Không thể tải danh sách cửa hàng',
        );
      }
      if (mounted) setState(() => _stores = response.data);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Đã xảy ra lỗi khi tải danh sách cửa hàng');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _openStore(Store store) {
    context.pushNamed(
      'store-detail',
      pathParameters: {'id': store.id.toString()},
      extra: store,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(title: const Text('Cửa hàng')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _fetchStores,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchStores(refresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Tìm thấy ${_stores.length} cửa hàng',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightIcon,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_stores.isEmpty)
            const _EmptyStores()
          else
            ..._stores.map(
              (store) => _StoreCard(store: store, onTap: _openStore),
            ),
          if (_isRefreshing) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.onTap});

  final Store store;
  final ValueChanged<Store> onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = store.image ?? store.imageUrl;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => onTap(store),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) =>
                          const _StoreImageFallback(),
                    )
                  : const _StoreImageFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store.address,
                    style: AppTypography.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (store.phone?.isNotEmpty == true)
                        _InfoChip(icon: Icons.phone, label: store.phone!),
                      if (store.openTime?.isNotEmpty == true)
                        _InfoChip(
                          icon: Icons.schedule,
                          label: '${store.openTime} - ${store.closeTime ?? ''}',
                        ),
                      const _InfoChip(
                        icon: Icons.check_circle,
                        label: 'Hoạt động',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreImageFallback extends StatelessWidget {
  const _StoreImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.16),
      child: const Center(
        child: Icon(Icons.map, size: 52, color: AppColors.primary),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primaryLight),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyStores extends StatelessWidget {
  const _EmptyStores();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text('Chưa có cửa hàng nào'),
        ],
      ),
    );
  }
}
