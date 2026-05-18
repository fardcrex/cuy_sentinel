import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_chart_placeholder.dart';
import 'metric_stats_row.dart';

class ResourceChartCard extends StatefulWidget {
  const ResourceChartCard({super.key});

  @override
  State<ResourceChartCard> createState() => _ResourceChartCardState();
}

class _ResourceChartCardState extends State<ResourceChartCard> {
  int _serviceIndex = 0; // 0=Passbolt, 1=ChkMonitor
  int _metricIndex = 0; // 0=CPU, 1=RAM, 2=Disco

  static const _services = ['Passbolt', 'ChkMonitor'];
  static const _metrics = ['CPU', 'RAM', 'Disco'];

  static const _data = [
    // Passbolt
    [
      // CPU
      [0.40, 0.42, 0.44, 0.47, 0.45, 0.43, 0.48, 0.50, 0.46, 0.44, 0.45, 0.47, 0.46, 0.48, 0.45, 0.44, 0.46, 0.45],
      // RAM
      [0.28, 0.29, 0.30, 0.31, 0.30, 0.31, 0.33, 0.34, 0.32, 0.31, 0.30, 0.32, 0.33, 0.34, 0.33, 0.32, 0.31, 0.30],
      // Disco
      [0.56, 0.57, 0.57, 0.58, 0.58, 0.57, 0.58, 0.59, 0.58, 0.57, 0.58, 0.58, 0.59, 0.58, 0.58, 0.57, 0.58, 0.58],
    ],
    // ChkMonitor
    [
      // CPU
      [0.10, 0.11, 0.12, 0.13, 0.11, 0.12, 0.14, 0.13, 0.12, 0.11, 0.12, 0.13, 0.12, 0.11, 0.12, 0.13, 0.12, 0.12],
      // RAM
      [0.23, 0.24, 0.24, 0.25, 0.24, 0.25, 0.25, 0.26, 0.25, 0.24, 0.25, 0.25, 0.24, 0.25, 0.25, 0.24, 0.25, 0.25],
      // Disco
      [0.42, 0.43, 0.43, 0.44, 0.44, 0.43, 0.44, 0.45, 0.44, 0.43, 0.44, 0.44, 0.43, 0.44, 0.44, 0.43, 0.44, 0.44],
    ],
  ];

  static const _stats = [
    // Passbolt
    [
      ('38%', '45%', '52%'),
      ('28%', '30%', '34%'),
      ('55%', '58%', '59%'),
    ],
    // ChkMonitor
    [
      ('9%', '12%', '15%'),
      ('23%', '25%', '26%'),
      ('42%', '44%', '45%'),
    ],
  ];

  static const _colors = [AppColors.chartCpu, AppColors.chartRam, AppColors.chartDisk];

  @override
  Widget build(BuildContext context) {
    final points = _data[_serviceIndex][_metricIndex].map((v) => v).toList();
    final stat = _stats[_serviceIndex][_metricIndex];
    final color = _colors[_metricIndex];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Uso de recursos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _services.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _Chip(
                  label: _services[i],
                  selected: i == _serviceIndex,
                  onTap: () => setState(() => _serviceIndex = i),
                ),
              ],
              const Spacer(),
              for (var i = 0; i < _metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _Chip(
                  label: _metrics[i],
                  selected: i == _metricIndex,
                  color: _colors[i],
                  onTap: () => setState(() => _metricIndex = i),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          MetricChartPlaceholder(
            points: points,
            lineColor: color,
            height: 180,
          ),
          const SizedBox(height: 16),
          MetricStatsRow(
            min: stat.$1,
            avg: stat.$2,
            max: stat.$3,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.5) : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
