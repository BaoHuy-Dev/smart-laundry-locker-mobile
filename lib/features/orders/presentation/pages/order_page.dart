import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';

import 'package:smart_laundry_locker/features/orders/presentation/providers/courier_orders_injection.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/courier_orders_provider.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_provider.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/order_skeleton_loading.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/order_status_colors.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/core/services/courier_mode_provider.dart';
import 'package:smart_laundry_locker/shared/widgets/unauthenticated_placeholder.dart';
import 'customer/customer_order_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'courier/courier_order_detail_page.dart';
import 'package:smart_laundry_locker/core/utils/enum_translator.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  bool _isFilterOpen = false;
  late AnimationController _filterController;
  late Animation<Offset> _filterOffset;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _orderCodeController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  final Map<String, String> _categories = {
    'ALL': 'Tất cả đơn hàng',
    'PERSONAL_RENTAL': EnumTranslator.translateOrderType('PERSONAL_RENTAL'),
    'LOGISTICS': EnumTranslator.translateOrderType('LOGISTICS'),
  };

  final Map<String, String> _statuses = {
    'PENDING': EnumTranslator.translateOrderStatus('PENDING'),
    'AWAITING_COURIER': EnumTranslator.translateOrderStatus('AWAITING_COURIER'),
    'AWAITING_PICKUP': EnumTranslator.translateOrderStatus('AWAITING_PICKUP'),
    'ACTIVE': EnumTranslator.translateOrderStatus('ACTIVE'),
    'COMPLETED': EnumTranslator.translateOrderStatus('COMPLETED'),
    'LOCKED_BY_BALANCE': EnumTranslator.translateOrderStatus(
      'LOCKED_BY_BALANCE',
    ),
    'CANCELLED': EnumTranslator.translateOrderStatus('CANCELLED'),
  };

  @override
  void initState() {
    super.initState();
    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _filterOffset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _filterController, curve: Curves.easeInOut),
        );

    TokenService.authState.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    if (TokenService.authState.value && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final isCourierModeActive = context
            .read<CourierModeProvider>()
            .isCourierModeActive;
        if (isCourierModeActive) return;
        context.read<OrderProvider>().fetchOrders();
      });
    }
  }

  @override
  void dispose() {
    TokenService.authState.removeListener(_onAuthStateChanged);
    _filterController.dispose();
    _searchController.dispose();
    _orderCodeController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
      if (_isFilterOpen) {
        _filterController.forward();
      } else {
        _filterController.reverse();
      }
    });
  }

  List<Order> _getDisplayOrders(OrderProvider provider) {
    var filtered = provider.orders;

    // Client-side filtering for orderType if needed, or rely on provider state
    if (provider.orderTypeFilter != null && provider.orderTypeFilter != 'ALL') {
      filtered = filtered
          .where((o) => o.orderType == provider.orderTypeFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final isCourierModeActive = context
        .watch<CourierModeProvider>()
        .isCourierModeActive;
    final accentColor = provider.orderTypeFilter == 'LOGISTICS'
        ? const Color(0xFF0C4B53)
        : const Color(0xFFF97316);

    return ValueListenableBuilder<bool>(
      valueListenable: TokenService.authState,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'ĐƠN HÀNG',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            body: const UnauthenticatedPlaceholder(
              message: 'Bạn cần đăng nhập để xem đơn hàng',
            ),
          );
        }

        if (isCourierModeActive) {
          return ChangeNotifierProvider<CourierOrdersProvider>(
            create: (_) =>
                CourierOrdersInjection.provideProvider(ApiClient())..load(),
            child: Consumer<CourierOrdersProvider>(
              builder: (context, courierProvider, _) {
                final historyOrders = courierProvider.historyOrders;
                final processingOrders = courierProvider.processingOrders;
                final completedToday = courierProvider.completedToday;
                final formatter = NumberFormat('#,###', 'vi_VN');

                Widget emptyState(String text) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 0.18,
                          child: Icon(
                            LucideIcons.package,
                            size: 72,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (courierProvider.isLoading) {
                  return const Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                return DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: SafeArea(
                      child: Column(
                        children: [
                          Container(
                            height: 118,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ĐƠN HÀNG CỦA TÔI',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Hôm nay bạn đã hoàn thành $completedToday đơn',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.refreshCw,
                                    color: Color(0xFF757575),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    courierProvider.load();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Builder(
                              builder: (context) {
                                final tabController = DefaultTabController.of(
                                  context,
                                );
                                const selectedColor = Color(0xFFFF9800);
                                const unselectedTextColor = Color(0xFF757575);
                                return AnimatedBuilder(
                                  animation: tabController,
                                  builder: (context, _) {
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        const pad = 6.0;
                                        const indicatorHeight = 36.0;
                                        final indicatorWidth =
                                            (constraints.maxWidth - pad * 2) /
                                            2;
                                        final indicatorLeft =
                                            tabController.index == 0
                                            ? pad
                                            : pad + indicatorWidth;
                                        return Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              AnimatedPositioned(
                                                duration: const Duration(
                                                  milliseconds: 220,
                                                ),
                                                curve: Curves.easeOutCubic,
                                                left: indicatorLeft,
                                                top: (48 - indicatorHeight) / 2,
                                                child: Container(
                                                  width: indicatorWidth,
                                                  height: indicatorHeight,
                                                  decoration: BoxDecoration(
                                                    color: selectedColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                      onTap: () => tabController
                                                          .animateTo(0),
                                                      child: Center(
                                                        child: Text(
                                                          'Lịch sử',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                tabController
                                                                        .index ==
                                                                    0
                                                                ? Colors.white
                                                                : unselectedTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                      onTap: () => tabController
                                                          .animateTo(1),
                                                      child: Center(
                                                        child: Text(
                                                          'Đang xử lý',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                tabController
                                                                        .index ==
                                                                    1
                                                                ? Colors.white
                                                                : unselectedTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (courierProvider.error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Text(
                                courierProvider.error!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                historyOrders.isEmpty
                                    ? emptyState(
                                        'Bạn chưa hoàn thành đơn hàng nào trong hôm nay',
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          12,
                                          16,
                                          18,
                                        ),
                                        itemCount: historyOrders.length,
                                        separatorBuilder: (context, index) =>
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                        itemBuilder: (context, index) {
                                          final job = historyOrders[index];
                                          final code = job.orderCode;
                                          final status = 'Đã hoàn thành';
                                          final from = job.originName;
                                          final to = job.destinationName;
                                          final orderType = job.order.orderType;
                                          final isLogistics =
                                              job.order.isLogistics;

                                          final time = job.time == null
                                              ? '--:--'
                                              : DateFormat(
                                                  'HH:mm',
                                                ).format(job.time!.toLocal());
                                          final money =
                                              '${formatter.format(job.income)} đ';

                                          const fromPinColor = Color(
                                            0xFF3B82F6,
                                          );
                                          const toPinColor = Color(0xFFEF4444);

                                          return Padding(
                                            padding: EdgeInsets.zero,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.12),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            7,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(
                                                                      0x1AFF9800,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          999,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    code,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color: Color(
                                                                        0xFFFF9800,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 6,
                                                                ),
                                                                Text(
                                                                  isLogistics
                                                                      ? "Vận chuyển"
                                                                      : "Thuê tủ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xFFECFDF3,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    999,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              status,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Color(
                                                                  0xFF15803D,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      if (from != 'N/A' ||
                                                          to != 'N/A')
                                                        Row(
                                                          children: [
                                                            if (from !=
                                                                'N/A') ...[
                                                              Icon(
                                                                LucideIcons
                                                                    .mapPin,
                                                                size: 12,
                                                                color:
                                                                    fromPinColor,
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  from,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            if (from != 'N/A' &&
                                                                to !=
                                                                    'N/A') ...[
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              const Text('→'),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                            ],
                                                            if (to !=
                                                                'N/A') ...[
                                                              Icon(
                                                                LucideIcons
                                                                    .mapPin,
                                                                size: 12,
                                                                color:
                                                                    toPinColor,
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  to,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      if (from != 'N/A' ||
                                                          to != 'N/A')
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            LucideIcons.clock,
                                                            size: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade500,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            time,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 18,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'Thu nhập: $money',
                                                              style: const TextStyle(
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Color(
                                                                  0xFF0F172A,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                context,
                                                              ).push(
                                                                CupertinoPageRoute<
                                                                  void
                                                                >(
                                                                  builder: (_) =>
                                                                      CourierOrderDetailPage(
                                                                        job:
                                                                            job,
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Chi tiết',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Color(
                                                                  0xFFF97316,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                processingOrders.isEmpty
                                    ? emptyState('Chưa có đơn hàng đang xử lý')
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          12,
                                          16,
                                          18,
                                        ),
                                        itemCount: processingOrders.length,
                                        separatorBuilder: (context, index) =>
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                        itemBuilder: (context, index) {
                                          final job = processingOrders[index];
                                          final code = job.orderCode;
                                          final from = job.originName;
                                          final to = job.destinationName;
                                          final time = job.time == null
                                              ? '--:--'
                                              : DateFormat(
                                                  'HH:mm',
                                                ).format(job.time!.toLocal());
                                          final money =
                                              '${formatter.format(job.income)} đ';
                                          return Padding(
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFFDE7D3,
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.10),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                code,
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  color: Color(
                                                                    0xFF111827,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                job
                                                                        .order
                                                                        .isLogistics
                                                                    ? "Vận chuyển"
                                                                    : "Thuê tủ",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        OrderStatusColors.orderBadge(
                                                          job.status,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    if (from != 'N/A' ||
                                                        to != 'N/A') ...[
                                                      if (from != 'N/A')
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              LucideIcons
                                                                  .mapPin,
                                                              size: 12,
                                                              color: Colors
                                                                  .blue
                                                                  .shade500,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                from,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (from != 'N/A')
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                      if (to != 'N/A')
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              LucideIcons
                                                                  .mapPin,
                                                              size: 12,
                                                              color: Colors
                                                                  .red
                                                                  .shade400,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                to,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                    ],
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          LucideIcons.clock3,
                                                          size: 13,
                                                          color: Colors
                                                              .grey
                                                              .shade500,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          time,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          money,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Color(
                                                                  0xFF0F172A,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          if (job.status ==
                                                                  'AWAITING_PICKUP' ||
                                                              job.status ==
                                                                  'ACTIVE') {
                                                            context.push(
                                                              AppRouter
                                                                  .activeDelivery,
                                                              extra: {
                                                                'orderId':
                                                                    job.orderId,
                                                              },
                                                            );
                                                          } else {
                                                            Navigator.of(
                                                              context,
                                                            ).push(
                                                              CupertinoPageRoute<
                                                                void
                                                              >(
                                                                builder: (_) =>
                                                                    CourierOrderDetailPage(
                                                                      job: job,
                                                                    ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                0xFFF97316,
                                                              ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 11,
                                                              ),
                                                        ),
                                                        child: const Text(
                                                          'Xem chi tiết',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildAppBar(context, provider, accentColor),
                  _buildOrderList(context, provider, accentColor),
                ],
              ),
              if (_isFilterOpen) _buildDimmedBackground(),
              _buildFilterSidebar(context, provider, accentColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    OrderProvider provider,
    Color accentColor,
  ) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: true,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: ShadSelect<String>(
        minWidth: 200,
        initialValue: provider.orderTypeFilter ?? 'ALL',
        onChanged: (value) {
          provider.fetchOrders(orderType: value);
        },
        selectedOptionBuilder: (context, value) => Text(
          _categories[value] ?? 'Đơn hàng',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        options: _categories.entries
            .map((e) => ShadOption(value: e.key, child: Text(e.value)))
            .toList(),
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.refreshCw, color: accentColor, size: 20),
          onPressed: () {
            provider.fetchOrders();
          },
        ),
        IconButton(
          icon: Icon(LucideIcons.slidersHorizontal, color: accentColor),
          onPressed: _toggleFilter,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    OrderProvider provider,
    Color accentColor,
  ) {
    if (provider.isLoading) {
      return const SliverFillRemaining(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: OrderSkeletonLoading(itemCount: 4, type: 'customer'),
        ),
      );
    }

    final displayOrders = _getDisplayOrders(provider);

    if (displayOrders.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.inbox, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'Chưa có đơn hàng nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == displayOrders.length) {
            if (provider.isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OrderCard(order: displayOrders[index]),
              ),
              if (index < displayOrders.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
            ],
          );
        }, childCount: displayOrders.length + (provider.isLoadingMore ? 1 : 0)),
      ),
    );
  }

  Widget _buildDimmedBackground() {
    return GestureDetector(
      onTap: _toggleFilter,
      child: Container(color: Colors.black.withOpacity(0.5)),
    );
  }

  Widget _buildFilterSidebar(
    BuildContext context,
    OrderProvider provider,
    Color accentColor,
  ) {
    return SlideTransition(
      position: _filterOffset,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width:
              MediaQuery.of(context).size.width *
              0.45, // Approximately 1/3 or more for usability
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Bộ lọc nâng cao',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: _toggleFilter,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildFilterField('Mã đơn hàng', _orderCodeController),
                      const SizedBox(height: 20),
                      _buildFilterField('Tìm kiếm', _searchController),
                      const SizedBox(height: 20),
                      const Text(
                        'Trạng thái',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ShadSelect<String>(
                        placeholder: const Text('Chọn trạng thái'),
                        initialValue: provider.statusFilter,
                        onChanged: (selected) {
                          provider.fetchOrders(status: selected);
                        },
                        selectedOptionBuilder: (context, value) =>
                            Text(_statuses[value] ?? 'Trạng thái'),
                        options: _statuses.entries
                            .map(
                              (e) => ShadOption(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                      ShadButton(
                        onPressed: () {
                          provider.fetchOrders(
                            orderCode: _orderCodeController.text,
                            search: _searchController.text,
                          );
                          _toggleFilter();
                        },
                        child: const Text('Áp dụng'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          _orderCodeController.clear();
                          _searchController.clear();
                          provider.fetchOrders();
                          _toggleFilter();
                        },
                        child: const Text(
                          'Xóa bộ lọc',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ShadInput(controller: controller, placeholder: Text('Nhập $label...')),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isRental = order.isPersonalRental;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<dynamic>(
            builder: (_) =>
                CustomerOrderDetailPage(orderId: order.id, order: order),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OrderStatusColors.orderBadge(order.status),
                        const SizedBox(width: 8),
                        if (order.paymentStatus != null)
                          OrderStatusColors.paymentBadge(order.paymentStatus),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            order.isLogistics ? 'Vận chuyển' : 'Thuê tủ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.orderCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isRental ? 'Thuê tủ' : 'Vận chuyển',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.black38),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 12),
            if (isRental)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _feeCol('Phí tích lũy', _fmt(order.accumulatedFee)),
                  _feeCol(
                    'Đã thu',
                    _fmt(order.totalCollected),
                    valueColor: const Color(0xFF2E7D32),
                  ),
                  _feeCol('Đơn giá', _fmt(order.currentRate)),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phí: ${_fmt(order.accumulatedFee)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Thu: ${_fmt(order.totalCollected)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(v);

  Widget _feeCol(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
