import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_laundry_locker/core/core.dart';
import 'package:smart_laundry_locker/features/auth/providers/auth_provider.dart';

/// User Home Screen mapped from RN's app/user/(tabs)/index.tsx
class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value?.user;
    final userName = user?.firstName ?? 'Khách';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Xin chào, $userName 👋',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Banner/Hero ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đặt lịch giặt ủi ngay',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tiện lợi - Nhanh chóng - An toàn',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/user/lockers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Bắt đầu'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Quick Actions ───
            Text(
              'Tiện ích',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.local_laundry_service,
                  label: 'Giặt ủi',
                  onTap: () => context.go('/user/lockers'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.inventory_2,
                  label: 'Gửi đồ',
                  onTap: () => context.go('/user/lockers'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.store,
                  label: 'Cửa hàng',
                  onTap: () => context.go('/user/stores'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.confirmation_number,
                  label: 'Voucher',
                  onTap: () => context.go('/user/vouchers'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ─── Active Orders ───
            Text(
              'Đơn hàng đang xử lý',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Không có đơn hàng nào',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightIcon,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
