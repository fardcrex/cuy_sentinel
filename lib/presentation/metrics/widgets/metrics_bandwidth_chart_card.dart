import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/animated_number_text.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_stats_row.dart';
import '../metric_model.dart';

class MetricsBandwidthChartCard extends StatefulWidget {
  const MetricsBandwidthChartCard({
    super.key,
    required this.inBuckets,
    required this.outBuckets,
  });

  final List<MetricsBucket> inBuckets;
  final List<MetricsBucket> outBuckets;

  @override
  State<MetricsBandwidthChartCard> createState() =>
      _MetricsBandwidthChartCardState();
}

class _MetricsBandwidthChartCardState
    extends State<MetricsBandwidthChartCard> {
  int _serviceIndex = 0; // 0=Ambos, 1=Passbolt, 2=ChkMonitor

  static const _services = ['Ambos', 'Passbolt', 'ChkMonitor'];

  @override
  Widget build(BuildContext context) {
    final inValues = _toValues(widget.inBuckets);
    final outValues = _toValues(widget.outBuckets);

    final allNonNull = [
      ...inValues.whereType<double>(),
      ...outValues.whereType<double>(),
    ];
    final maxY = allNonNull.isEmpty ? 1.0 : allNonNull.reduce(math.max);

    final inStats = _buildStats(inValues.whereType<double>().toList());
    final outStats = _buildStats(outValues.whereType<double>().toList());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ancho de banda',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              for (var i = 0; i < _services.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _Chip(
                  label: _services[i],
                  selected: i == _serviceIndex,
                  onTap: () => setState(() => _serviceIndex = i),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Entrante / Saliente — ${_services[_serviceIndex]}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          _SeriesLabel(label: 'Entrante', color: AppColors.chartNetwork),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _BandwidthPainter(
                values: inValues,
                maxY: maxY,
                lineColor: AppColors.chartNetwork,
              ),
            ),
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: _statWidget(inStats.min),
            avg: _statWidget(inStats.avg),
            max: _statWidget(inStats.max),
            color: AppColors.chartNetwork,
          ),
          const SizedBox(height: 20),
          _SeriesLabel(label: 'Saliente', color: AppColors.chartCpu),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _BandwidthPainter(
                values: outValues,
                maxY: maxY,
                lineColor: AppColors.chartCpu,
              ),
            ),
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: _statWidget(outStats.min),
            avg: _statWidget(outStats.avg),
            max: _statWidget(outStats.max),
            color: AppColors.chartCpu,
          ),
        ],
      ),
    );
  }

  List<double?> _toValues(List<MetricsBucket> buckets) => buckets.map((b) {
        return switch (_serviceIndex) {
          0 => b.isComplete ? b.passbolt! + b.chkmonitor! : null,
          1 => b.passbolt,
          _ => b.chkmonitor,
        };
      }).toList();

  _BwStats _buildStats(List<double> values) {
    if (values.isEmpty) return const _BwStats();
    final sorted = [...values]..sort();
    final avg = sorted.reduce((a, b) => a + b) / sorted.length;
    return _BwStats(min: sorted.first, avg: avg, max: sorted.last);
  }

  Widget _statWidget(double? value) {
    if (value == null) return const Text('—');
    return AnimatedNumberText(value: value, decimalDigits: 1, suffix: ' MB/s');
  }
}

// ── painter ───────────────────────────────────────────────────────────────────

class _BandwidthPainter extends CustomPainter {
  const _BandwidthPainter({
    required this.values,
    required this.maxY,
    required this.lineColor,
  });

  final List<double?> values;
  final double maxY;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || values.isEmpty) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final gridPaint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * (i / 3)),
        Offset(size.width, size.height * (i / 3)),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.24),
          lineColor.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    _drawWithGaps(canvas, size, linePaint, fillPaint);
    canvas.restore();
  }

  void _drawWithGaps(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint fillPaint,
  ) {
    final safeMax = maxY <= 0 ? 1.0 : maxY;
    final n = values.length;
    var linePath = Path();
    var fillPath = Path();
    var segmentStarted = false;
    var lastDx = 0.0;

    void closeSegment() {
      if (!segmentStarted) return;
      fillPath
        ..lineTo(lastDx, size.height)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
      linePath = Path();
      fillPath = Path();
      segmentStarted = false;
    }

    for (var i = 0; i < n; i++) {
      final value = values[i];
      final dx = n == 1 ? 0.0 : size.width * i / (n - 1);

      if (value == null) {
        closeSegment();
        continue;
      }

      final normalized = (value / safeMax).clamp(0.0, 1.0);
      final dy = size.height - size.height * normalized;

      if (!segmentStarted) {
        linePath.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, size.height)
          ..lineTo(dx, dy);
        segmentStarted = true;
      } else {
        linePath.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
      lastDx = dx;
    }
    closeSegment();
  }

  @override
  bool shouldRepaint(covariant _BandwidthPainter old) =>
      old.values != values || old.maxY != maxY || old.lineColor != lineColor;
}

// ── helpers ───────────────────────────────────────────────────────────────────

class _BwStats {
  const _BwStats({this.min, this.avg, this.max});
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

class _SeriesLabel extends StatelessWidget {
  const _SeriesLabel({required this.label, required this.color});

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
