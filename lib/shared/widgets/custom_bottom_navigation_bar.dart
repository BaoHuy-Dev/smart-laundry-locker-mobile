import 'package:flutter/material.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

/// Builder function for custom icons
typedef IconBuilder = Widget Function(Color color, double size);

/// Floating navy bottom navigation bar (ported from the legacy React Native
/// customer app): a rounded navy pill with a raised, gradient QR action in the
/// center. Active tabs use a soft white highlight + cyan text/icon.
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AislBrand.navBar,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = currentIndex == index;

              if (item.isProminent) {
                return _buildProminent(item, index);
              }
              return _buildItem(item, index, isActive);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(NavigationItem item, int index, bool isActive) {
    final color = isActive ? Colors.white : AislBrand.navInactive;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(isActive ? item.activeIcon : item.icon, color),
                if (item.label.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProminent(NavigationItem item, int index) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(index),
          child: Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AislBrand.cyan, AislBrand.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AislBrand.cyan.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _buildIcon(item.icon, Colors.white, size: 26),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon, Color color, {double size = 22}) {
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
