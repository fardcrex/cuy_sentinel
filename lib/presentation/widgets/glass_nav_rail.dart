import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'glass_nav_bar.dart';
import 'nav_style_cubit.dart';

class GlassNavRail extends StatelessWidget {
  const GlassNavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.leading,
    required this.onLogout,
    this.style = NavGlassStyle.dark,
  });

  final List<NavDestinationData> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget leading;
  final VoidCallback onLogout;
  final NavGlassStyle style;

  static const double width = 76;

  Color get _bgColor => style == NavGlassStyle.dark
      ? const Color(0xCC08111A)
      : AppColors.primary.withValues(alpha: 0.10);

  Color get _borderColor => style == NavGlassStyle.dark
      ? Colors.white.withValues(alpha: 0.09)
      : AppColors.primary.withValues(alpha: 0.35);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: _borderColor, width: 0.6),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: leading,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(destinations.length, (i) {
                    return _GlassRailItem(
                      icon: destinations[i].icon,
                      label: destinations[i].label,
                      isSelected: i == selectedIndex,
                      style: style,
                      onTap: () => onDestinationSelected(i),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: Icon(
                    Icons.logout_rounded,
                    color: style == NavGlassStyle.dark
                        ? AppColors.textInactive
                        : AppColors.primary.withValues(alpha: 0.45),
                    size: 20,
                  ),
                  onPressed: onLogout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassRailItem extends StatelessWidget {
  const _GlassRailItem({
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
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.10 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
