import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/features/promotions/data/models/promotion_model.dart';
import 'package:smart_laundry_locker/features/promotions/presentation/providers/promotion_provider.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

class PromotionsPage extends ConsumerStatefulWidget {
  const PromotionsPage({super.key});

  @override
  ConsumerState<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends ConsumerState<PromotionsPage> {
  static const _gradients = [
    [Color(0xFF003D5B), Color(0xFF0077B6)],
    [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    [Color(0xFF059669), Color(0xFF10B981)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
    [Color(0xFFE53E3E), Color(0xFFFC8181)],
    [Color(0xFF0F172A), Color(0xFF334155)],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(promotionNotifierProvider).load();
    });
  }

  List<Color> _gradientFor(int id) {
    return _gradients[id % _gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(promotionNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          BrandHeroHeader(
            title: 'Ưu đãi & Flash Sale',
            subtitle: 'Khám phá ưu đãi đang hiệu lực hôm nay',
            onBack: () => context.pop(),
            trailing: BrandCircleIconButton(
              icon: LucideIcons.refreshCw,
              onTap: () => ref.read(promotionNotifierProvider).load(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AislBrand.navy,
              onRefresh: () => ref.read(promotionNotifierProvider).load(),
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PromotionProvider provider) {
    if (provider.isLoading && provider.promotions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AislBrand.navy));
    }
    if (provider.error != null && provider.promotions.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(LucideIcons.triangleAlert, size: 52, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      );
    }
    if (provider.promotions.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(LucideIcons.ticketSlash, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Chưa có ưu đãi nào đang hiệu lực',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: provider.promotions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) => _buildPromoCard(provider.promotions[index], index),
    );
  }

  Widget _buildPromoCard(PromotionModel promo, int index) {
    final colors = _gradientFor(promo.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Gradient banner
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (promo.imageUrl != null && promo.imageUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: promo.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _gradientBanner(colors),
                          errorWidget: (_, __, ___) => _gradientBanner(colors),
                        )
                      : _gradientBanner(colors),
                  // Dark overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Top-left: Flash Sale tag
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.zap, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'FLASH SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top-right: Discount badge
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promo.discountLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  // Bottom: name
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Text(
                      promo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (promo.description != null && promo.description!.isNotEmpty) ...[
                    Text(
                      promo.description!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (promo.minOrderLabel != null) ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.info, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          promo.minOrderLabel!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      // Expiry
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 12,
                            color: promo.isExpiringSoon ? const Color(0xFFE53E3E) : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promo.expiryLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: promo.isExpiringSoon ? const Color(0xFFE53E3E) : Colors.grey.shade500,
                              fontWeight: promo.isExpiringSoon ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Code chip + copy
                      GestureDetector(
                        onTap: () => _copyCode(context, promo.code),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AislBrand.navy.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AislBrand.navy.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                promo.code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AislBrand.navy,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(LucideIcons.copy, size: 13, color: AislBrand.navy),
                            ],
                          ),
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
    );
  }

  Widget _gradientBanner(List<Color> colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(LucideIcons.ticket, size: 52, color: Colors.white24),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Đã sao chép mã: $code'),
          ],
        ),
        backgroundColor: AislBrand.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
