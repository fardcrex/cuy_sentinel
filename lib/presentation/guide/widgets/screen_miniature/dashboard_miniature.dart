import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class DashboardMiniature extends StatelessWidget {
  const DashboardMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // 4 stat cards en fila
          Row(
            children: [
              _StatCard(color: AppColors.primary),
              const SizedBox(width: 3),
              _StatCard(color: AppColors.primaryBright),
              const SizedBox(width: 3),
              _StatCard(color: AppColors.warning),
              const SizedBox(width: 3),
              _StatCard(color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 5),
          // 2 columnas: flex 2 (charts) / flex 1 (sidebar cards)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniChartBox(color: AppColors.chartCpu),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: MiniChartBox(
                          color: AppColors.chartNetwork,
                          points: const [
                            0.0, 0.4, 0.2, 0.65, 0.35, 0.5,
                            0.55, 0.8, 0.7, 0.45, 0.85, 0.7, 1.0, 0.55,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniBox(accentColor: AppColors.primary),
                      ),
                      const SizedBox(height: 3),
                      const Expanded(child: MiniBox()),
                      const SizedBox(height: 3),
                      const Expanded(child: MiniBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
