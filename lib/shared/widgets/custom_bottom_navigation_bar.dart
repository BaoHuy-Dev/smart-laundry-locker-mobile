import 'package:smart_laundry_locker/core/widgets/qr_scanner_button.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:flutter/material.dart';

/// Builder function for custom icons
typedef IconBuilder = Widget Function(Color color, double size);

/// Custom bottom navigation bar with 5 items using Lucide icons or custom SVGs
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final List<NavigationItem> items;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AISLShadcnTheme.lightTheme;

    return Material(
      color: theme.colorScheme.background,
      elevation: 8,
      shadowColor: Colors.black12,
      child: SafeArea(
        child: SizedBox(
          height: 78,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              final isActive = currentIndex == index;
              const activeColor = AISLShadcnTheme.navyPrimary;
              final inactiveColor = theme.colorScheme.mutedForeground;
              final color = isActive ? activeColor : inactiveColor;

              if (item.isProminent) {
                return Expanded(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -4),
                      child: QrScannerButton(
                        onTap: () => onTap(index),
                        isActive: isActive,
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIcon(
                          isActive ? item.activeIcon : item.icon,
                          color,
                          size: 24,
                        ),
                        if (item.label.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon, Color color, {double size = 24}) {
    if (icon is IconData) {
      return Icon(icon, size: size, color: color);
    } else if (icon is IconBuilder) {
      return icon(color, size);
    }
    return SizedBox(width: size, height: size);
  }
}

/// Navigation item model for custom bottom navigation
class NavigationItem {
  final dynamic icon; // IconData or IconBuilder
  final dynamic activeIcon; // IconData or IconBuilder
  final String label;
  final String route;
  final bool isProminent;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isProminent = false,
  }) : assert(
         (icon is IconData || icon is IconBuilder) &&
             (activeIcon is IconData || activeIcon is IconBuilder),
         'icon and activeIcon must be either IconData or IconBuilder',
       );
}
