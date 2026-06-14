import 'dart:async';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:smart_laundry_locker/features/stores/domain/entities/store.dart';
import 'package:smart_laundry_locker/features/stores/infrastructure/services/store_service.dart';
import 'package:smart_laundry_locker/features/stores/infrastructure/services/favorite_stores_service.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final CourierOrdersProvider _courierOrdersProvider;

  // Customer-home (RN-style) state.
  final StoreService _storeService = StoreService(ApiClient());
  final FavoriteStoresService _favService = FavoriteStoresService();
  List<Store> _stores = const [];
  bool _loadingStores = true;
  String? _storeError;
  Set<int> _favoriteIds = <int>{};

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
      _loadStores();
      _loadFavorites();
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

  Future<void> _loadStores() async {
    setState(() {
      _loadingStores = true;
      _storeError = null;
    });
    try {
      final stores = await _storeService.getStores();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loadingStores = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _storeError = 'Không thể tải danh sách cửa hàng';
        _loadingStores = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final ids = await _favService.getFavoriteIds();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  Future<void> _toggleFavorite(Store store) async {
    final nowFav = await _favService.toggle(store.id);
    if (!mounted) return;
    setState(() {
      if (nowFav) {
        _favoriteIds.add(store.id);
      } else {
        _favoriteIds.remove(store.id);
      }
    });
  }

  Future<void> _onRefresh() async {
    final profile = context.read<ProfileProvider>();
    context.read<NotificationProvider>().loadUnreadCount();
    await Future.wait<void>([profile.loadProfile(), _loadStores()]);
    await _loadFavorites();
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
      backgroundColor: AislBrand.pageBackground,
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
            _buildWelcomeCard(context),
            const SizedBox(height: 28),
            _buildServicesSection(context),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BrandSectionHeader(
                icon: LucideIcons.store,
                title: 'Các nơi đặt locker',
                onSeeAll: () => context.push(AppRouter.stores),
              ),
            ),
            const SizedBox(height: 16),
            _buildStoreSection(context),
            const SizedBox(height: 24),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              BrandAvatar(
                imageUrl: profile?.avatarUrl,
                name: name,
                size: 50,
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
                        color: AislBrand.navy.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBell(context),
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
        onTap: () => context.push(AppRouter.myVouchers),
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

  Widget _buildWelcomeCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AislBrand.softHeaderGradient,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hãy để chúng tôi là nơi an toàn của bạn.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: const Color(0xFF1A3A4A),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          LucideIcons.box,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
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

  Widget _buildServicesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dịch vụ tiện ích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AislBrand.textTitle,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  'Thuê tủ',
                  'An toàn',
                  LucideIcons.key,
                  const Color(0xFFF0F7FF),
                  AislBrand.blue,
                  () => context.push(AppRouter.rentLocker),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  'Gửi hàng',
                  'Nhanh chóng',
                  LucideIcons.send,
                  const Color(0xFFF3FAF4),
                  const Color(0xFF16A34A),
                  () => context.push(AppRouter.sendParcel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  'Lấy hàng',
                  'Tiện lợi',
                  LucideIcons.packageOpen,
                  const Color(0xFFFFF8F0),
                  const Color(0xFFEA8A1E),
                  () => context.push(AppRouter.lockerOtp),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  'Đơn tủ',
                  'Theo dõi',
                  LucideIcons.package,
                  const Color(0xFFFFF4F6),
                  const Color(0xFFE91E63),
                  () => context.push(AppRouter.myLockerOrders),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  'Ủy quyền',
                  'Mở tủ hộ',
                  LucideIcons.lockOpen,
                  const Color(0xFFEFF6FF),
                  AislBrand.navy,
                  () => context.push(AppRouter.authorizedOpening),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  'Giặt đồ',
                  'Tạo đơn',
                  LucideIcons.washingMachine,
                  const Color(0xFFF4F7FF),
                  AislBrand.blue,
                  () => context.push(AppRouter.userLaundryOrder),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 122,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AislBrand.textTitle,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSection(BuildContext context) {
    if (_loadingStores) {
      return _storeStateCard(
        const SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(color: AislBrand.navy),
          ),
        ),
      );
    }
    if (_storeError != null) {
      return _storeStateCard(
        _storeMessage(
          LucideIcons.triangleAlert,
          _storeError!,
          const Color(0xFFE53E3E),
        ),
      );
    }
    if (_stores.isEmpty) {
      return _storeStateCard(
        _storeMessage(
          LucideIcons.store,
          'Chưa có nơi đặt locker nào',
          const Color(0xFFA0AEC0),
        ),
      );
    }
    return _buildStoreFeatureCard(context, _stores.first);
  }

  Widget _storeStateCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AislBrand.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
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

  Widget _buildStoreFeatureCard(BuildContext context, Store store) {
    final isFavorite = _favoriteIds.contains(store.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(AppRouter.storeDetail, extra: store),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AislBrand.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: (store.image != null && store.image!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: store.image!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _mapPlaceholder(),
                              errorWidget: (_, __, ___) => _mapPlaceholder(),
                            )
                          : _mapPlaceholder(),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: BrandStatusBadge(
                      label: store.isActive ? 'Hoạt động' : 'Đóng cửa',
                      dotColor: store.isActive
                          ? AislBrand.statusGreen
                          : Colors.grey,
                      textColor: store.isActive
                          ? AislBrand.statusGreenText
                          : Colors.grey.shade700,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Row(
                      children: [
                        if (store.distanceKm != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.mapPin,
                                  size: 12,
                                  color: AislBrand.navy,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${store.distanceKm!.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AislBrand.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AislBrand.textTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.address ?? 'Chưa có địa chỉ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AislBrand.textMuted,
                        height: 1.4,
                      ),
                    ),
                    if (store.contactPhone != null &&
                        store.contactPhone!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.phone,
                            size: 14,
                            color: AislBrand.textBody,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            store.contactPhone!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AislBrand.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      color: const Color(0xFFF7FAFC),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.map, size: 40, color: Color(0xFFA0AEC0)),
          SizedBox(height: 8),
          Text(
            'Bản đồ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA0AEC0),
            ),
          ),
        ],
      ),
    );
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
                    _buildWalletSection(context),
                    const SizedBox(height: 24),
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

  Widget _buildBlogSection(BuildContext context, HomeProvider provider) {
    if (provider.blogs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Tin tức & Cẩm nang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: provider.blogs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final blog = provider.blogs[index];
              return InkWell(
                onTap: () {
                  // Show detail dialog or navigate
                  SmartDialog.show(
                    builder: (ctx) => AlertDialog(
                      title: Text(blog.title),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (blog.imageUrl != null)
                              Image.network(blog.imageUrl!),
                            const SizedBox(height: 12),
                            Text(blog.content),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => SmartDialog.dismiss(),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: blog.imageUrl != null
                            ? Image.network(
                                blog.imageUrl!,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 140,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        LucideIcons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                            : Container(
                                height: 140,
                                color: Colors.grey[200],
                                child: const Icon(
                                  LucideIcons.newspaper,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(blog.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              blog.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            if (blog.subTitle != null &&
                                blog.subTitle!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                blog.subTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _buildMainActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Dịch vụ tiện ích',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildExpressCard(
                  'Thuê tủ',
                  'An toàn',
                  LucideIcons.key,
                  const Color(0xFFF0F7FF),
                  Colors.blue.shade500,
                  () => context.push(AppRouter.rentLocker),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExpressCard(
                  'Lấy hàng',
                  'Tiện lợi',
                  LucideIcons.packageOpen,
                  const Color(0xFFFFF8F0),
                  const Color(0xFF5F8FB8),
                  () => context.push(AppRouter.lockerOtp),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExpressCard(
                  'Gửi hàng',
                  'Nhanh chóng',
                  LucideIcons.send,
                  const Color(0xFFF3FAF4),
                  Colors.green.shade500,
                  () => context.push(AppRouter.sendParcel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildExpressCard(
                  'Ủy quyền',
                  'Mở tủ',
                  LucideIcons.lockOpen,
                  const Color(0xFFEFF6FF),
                  Colors.blue.shade600,
                  () => context.push(AppRouter.authorizedOpening),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExpressCard(
                  'Giat do',
                  'Tao don',
                  LucideIcons.washingMachine,
                  const Color(0xFFF4F7FF),
                  AISLShadcnTheme.navyPrimary,
                  () => context.push(AppRouter.userLaundryOrder),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExpressCard(
                  'Đơn tủ',
                  'Theo dõi',
                  LucideIcons.package,
                  const Color(0xFFFFF4F6),
                  Colors.pink.shade500,
                  () => context.push(AppRouter.myLockerOrders),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoresEntry(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRouter.stores),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AISLShadcnTheme.navyPrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.store,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khám phá cửa hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tìm cửa hàng & tủ gần bạn',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpressCard(
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130, // Adjusted for 3 columns
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
