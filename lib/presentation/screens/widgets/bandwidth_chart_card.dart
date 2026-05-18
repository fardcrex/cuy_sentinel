import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_chart_placeholder.dart';
import 'metric_stats_row.dart';

class BandwidthChartCard extends StatelessWidget {
  const BandwidthChartCard({super.key});

  static const _inPoints = [
    0.20, 0.24, 0.22, 0.28, 0.25, 0.30, 0.23, 0.27, 0.31, 0.26, 0.29, 0.23,
    0.28, 0.33, 0.27, 0.30, 0.36, 0.29,
  ];

  static const _outPoints = [
    0.10, 0.12, 0.11, 0.14, 0.12, 0.15, 0.11, 0.13, 0.15, 0.12, 0.14, 0.11,
    0.13, 0.16, 0.13, 0.14, 0.17, 0.14,
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ancho de banda',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tráfico agregado — Passbolt + ChkMonitor',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _SeriesRow(label: 'Entrante', color: AppColors.chartNetwork),
          const SizedBox(height: 8),
          MetricChartPlaceholder(
            points: _inPoints,
            lineColor: AppColors.chartNetwork,
            height: 100,
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: '0.8 MB/s',
            avg: '2.3 MB/s',
            max: '4.1 MB/s',
            color: AppColors.chartNetwork,
          ),
          const SizedBox(height: 20),
          _SeriesRow(label: 'Saliente', color: AppColors.chartCpu),
          const SizedBox(height: 8),
          MetricChartPlaceholder(
            points: _outPoints,
            lineColor: AppColors.chartCpu,
            height: 100,
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: '0.3 MB/s',
            avg: '1.1 MB/s',
            max: '2.0 MB/s',
            color: AppColors.chartCpu,
          ),
        ],
      ),
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
