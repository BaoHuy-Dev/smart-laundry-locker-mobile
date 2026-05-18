import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/models/store.dart';
import '../../../../core/storage/local_favorites_service.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isLoading = true;
  Map<int, Store> _favoriteStores = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stores = await LocalFavoritesService.getFavoriteStores();
    if (mounted) {
      setState(() {
        _favoriteStores = stores;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(Store store) async {
    final stores = await LocalFavoritesService.toggleStore(store);
    if (mounted) setState(() => _favoriteStores = stores);
  }

  @override
  Widget build(BuildContext context) {
    final stores = _favoriteStores.values.toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(title: const Text('Yêu thích')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
          ? const _EmptyFavorites()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: stores.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final store = stores[index];
                return Card(
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
                      onPressed: () => _toggle(store),
                      icon: const Icon(Icons.favorite, color: Colors.pink),
                    ),
                    onTap: () => context.pushNamed(
                      'store-detail',
                      pathParameters: {'id': store.id.toString()},
                      extra: store,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa lưu cửa hàng nào vào danh sách yêu thích',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
