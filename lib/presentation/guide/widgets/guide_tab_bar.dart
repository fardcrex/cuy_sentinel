import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class GuideTabBar extends StatelessWidget {
  const GuideTabBar({super.key, required this.controller});

  final TabController controller;

  static const _labels = [
    'Resumen',
    'Dashboard',
    'Servicios',
    'Métricas',
    'Alertas',
    'Usuarios',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panel,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        tabs: _labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }
}
