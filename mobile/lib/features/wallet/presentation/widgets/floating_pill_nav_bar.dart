import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';

class NavItemData {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class FloatingPillNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onTabSelected;

  const FloatingPillNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<NavItemData> _items = [
    NavItemData(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.credit_card_rounded,
      activeIcon: Icons.credit_card_rounded,
      label: 'Cards',
    ),
    NavItemData(
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
    NavItemData(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
      label: 'Menu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 22,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF191B21), // Sleek matte dark charcoal capsule
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primaryYellow.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_items.length, (index) {
              return _buildNavItem(
                index: index,
                item: _items[index],
                isSelected: selectedIndex == index,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required NavItemData item,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : Colors.transparent, // #F3D602
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (item.activeIcon ?? item.icon) : item.icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF1B1D28) // Bold dark navy contrast on yellow
                  : Colors.white.withValues(alpha: 0.75),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Color(0xFF1B1D28),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


