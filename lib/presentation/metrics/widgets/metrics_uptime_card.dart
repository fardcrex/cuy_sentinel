import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/animated_number_text.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_chart_placeholder.dart';
import '../../widgets/metric_stats_row.dart';
import '../metric_model.dart';

class MetricsUptimeCard extends StatelessWidget {
  const MetricsUptimeCard({
    super.key,
    required this.buckets,
  });

  /// uptimeBuckets de MetricsLoadedModelX — valores en [0.0, 1.0], null = gap
  final List<MetricsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final ratios = buckets.map(_uptimeRatio).toList();
    final stats = _buildStats(ratios.whereType<double>().toList());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de disponibilidad',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ratio de disponibilidad combinado',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          MetricChartPlaceholder(
            points: ratios,
            lineColor: AppColors.primary,
            height: 140,
          ),
          const SizedBox(height: 14),
          MetricStatsRow(
            min: _statWidget(stats.min),
            avg: _statWidget(stats.avg),
            max: _statWidget(stats.max),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Ratio medio: (pb + ck) / 2 cuando ambos disponibles
  double? _uptimeRatio(MetricsBucket b) =>
      switch ((b.passbolt, b.chkmonitor)) {
        (final pb?, final ck?) => (pb + ck) / 2,
        (final pb?, null) => pb,
        (null, final ck?) => ck,
        (null, null) => null,
      };

  _UptimeStats _buildStats(List<double> values) {
    if (values.isEmpty) return const _UptimeStats();
    final percents = values.map((v) => v * 100).toList()..sort();
    final avg = percents.reduce((a, b) => a + b) / percents.length;
    return _UptimeStats(min: percents.first, avg: avg, max: percents.last);
  }

  Widget _statWidget(double? value) {
    if (value == null) return const Text('—');
    return AnimatedNumberText(value: value, decimalDigits: 1, suffix: '%');
  }
}

class _UptimeStats {
  const _UptimeStats({this.min, this.avg, this.max});
  final double? min;
  final double? avg;
  final double? max;
}
