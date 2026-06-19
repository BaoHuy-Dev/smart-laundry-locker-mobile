import 'dart:async';
import 'package:flutter/services.dart';
import 'package:smart_laundry_locker/core/config/feature_flags.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/promotions/data/models/promotion_model.dart';
import 'package:smart_laundry_locker/features/promotions/presentation/providers/promotion_provider.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_laundry_locker/core/utils/currency_formatter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_laundry_locker/features/notifications/presentation/providers/notification_provider.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:smart_laundry_locker/core/services/courier_mode_provider.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/courier_orders_injection.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/courier_orders_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_provider.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_injection.dart';
import 'package:smart_laundry_locker/features/home/presentation/providers/home_provider.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:smart_laundry_locker/features/locker/domain/entities/locker_location.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_provider.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_providers.dart';
import 'package:smart_laundry_locker/features/stores/domain/entities/store.dart';
import 'package:smart_laundry_locker/features/stores/presentation/pages/store_lockers_page.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final CourierOrdersProvider _courierOrdersProvider;

  // Customer-home (RN-style) state.

  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<String> _bannerImages = [
    'https://img.freepik.com/free-vector/gradient-sale-background_23-2148934477.jpg',
    'https://img.freepik.com/free-vector/super-sale-banner-template-with-3d-text-effect_1361-2603.jpg',
    'https://img.freepik.com/free-vector/gradient-sale-background_23-2148817294.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _courierOrdersProvider = CourierOrdersInjection.provideProvider(
      ApiClient(),
    );
    _startBannerTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = context.read<ProfileProvider>();
      if (profile.profile == null && !profile.isLoading) {
        profile.loadProfile();
      }
      ref.read(lockerNotifierProvider).getLocations();
      ref.read(promotionNotifierProvider).load();
    });
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        final homeProvider = context.read<HomeProvider>();
        final ads = homeProvider.advertisements;
        final count = ads.isNotEmpty ? ads.length : _bannerImages.length;
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % count;
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    final profile = context.read<ProfileProvider>();
    context.read<NotificationProvider>().loadUnreadCount();
    await Future.wait<void>([
      profile.loadProfile(),
      ref.read(lockerNotifierProvider).getLocations(refresh: true),
      ref.read(promotionNotifierProvider).load(),
    ]);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _courierOrdersProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCourierModeActive = context
        .watch<CourierModeProvider>()
        .isCourierModeActive;

    if (isCourierModeActive &&
        !_courierOrdersProvider.isLoading &&
        !_courierOrdersProvider.hasLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _courierOrdersProvider.load();
      });
    }

    return Scaffold(
      backgroundColor: context.pageBg,
      body: isCourierModeActive
          ? _buildCourierBody(context)
          : _buildCustomerBody(context),
    );
  }

  // ---------------------------------------------------------------------------
  // Customer home (RN-style)
  // ---------------------------------------------------------------------------

  Widget _buildCustomerBody(BuildContext context) {
    return RefreshIndicator(
      color: AislBrand.navy,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildChips(context),
            const SizedBox(height: 24),
            _buildPopularLockersSection(context),
            const SizedBox(height: 24),
            _buildFlashSaleSection(context),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Chào buổi sáng';
    if (hour < 14) return '🌤️ Chào buổi trưa';
    if (hour < 18) return '🌅 Chào buổi chiều';
    return '🌙 Chào buổi tối';
  }

  Widget _buildHeader(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final name = (profile?.fullName.trim().isNotEmpty ?? false)
        ? profile!.fullName
        : 'Người dùng';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AislBrand.softHeaderGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Row 1: Avatar / name / bell ──────────────────────────
              Row(
                children: [
                  BrandAvatar(
                    imageUrl: profile?.avatarUrl,
                    name: name,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hi $name!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AislBrand.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _greeting(),
                          style: TextStyle(
                            fontSize: 13,
                            color: AislBrand.navy.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBell(context),
                ],
              ),
              // ── Row 2: Số dư ví (tạm ẩn — backend chưa có wallet service) ──
              if (FeatureFlags.walletEnabled) const SizedBox(height: 16),
              if (FeatureFlags.walletEnabled)
                Consumer<WalletProvider>(
                builder: (context, wallet, _) => GestureDetector(
                  onTap: () async {
                    await context.push(AppRouter.topUp);
                    if (context.mounted) wallet.getWalletBalance();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AislBrand.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AislBrand.navy.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AislBrand.navy.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.wallet,
                            color: AislBrand.navy,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Số dư ví',
                              style: TextStyle(
                                fontSize: 11,
                                color: AislBrand.navy.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatVnd(wallet.balance),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AislBrand.navy,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AislBrand.navy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Nạp tiền',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBell(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final count = provider.unreadCount;
        return GestureDetector(
          onTap: () => context.push(AppRouter.notifications),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: AislBrand.navy.withValues(alpha: 0.1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(LucideIcons.bell, color: AislBrand.navy, size: 24),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AislBrand.badgeRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChips(BuildContext context) {
    final chips = <Widget>[
      BrandFilterChip(
        icon: LucideIcons.packageCheck,
        label: 'Đơn hàng',
        onTap: () => context.go(AppRouter.orders),
      ),
      BrandFilterChip(
        icon: LucideIcons.box,
        label: 'Tủ',
        onTap: () => context.go(AppRouter.lockers),
      ),
      BrandFilterChip(
        icon: LucideIcons.store,
        label: 'Cửa hàng',
        onTap: () => context.push(AppRouter.stores),
      ),
      BrandFilterChip(
        icon: LucideIcons.bell,
        label: 'Thông báo',
        onTap: () => context.push(AppRouter.notifications),
      ),
      BrandFilterChip(
        icon: LucideIcons.gift,
        label: 'Ưu đãi',
        onTap: () => context.push(AppRouter.promotions),
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }

  // ── "Popular Workouts" style: horizontal locker cards ──────────────────────

  Widget _buildPopularLockersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BrandSectionHeader(
            icon: LucideIcons.store,
            title: 'Các nơi đặt locker',
            onSeeAll: () => context.go(AppRouter.lockers),
            highlightColor: const Color(0xFF766807),
            highlightRollColor: const Color(0xFF58500D),
          ),
        ),
        const SizedBox(height: 14),
        _buildLockerHorizontalList(context),
      ],
    );
  }

  Widget _buildLockerHorizontalList(BuildContext context) {
    final LockerProvider lockerProvider = ref.watch(lockerNotifierProvider);
    final LockerState state = lockerProvider.state;

    if (state.isLoading && state.locations.isEmpty) {
      return SizedBox(
        height: 158,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }
    if (state.error != null && state.locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _storeMessage(LucideIcons.triangleAlert, state.error!, const Color(0xFFE53E3E)),
      );
    }
    if (state.locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _storeMessage(LucideIcons.store, 'Chưa có nơi đặt locker nào', const Color(0xFFA0AEC0)),
      );
    }
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.locations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, index) => _buildLockerHorizontalCard(context, state.locations[index]),
      ),
    );
  }

  Widget _buildLockerHorizontalCard(BuildContext context, LockerLocation location) {
    final colors = _gradientForLocation(location.id);
    final initials = _initialsForName(location.name);
    return GestureDetector(
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => StoreLockerGridPage(
            store: Store(
              id: int.tryParse(location.id) ?? 0,
              name: location.name,
              address: location.address,
              latitude: location.latitude,
              longitude: location.longitude,
              active: location.isActive,
            ),
          ),
        ),
      ),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or gradient
              (location.imageUrl != null && location.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: location.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _lockerCardGradient(colors, initials),
                      errorWidget: (_, __, ___) => _lockerCardGradient(colors, initials),
                    )
                  : _lockerCardGradient(colors, initials),
              // Dark bottom overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.60)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Status badge top-left
              Positioned(
                top: 12,
                left: 12,
                child: BrandStatusBadge(
                  label: location.isActive ? 'Hoạt động' : 'Đóng cửa',
                  dotColor: location.isActive ? AislBrand.statusGreen : Colors.grey,
                  textColor: location.isActive ? AislBrand.statusGreenText : Colors.grey.shade700,
                ),
              ),
              // Name + address bottom
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, color: Colors.white60, size: 11),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location.address.isNotEmpty ? location.address : 'Chưa có địa chỉ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lockerCardGradient(List<Color> colors, String initials) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            const Icon(LucideIcons.lockKeyhole, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Flash Sale section ─────────────────────────────────────────────────────

  Widget _buildFlashSaleSection(BuildContext context) {
    final PromotionProvider promoProvider = ref.watch(promotionNotifierProvider);
    final promos = promoProvider.promotions;
    final isLoading = promoProvider.isLoading;

    if (!isLoading && promos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BrandSectionHeader(
            icon: LucideIcons.zap,
            title: 'Flash Sale',
            onSeeAll: () => context.push(AppRouter.promotions),
            highlightColor: const Color(0xFF766807),
            highlightRollColor: const Color(0xFF58500D),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isLoading && promos.isEmpty
              ? _buildFlashSaleSkeleton()
              : Column(
                  children: [
                    for (int i = 0; i < promos.take(10).length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: context.dividerColor),
                      RepaintBoundary(
                        child: _FlashSaleCard(
                          promo: promos[i],
                          colors: _gradients[i % _gradients.length],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildFlashSaleSkeleton() {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 200,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _storeMessage(IconData icon, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          Icon(icon, size: 44, color: color),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static const _gradients = [
    [Color(0xFF003D5B), Color(0xFF0077B6)],
    [Color(0xFF0077B6), Color(0xFF00B4D8)],
    [Color(0xFF059669), Color(0xFF10B981)],
    [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
    [Color(0xFF0F172A), Color(0xFF334155)],
  ];

  List<Color> _gradientForLocation(String id) {
    final hash = id.codeUnits.fold(0, (a, b) => a + b);
    return _gradients[hash % _gradients.length];
  }

  String _initialsForName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    final n = parts.first;
    return n.length >= 2 ? n.substring(0, 2).toUpperCase() : n.toUpperCase();
  }

  // ---------------------------------------------------------------------------
  // Courier home (unchanged behaviour)
  // ---------------------------------------------------------------------------

  Widget _buildCourierBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<HomeProvider>(
                builder: (context, provider, _) =>
                    _buildBanner(context, provider),
              ),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  children: [
                    // Ví (tạm ẩn — backend chưa có wallet service)
                    if (FeatureFlags.walletEnabled) _buildWalletSection(context),
                    if (FeatureFlags.walletEnabled) const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _courierOrdersProvider,
                      builder: (context, _) {
                        return _buildCourierCompletedCard(
                          _courierOrdersProvider.completedToday,
                          isLoading: _courierOrdersProvider.isLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<CourierDispatchProvider>(
                      builder: (context, dispatchProvider, _) {
                        return Column(
                          children: [
                            _buildCourierStartWorkCard(
                              context,
                              isOnline: dispatchProvider.isOnline,
                            ),
                            if (dispatchProvider.isOnline) ...[
                              const SizedBox(height: 16),
                              _buildCourierViewMapCard(context),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildCourierQuickActionsRow(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AISLShadcnTheme.navyPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.box,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LOCKERLY',
                style: TextStyle(
                  color: AISLShadcnTheme.navyPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  height: 1,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, color: Colors.grey, size: 20),
          onPressed: () async {
            context.read<HomeProvider>().loadHomeData();
            context.read<WalletProvider>().getWalletBalance();
            if (context.read<CourierModeProvider>().isCourierModeActive) {
              _courierOrdersProvider.load();
            }
            SmartDialog.showToast('Đã làm mới dữ liệu');
          },
        ),
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final int count = provider.unreadCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.bell, color: Colors.grey),
                  onPressed: () {
                    context.push(AppRouter.notifications);
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, HomeProvider provider) {
    final ads = provider.advertisements;

    if (ads.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.grey[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.megaphone,
                color: Colors.white.withValues(alpha: 0.3),
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Chưa có quảng cáo nào',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Đăng ký trở thành Đối tác để đặt quảng cáo tại đây!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // Optionally link to partner registration form
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(LucideIcons.users, size: 16),
                label: const Text('Đăng ký ngay'),
              ),
            ],
          ),
        ),
      );
    }

    final images = ads.map((e) => e.imageUrl).toList();

    if (_currentBannerIndex >= images.length) {
      _currentBannerIndex = 0;
    }

    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(color: Colors.black87),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.network(
                images[_currentBannerIndex],
                key: ValueKey<String>(images[_currentBannerIndex]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(LucideIcons.image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ví của bạn',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Consumer<WalletProvider>(
                      builder: (context, walletProvider, _) {
                        return _buildCurrencyItem(
                          LucideIcons.coins,
                          CurrencyFormatter.formatVnd(walletProvider.balance),
                          Colors.amber,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await context.push(AppRouter.topUp);
                if (!context.mounted) return;
                await context.read<WalletProvider>().getWalletBalance();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wallet, color: AISLShadcnTheme.navyPrimary),
                    const SizedBox(height: 4),
                    const Text(
                      'Nạp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCourierCompletedCard(
    int completedToday, {
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              LucideIcons.packageCheck,
              color: AISLShadcnTheme.navyPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Đơn hoàn thành hôm nay',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  '$completedToday',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCourierStartWorkCard(
    BuildContext context, {
    bool isOnline = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          isOnline ? _handleStopWorking(context) : _handleStartWorking(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF16A34A).withValues(alpha: 0.10)
                      : AISLShadcnTheme.navyPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
                  color: isOnline
                      ? const Color(0xFF16A34A)
                      : AISLShadcnTheme.navyPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'ĐANG HOẠT ĐỘNG' : 'BẮT ĐẦU LÀM VIỆC',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isOnline
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFFF6B1A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline
                          ? 'Bạn đang sẵn sàng nhận đơn hàng mới.'
                          : 'Nhận đơn, đi nhận và bàn giao tủ.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.grey.shade100
                      : const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.pause : Icons.play_arrow,
                      color: isOnline ? Colors.grey.shade700 : Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Nghỉ ngơi' : 'Bắt đầu',
                      style: TextStyle(
                        color: isOnline ? Colors.grey.shade700 : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildCourierViewMapCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push(AppRouter.courierMap),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.map,
                color: AISLShadcnTheme.navyPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BẢN ĐỒ THEO DÕI',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Xem vị trí và các đơn hàng quanh bạn.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
    );
  }

  Future<void> _handleStartWorking(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      SmartDialog.showToast('Vui lòng bật dịch vụ định vị.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cần quyền vị trí',
            style: TextStyle(color: Colors.black87),
          ),
          content: const Text(
            'Bạn cần bật định vị để nhận đơn hàng.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Đóng', style: TextStyle(color: Colors.black87)),
            ),
            TextButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
                if (context.mounted) Navigator.of(dialogCtx).pop();
              },
              child: const Text(
                'Mở cài đặt',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
      return;
    }

    CourierDispatchInjection.provideCourierDispatchProvider();

    if (!context.mounted) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    // Sync to backend immediately
    if (!context.mounted) return;
    context.read<CourierDispatchProvider>().goOnlineWithLocation(
      position.latitude,
      position.longitude,
    );

    if (!context.mounted) return;
    context.push(AppRouter.courierMap);
  }

  Future<void> _handleStopWorking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Dừng làm việc?',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Hệ thống sẽ không điều phối đơn hàng mới cho bạn.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Dừng',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      await context.read<CourierDispatchProvider>().goOffline();
      SmartDialog.showToast('Đã dừng chế độ hoạt động');
    }
  }

  Widget _buildCourierQuickActionsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _CourierAction(
              icon: LucideIcons.keyRound,
              label: 'Lấy hàng (OTP)',
              onTap: () => context.push(AppRouter.lockerOtp),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CourierAction(
              icon: LucideIcons.qrCode,
              label: 'Giao hàng',
              onTap: () => context.push(AppRouter.qrScan),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CourierAction(
              icon: LucideIcons.headset,
              label: 'Hỗ trợ',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Hỗ trợ',
                      style: TextStyle(color: Colors.black87),
                    ),
                    content: const Text(
                      'Liên hệ tổng đài/Admin để được hỗ trợ.',
                      style: TextStyle(color: Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CourierAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AISLShadcnTheme.navyPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AISLShadcnTheme.navyPrimary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Flash Sale card — extracted for RepaintBoundary isolation ────────────────

class _FlashSaleCard extends StatelessWidget {
  final PromotionModel promo;
  final List<Color> colors;

  const _FlashSaleCard({required this.promo, required this.colors});

  @override
  Widget build(BuildContext context) {
    final String? sub =
        (promo.description != null && promo.description!.isNotEmpty)
            ? promo.description
            : null;

    return GestureDetector(
      onTap: () => context.push(AppRouter.promotions),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: image 110×110 ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: promo.effectiveImageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 220,
                      memCacheHeight: 220,
                      placeholder: (_, __) => _gradientBg(),
                      errorWidget: (_, __, ___) => _gradientBg(),
                    ),
                    Positioned(
                      bottom: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53E3E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          promo.discountLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ── Right: content ───────────────────────────────────────
            Expanded(
              child: SizedBox(
                height: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flash Sale chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.zap,
                              size: 10, color: Color(0xFFF97316)),
                          SizedBox(width: 4),
                          Text(
                            'Flash Sale',
                            style: TextStyle(
                              color: Color(0xFFF97316),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Title — 2 lines
                    Text(
                      promo.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: context.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    // Subtitle
                    if (sub != null)
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    // Bottom: expiry + code chip
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 12,
                          color: promo.isExpiringSoon
                              ? const Color(0xFFE53E3E)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            promo.expiryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: promo.isExpiringSoon
                                  ? const Color(0xFFE53E3E)
                                  : const Color(0xFF94A3B8),
                              fontWeight: promo.isExpiringSoon
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _copyCode(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AislBrand.navy.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AislBrand.navy.withValues(alpha: 0.18)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  promo.code,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: AislBrand.navy,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(LucideIcons.copy,
                                    size: 12, color: AislBrand.navy),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: promo.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép: ${promo.code}'),
        backgroundColor: AislBrand.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _gradientBg() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(LucideIcons.ticket, size: 32, color: Colors.white24),
        ),
      );
}
