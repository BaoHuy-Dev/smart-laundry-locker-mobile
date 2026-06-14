import 'package:smart_laundry_locker/features/locker/domain/entities/locker_location.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/locker_detail_map_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/locker_map_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_provider.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_providers.dart';
import 'package:smart_laundry_locker/features/locker/presentation/widgets/locker_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/shared/widgets/unauthenticated_placeholder.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

class LockerPage extends ConsumerStatefulWidget {
  const LockerPage({super.key});

  @override
  ConsumerState<LockerPage> createState() => _LockerPageState();
}

class _LockerPageState extends ConsumerState<LockerPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    TokenService.authState.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    if (TokenService.authState.value && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read<LockerProvider>(lockerNotifierProvider).getLocations();
        }
      });
    }
  }

  @override
  void dispose() {
    TokenService.authState.removeListener(_onAuthStateChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    ref
        .read<LockerProvider>(lockerNotifierProvider)
        .getLocations(search: query);
  }

  void _onScroll() {
    // Load more khi scroll gần cuối
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final LockerProvider provider = ref.read<LockerProvider>(
        lockerNotifierProvider,
      );
      if (provider.state.canLoadMoreLocations &&
          !provider.state.isLoadingMore) {
        provider.loadMoreLocations(search: _searchController.text);
      }
    }
  }

  void _navigateToMap(LockerLocation location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LockerDetailMapPage(location: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LockerProvider provider = ref.watch<LockerProvider>(
      lockerNotifierProvider,
    );
    final LockerState state = provider.state;

    return ValueListenableBuilder<bool>(
      valueListenable: TokenService.authState,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7FAFC),
            body: Column(
              children: const [
                BrandHeroHeader(
                  title: 'Danh sách tủ',
                  subtitle: 'Đăng nhập để xem các tủ khả dụng',
                ),
                Expanded(
                  child: UnauthenticatedPlaceholder(
                    message: 'Bạn cần đăng nhập để xem danh sách tủ',
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7FAFC),
          body: Column(
            children: [
              BrandHeroHeader(
                title: 'Danh sách tủ',
                subtitle: 'Chọn tủ để xem chi tiết',
                trailing: BrandCircleIconButton(
                  icon: LucideIcons.mapPin,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LockerMapPage(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tủ...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AislBrand.chipBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AislBrand.chipBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AislBrand.blue),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildLocationsList(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationsList(LockerState state) {
    // Loading state
    if (state.isLoading && state.locations.isEmpty) {
      // Skeleton loading for list
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const _LockerItemSkeleton(),
      );
    }

    // Error state
    if (state.error != null && state.locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read<LockerProvider>(lockerNotifierProvider)
                  .getLocations(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.locations.isEmpty) {
      return Center(
        child: Text(
          'Hiện tại chưa có tủ nào!',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    // List of locations
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read<LockerProvider>(lockerNotifierProvider)
            .getLocations(refresh: true);
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: state.locations.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Loading more indicator - show skeleton row
          if (index >= state.locations.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: _LockerItemSkeleton(),
            );
          }

          final location = state.locations[index];
          return LockerItem(
            location: location,
            onTap: () => _navigateToMap(location),
          );
        },
      ),
    );
  }
}

/// Skeleton placeholder for LockerItem while loading
class _LockerItemSkeleton extends StatelessWidget {
  const _LockerItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final box = (width * 0.18).clamp(48.0, 72.0);
    final line1Height = (width * 0.035).clamp(12.0, 18.0);
    final line2Height = (width * 0.03).clamp(10.0, 14.0);
    final horizontalPadding = (width * 0.04).clamp(12.0, 20.0);
    final spacing = (width * 0.02).clamp(4.0, 16.0);

    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: line1Height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Container(
                  height: line2Height,
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: width * 0.6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: spacing * 0.25),
                Container(
                  height: line2Height,
                  width: width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
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
