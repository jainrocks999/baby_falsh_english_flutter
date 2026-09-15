import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class KidsBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  const KidsBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.videogame_asset_rounded,
                label: 'Games',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                selected: false,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final color = selected ? const Color(0xff2b9f01) : Colors.black45;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isTablet ? 26 : 30),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.fontSize(context, isTablet ? 2 : 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
