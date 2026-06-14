import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/features/stores/domain/entities/store.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

/// Image-banner store card (ported from the legacy RN customer app): a photo
/// header with a status badge + favourite heart, then the store name/address.
class StoreCard extends StatelessWidget {
  const StoreCard({
    required this.store,
    required this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    super.key,
  });

  final Store store;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AislBrand.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: (store.image != null && store.image!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: store.image!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const _Banner(),
                            errorWidget: (_, __, ___) => const _Banner(),
                          )
                        : const _Banner(),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: BrandStatusBadge(
                    label: store.isActive ? 'Mở cửa' : 'Đóng',
                    dotColor: store.isActive
                        ? AislBrand.statusGreen
                        : Colors.grey,
                    textColor: store.isActive
                        ? AislBrand.statusGreenText
                        : Colors.grey.shade700,
                  ),
                ),
                if (onToggleFavorite != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: BrandCircleIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorite
                          ? const Color(0xFFE91E63)
                          : AislBrand.navy,
                      background: Colors.white.withValues(alpha: 0.92),
                      size: 34,
                      iconSize: 18,
                      onTap: onToggleFavorite!,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AislBrand.textTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: AislBrand.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.address ?? 'Chưa có địa chỉ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AislBrand.textMuted,
                          ),
                        ),
                      ),
                      if (store.distanceKm != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${store.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AislBrand.blue,
                          ),
                        ),
                      ],
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

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AislBrand.softHeaderGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(LucideIcons.store, size: 52, color: AislBrand.navy),
    );
  }
}
