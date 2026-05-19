import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../metrics/metric_model.dart';
import 'animated_number_text.dart';
import 'app_card.dart';
import 'metric_chart_placeholder.dart';
import 'metric_stats_row.dart';

class BandwidthChartCard extends StatelessWidget {
  const BandwidthChartCard({
    super.key,
    required this.inBuckets,
    required this.outBuckets,
  });

  final List<MetricsBucket> inBuckets;
  final List<MetricsBucket> outBuckets;

  @override
  Widget build(BuildContext context) {
    final inRaw = _toRaw(inBuckets);
    final outRaw = _toRaw(outBuckets);
    final inStats = _buildStats(inRaw);
    final outStats = _buildStats(outRaw);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ancho de banda',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tráfico agregado — Passbolt + ChkMonitor',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          _SeriesRow(label: 'Entrante', color: AppColors.chartNetwork),
          const SizedBox(height: 8),
          MetricChartPlaceholder(
            points: _buildPoints(inRaw),
            lineColor: AppColors.chartNetwork,
            height: 100,
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: _buildStatValue(inStats.min),
            avg: _buildStatValue(inStats.avg),
            max: _buildStatValue(inStats.max),
            color: AppColors.chartNetwork,
          ),
          const SizedBox(height: 20),
          _SeriesRow(label: 'Saliente', color: AppColors.chartCpu),
          const SizedBox(height: 8),
          MetricChartPlaceholder(
            points: _buildPoints(outRaw),
            lineColor: AppColors.chartCpu,
            height: 100,
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: _buildStatValue(outStats.min),
            avg: _buildStatValue(outStats.avg),
            max: _buildStatValue(outStats.max),
            color: AppColors.chartCpu,
          ),
        ],
      ),
    );
  }

  List<double?> _toRaw(List<MetricsBucket> buckets) => buckets
      .map((b) => b.isComplete ? b.passbolt! + b.chkmonitor! : null)
      .toList();

  List<double?> _buildPoints(List<double?> rawValues) {
    final nonNull = rawValues.whereType<double>().toList();
    if (nonNull.isEmpty) return rawValues;
    final minV = nonNull.reduce((a, b) => a < b ? a : b);
    final maxV = nonNull.reduce((a, b) => a > b ? a : b);
    final span = maxV - minV;
    return rawValues.map((v) {
      if (v == null) return null;
      return span <= 0.0001 ? 0.5 : 0.12 + ((v - minV) / span) * 0.76;
    }).toList();
  }

  _BandwidthStats _buildStats(List<double?> rawValues) {
    final values = rawValues.whereType<double>().toList();
    if (values.isEmpty) return const _BandwidthStats();
    values.sort();
    final avg = values.reduce((a, b) => a + b) / values.length;
    return _BandwidthStats(min: values.first, avg: avg, max: values.last);
  }

  Widget _buildStatValue(double? value) {
    if (value == null) return const Text('—');
    return AnimatedNumberText(value: value, decimalDigits: 1, suffix: ' MB/s');
  }
}

class _BandwidthStats {
  const _BandwidthStats({this.min, this.avg, this.max});
  final double? min;
  final double? avg;
  final double? max;
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
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
