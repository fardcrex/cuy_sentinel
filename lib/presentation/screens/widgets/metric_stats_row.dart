import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MetricStatsRow extends StatelessWidget {
  const MetricStatsRow({
    super.key,
    required this.min,
    required this.avg,
    required this.max,
    required this.color,
  });

  final String min;
  final String avg;
  final String max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(label: 'Mín', value: min, color: AppColors.textSecondary),
        const SizedBox(width: 24),
        _StatItem(label: 'Prom', value: avg, color: color),
        const SizedBox(width: 24),
        _StatItem(label: 'Máx', value: max, color: AppColors.critical),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
