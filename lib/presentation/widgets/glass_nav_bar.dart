import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'nav_style_cubit.dart';

class NavDestinationData {
  const NavDestinationData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.style = NavGlassStyle.dark,
  });

  final List<NavDestinationData> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final NavGlassStyle style;

  Color get _bgColor => style == NavGlassStyle.dark
      ? const Color(0xCC08111A) // darkPanel 80%
      : AppColors.primary.withValues(alpha: 0.10);

  Color get _borderColor => style == NavGlassStyle.dark
      ? Colors.white.withValues(alpha: 0.09)
      : AppColors.primary.withValues(alpha: 0.35);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: _borderColor, width: 0.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (i) {
              return _GlassNavItem(
                icon: destinations[i].icon,
                label: destinations[i].label,
                isSelected: i == selectedIndex,
                style: style,
                onTap: () => onDestinationSelected(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.style,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final NavGlassStyle style;
  final VoidCallback onTap;

  Color get _activeColor => AppColors.primary;

  Color get _inactiveColor => style == NavGlassStyle.dark
      ? AppColors.textInactive
      : AppColors.primary.withValues(alpha: 0.45);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _activeColor : _inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(28),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.10 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: isSelected ? 0.1 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
