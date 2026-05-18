import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/core.dart';
import '../../../../core/models/store.dart';
import '../../../../core/services/store_service.dart';
import '../../../../core/storage/local_favorites_service.dart';

class StoreDetailScreen extends ConsumerStatefulWidget {
  const StoreDetailScreen({
    super.key,
    required this.storeId,
    this.initialStore,
  });

  final int storeId;
  final Store? initialStore;

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  Store? _store;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _store = widget.initialStore;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = _store == null;
      _error = null;
    });

    try {
      final favorites = await LocalFavoritesService.getFavoriteStores();
      Store? loaded = _store;
      if (loaded == null) {
        final response = await StoreService.getStoreById(widget.storeId);
        loaded = response.data;
      }

      if (mounted) {
        setState(() {
          _store = loaded;
          _isFavorite = favorites.containsKey(widget.storeId);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải thông tin cửa hàng');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final store = _store;
    if (store == null) return;
    final favorites = await LocalFavoritesService.toggleStore(store);
    if (mounted) setState(() => _isFavorite = favorites.containsKey(store.id));
  }

  Future<void> _openDirections() async {
    final store = _store;
    if (store == null) return;
    final uri = store.latitude != null && store.longitude != null
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${store.latitude},${store.longitude}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(store.address)}',
          );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Chi tiết cửa hàng'),
        actions: [
          IconButton(
            onPressed: store == null ? null : _toggleFavorite,
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _load)
          : _StoreDetailBody(
              store: store!,
              isFavorite: _isFavorite,
              onDirections: _openDirections,
              onChooseLocker: () => context.go('/user/lockers'),
            ),
    );
  }
}

class _StoreDetailBody extends StatelessWidget {
  const _StoreDetailBody({
    required this.store,
    required this.isFavorite,
    required this.onDirections,
    required this.onChooseLocker,
  });

  final Store store;
  final bool isFavorite;
  final VoidCallback onDirections;
  final VoidCallback onChooseLocker;

  @override
  Widget build(BuildContext context) {
    final imageUrl = store.image ?? store.imageUrl;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) =>
                      const _MapFallback(),
                )
              : const _MapFallback(),
        ),
        Transform.translate(
          offset: const Offset(0, -24),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        store.name,
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pink : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _StatusBadge(),
                const SizedBox(height: 16),
                Text(store.address, style: AppTypography.textTheme.bodyLarge),
                const Divider(height: 32),
                if (store.phone?.isNotEmpty == true)
                  _DetailRow(
                    icon: Icons.phone,
                    label: 'Số điện thoại',
                    value: store.phone!,
                  ),
                if (store.openTime?.isNotEmpty == true)
                  _DetailRow(
                    icon: Icons.schedule,
                    label: 'Giờ mở cửa',
                    value: '${store.openTime} - ${store.closeTime ?? ''}',
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onChooseLocker,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Chọn locker tại cửa hàng'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Chỉ đường'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            foregroundColor: AppColors.primary,
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.textTheme.bodySmall),
                Text(
                  value,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.successColor),
          SizedBox(width: 6),
          Text('Hoạt động', style: TextStyle(color: AppColors.successColor)),
        ],
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.16),
      child: const Center(
        child: Icon(Icons.map, size: 72, color: AppColors.primary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
