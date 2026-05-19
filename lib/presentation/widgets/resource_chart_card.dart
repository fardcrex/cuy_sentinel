import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/metrics/domain/entities/metric.dart';
import 'animated_number_text.dart';
import 'app_card.dart';
import 'metric_chart_placeholder.dart';
import 'metric_stats_row.dart';

class ResourceChartCard extends StatefulWidget {
  const ResourceChartCard({
    super.key,
    required this.passboltMetrics,
    required this.chkmonitorMetrics,
  });

  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;

  @override
  State<ResourceChartCard> createState() => _ResourceChartCardState();
}

class _ResourceChartCardState extends State<ResourceChartCard> {
  int _serviceIndex = 0; // 0=Passbolt, 1=ChkMonitor
  int _metricIndex = 0; // 0=CPU, 1=RAM, 2=Disco

  static const _services = ['Passbolt', 'ChkMonitor'];
  static const _metrics = ['CPU', 'RAM', 'Disco'];

  static const _colors = [
    AppColors.chartCpu,
    AppColors.chartRam,
    AppColors.chartDisk,
  ];

  @override
  Widget build(BuildContext context) {
    final selectedMetrics = _serviceIndex == 0
        ? widget.passboltMetrics
        : widget.chkmonitorMetrics;
    final points = _buildPoints(selectedMetrics, _metricIndex);
    final stat = _buildStats(selectedMetrics, _metricIndex);
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
          MetricChartPlaceholder(points: points, lineColor: color, height: 180),
          const SizedBox(height: 16),
          MetricStatsRow(
            min: _buildStatValue(stat.min),
            avg: _buildStatValue(stat.avg),
            max: _buildStatValue(stat.max),
            color: color,
          ),
        ],
      ),
    );
  }

  List<double> _buildPoints(List<Metric> metrics, int metricIndex) {
    const target = 18;
    final sorted = [...metrics]
      ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
    final values = sorted
        .map((metric) => _metricValue(metric, metricIndex))
        .whereType<double>()
        .map((value) => (value / 100).clamp(0.0, 1.0))
        .toList();

    if (values.isEmpty) return List.filled(target, 0.0);
    if (values.length >= target) return values.take(target).toList();
    return List.filled(target - values.length, values.first) + values;
  }

  _MetricStatSummary _buildStats(List<Metric> metrics, int metricIndex) {
    final values = metrics
        .map((metric) => _metricValue(metric, metricIndex))
        .whereType<double>()
        .toList();

    if (values.isEmpty) {
      return const _MetricStatSummary();
    }

    values.sort();
    final avg = values.reduce((a, b) => a + b) / values.length;
    return _MetricStatSummary(min: values.first, avg: avg, max: values.last);
  }

  double? _metricValue(Metric metric, int metricIndex) => switch (metricIndex) {
    0 => metric.cpuUsagePercent,
    1 => metric.ramUsagePercent,
    2 => metric.diskUsagePercent,
    _ => null,
  };

  Widget _buildStatValue(double? value) {
    if (value == null) return const Text('—');
    return AnimatedNumberText(value: value, suffix: '%');
  }
}

class _MetricStatSummary {
  const _MetricStatSummary({this.min, this.avg, this.max});

  final double? min;
  final double? avg;
  final double? max;
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
          color: selected ? accent.withValues(alpha: 0.16) : AppColors.panel,
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
