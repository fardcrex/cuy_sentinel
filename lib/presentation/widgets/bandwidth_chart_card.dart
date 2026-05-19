import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../metrics/metric_model.dart';
import 'animated_number_text.dart';
import 'app_card.dart';
import 'metric_chart_placeholder.dart';
import 'metric_stats_row.dart';

class BandwidthChartCard extends StatefulWidget {
  const BandwidthChartCard({
    super.key,
    required this.inBuckets,
    required this.outBuckets,
  });

  final List<MetricsBucket> inBuckets;
  final List<MetricsBucket> outBuckets;

  @override
  State<BandwidthChartCard> createState() => _BandwidthChartCardState();
}

class _BandwidthChartCardState extends State<BandwidthChartCard> {
  int _serviceIndex = 0; // 0=Ambos, 1=Passbolt, 2=ChkMonitor

  static const _services = ['Ambos', 'Passbolt', 'ChkMonitor'];

  // Sticky max: only grows so the scale is stable between frames,
  // which lets MetricChartPlaceholder detect the sliding-window shift.
  double _displayMax = 0;

  @override
  void initState() {
    super.initState();
    _updateMax();
  }

  @override
  void didUpdateWidget(covariant BandwidthChartCard old) {
    super.didUpdateWidget(old);
    _updateMax();
  }

  void _updateMax() {
    final values = [
      ...widget.inBuckets,
      ...widget.outBuckets,
    ].map(_rawValue).whereType<double>();
    if (values.isEmpty) return;
    final curMax = values.reduce((a, b) => a > b ? a : b);
    if (curMax > _displayMax) _displayMax = curMax;
  }

  double? _rawValue(MetricsBucket b) => switch (_serviceIndex) {
    0 => b.isComplete ? b.passbolt! + b.chkmonitor! : null,
    1 => b.passbolt,
    _ => b.chkmonitor,
  };

  @override
  Widget build(BuildContext context) {
    final inRaw = widget.inBuckets.map(_rawValue).toList();
    final outRaw = widget.outBuckets.map(_rawValue).toList();
    // LOG: Mostrar los arrays de puntos que se van a graficar (incluyendo nulls)
    // Solo para debug visual de gaps
    // ignore: avoid_print
    print('[BandwidthChartCard] Entrante: $inRaw');
    // ignore: avoid_print
    print('[BandwidthChartCard] Saliente: $outRaw');
    final inStats = _buildStats(inRaw);
    final outStats = _buildStats(outRaw);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ancho de banda',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              for (var i = 0; i < _services.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _Chip(
                  label: _services[i],
                  selected: i == _serviceIndex,
                  onTap: () => setState(() {
                    _serviceIndex = i;
                    _displayMax = 0;
                    _updateMax();
                  }),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Entrante / Saliente — ${_services[_serviceIndex]}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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

  List<double?> _buildPoints(List<double?> rawValues) {
    if (_displayMax <= 0) return List.filled(rawValues.length, null);
    return rawValues.map((v) {
      if (v == null) return null;
      return (0.12 + (v / _displayMax) * 0.76).clamp(0.0, 1.0);
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
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
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
