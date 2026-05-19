import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class MetricsMiniature extends StatelessWidget {
  const MetricsMiniature({super.key});

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
          Row(
            children: [
              for (final t in ['1h', '6h', '24h', '7d'])
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: _FilterChip(label: t, active: t == '1h'),
                ),
              const Spacer(),
              _FilterChip(label: 'PB', active: false),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _SummaryCard(color: AppColors.chartCpu),
              const SizedBox(width: 2),
              _SummaryCard(color: AppColors.chartRam),
              const SizedBox(width: 2),
              _SummaryCard(color: AppColors.chartDisk),
              const SizedBox(width: 2),
              _SummaryCard(color: AppColors.chartNetwork),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniChartBox(color: AppColors.chartCpu),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: MiniChartBox(color: AppColors.chartNetwork),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _UptimeBox()),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.stroke,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          color: active ? AppColors.primary : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 2,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _UptimeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              for (var i = 0; i < 8; i++) ...[
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 3
                          ? AppColors.danger.withValues(alpha: 0.6)
                          : AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                if (i < 7) const SizedBox(width: 1),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
