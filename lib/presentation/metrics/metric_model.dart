import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/metrics/domain/entities/metric.dart';
import '../../feature/monitoring/domain/entities/service_status.dart';
import '../widgets/animated_number_text.dart';
import 'cubit/metrics_range.dart';
import 'cubit/metrics_state.dart';

// ── bucket model ──────────────────────────────────────────────────────────────

class MetricsBucket {
  const MetricsBucket({
    required this.time,
    required this.passbolt,
    required this.chkmonitor,
  });

  final DateTime time;
  final double? passbolt;
  final double? chkmonitor;

  bool get isComplete => passbolt != null && chkmonitor != null;
  // No hay combined: cada widget calcula su propio agregado según semántica
}

// ── bucketizer ────────────────────────────────────────────────────────────────

List<MetricsBucket> bucketize({
  required List<Metric> passboltAsc,
  required List<Metric> chkmonitorAsc,
  required DateTime from,
  required DateTime to,
  required MetricsRange range,
  required double? Function(Metric) select,
}) {
  final pb = [...passboltAsc]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
  final ck = [...chkmonitorAsc]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));

  final bs = range.bucketSize;
  final tol = range.lookbackTolerance;

  double? avg(List<Metric> src, DateTime start, DateTime end) {
    final values = src
        .where(
          (m) => !m.collectedAt.isBefore(start) && m.collectedAt.isBefore(end),
        )
        .map(select)
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double? nearest(List<Metric> src, DateTime start) {
    final candidates = src
        .where(
          (m) =>
              !m.collectedAt.isBefore(start.subtract(tol)) &&
              m.collectedAt.isBefore(start),
        )
        .toList();
    if (candidates.isEmpty) return null;
    return select(candidates.last);
  }

  return List.generate(12, (i) {
    final start = from.add(bs * i);
    final end = (i == 11) ? to : start.add(bs);

    final pbVal = avg(pb, start, end) ?? nearest(pb, start);
    final ckVal = avg(ck, start, end) ?? nearest(ck, start);

    return MetricsBucket(time: start, passbolt: pbVal, chkmonitor: ckVal);
  });
}

List<MetricsBucket> bucketizeLatest({
  required List<Metric> passboltAsc,
  required List<Metric> chkmonitorAsc,
  required DateTime from,
  required DateTime to,
  required Duration bucketSize,
  required Duration lookbackTolerance,
  required double? Function(Metric) select,
}) {
  final pb = [...passboltAsc]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
  final ck = [...chkmonitorAsc]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));

  double? latest(List<Metric> src, DateTime start, DateTime end) {
    final inBucket = src
        .where(
          (m) => !m.collectedAt.isBefore(start) && m.collectedAt.isBefore(end),
        )
        .toList();
    if (inBucket.isEmpty) return null;
    return select(inBucket.last);
  }

  double? nearest(List<Metric> src, DateTime start) {
    final candidates = src
        .where(
          (m) =>
              !m.collectedAt.isBefore(start.subtract(lookbackTolerance)) &&
              m.collectedAt.isBefore(start),
        )
        .toList();
    if (candidates.isEmpty) return null;
    return select(candidates.last);
  }

  return List.generate(12, (i) {
    final start = from.add(bucketSize * i);
    final end = (i == 11) ? to : start.add(bucketSize);

    final pbVal = latest(pb, start, end) ?? nearest(pb, start);
    final ckVal = latest(ck, start, end) ?? nearest(ck, start);

    return MetricsBucket(time: start, passbolt: pbVal, chkmonitor: ckVal);
  });
}

// ── models ────────────────────────────────────────────────────────────────────

class MetricSummaryCardModel {
  MetricSummaryCardModel({
    required this.title,
    required this.passboltValue,
    required this.chkmonitorValue,
    required this.status,
    required this.icon,
    required this.color,
  });

  final String title;
  final Widget passboltValue;
  final Widget chkmonitorValue;
  final ServiceStatus status;
  final IconData icon;
  final Color color;
}

class MetricsSnmpRowModel {
  MetricsSnmpRowModel({
    required this.label,
    required this.latency,
    required this.loss,
    required this.color,
  });

  final String label;
  final Widget latency;
  final Widget loss;
  final Color color;
}

// ── extensions ────────────────────────────────────────────────────────────────

extension MetricsLoadedModelX on MetricsLoaded {
  List<MetricSummaryCardModel> toSummaryCards() {
    final pb = passboltMetrics.lastOrNull;
    final ck = chkmonitorMetrics.lastOrNull;
    final status = _resolveCombinedStatus(pb?.serviceStatus, ck?.serviceStatus);

    return [
      MetricSummaryCardModel(
        title: 'CPU promedio',
        passboltValue: _buildAnimatedValue(
          pb?.cpuUsagePercent,
          suffix: '%',
          decimalDigits: 1,
        ),
        chkmonitorValue: _buildAnimatedValue(
          ck?.cpuUsagePercent,
          suffix: '%',
          decimalDigits: 1,
        ),
        status: status,
        icon: Icons.memory_rounded,
        color: AppColors.chartCpu,
      ),
      MetricSummaryCardModel(
        title: 'RAM usada',
        passboltValue: _buildAnimatedValue(
          pb?.ramUsagePercent,
          suffix: '%',
          decimalDigits: 1,
        ),
        chkmonitorValue: _buildAnimatedValue(
          ck?.ramUsagePercent,
          suffix: '%',
          decimalDigits: 1,
        ),
        status: status,
        icon: Icons.developer_board_rounded,
        color: AppColors.chartRam,
      ),
      MetricSummaryCardModel(
        title: 'Uso de disco',
        passboltValue: _buildAnimatedValue(
          pb?.diskUsagePercent,
          suffix: '%',
          decimalDigits: 1,
        ),
        chkmonitorValue: _buildAnimatedValue(
          ck?.diskUsagePercent,
          suffix: '%',
          decimalDigits: 1,
        ),
        status: status,
        icon: Icons.storage_rounded,
        color: AppColors.chartDisk,
      ),
      MetricSummaryCardModel(
        title: 'BW entrante',
        passboltValue: _buildAnimatedValue(
          pb?.bandwidthInMb,
          suffix: ' MB/s',
          decimalDigits: 1,
        ),
        chkmonitorValue: _buildAnimatedValue(
          ck?.bandwidthInMb,
          suffix: ' MB/s',
          decimalDigits: 1,
        ),
        status: status,
        icon: Icons.download_rounded,
        color: AppColors.chartNetwork,
      ),
    ];
  }

  List<MetricsSnmpRowModel> toSnmpRows() {
    final pb = passboltMetrics.lastOrNull;
    final ck = chkmonitorMetrics.lastOrNull;

    return [
      MetricsSnmpRowModel(
        label: 'Passbolt :1161',
        latency: _buildAnimatedValue(pb?.snmpLatencyMs, suffix: ' ms'),
        loss: _buildAnimatedValue(
          pb?.snmpLossPercent,
          suffix: '%',
          decimalDigits: 2,
        ),
        color: AppColors.primary,
      ),
      MetricsSnmpRowModel(
        label: 'ChkMonitor :2161',
        latency: _buildAnimatedValue(ck?.snmpLatencyMs, suffix: ' ms'),
        loss: _buildAnimatedValue(
          ck?.snmpLossPercent,
          suffix: '%',
          decimalDigits: 2,
        ),
        color: AppColors.secondary,
      ),
    ];
  }

  List<MetricsBucket> get bandwidthInBuckets => bucketize(
    passboltAsc: passboltMetrics,
    chkmonitorAsc: chkmonitorMetrics,
    from: queryFrom,
    to: queryTo,
    range: range,
    select: (m) => m.bandwidthInMb,
  );

  List<MetricsBucket> get bandwidthOutBuckets => bucketize(
    passboltAsc: passboltMetrics,
    chkmonitorAsc: chkmonitorMetrics,
    from: queryFrom,
    to: queryTo,
    range: range,
    select: (m) => m.bandwidthOutMb,
  );

  List<MetricsBucket> get uptimeBuckets => bucketize(
    passboltAsc: passboltMetrics,
    chkmonitorAsc: chkmonitorMetrics,
    from: queryFrom,
    to: queryTo,
    range: range,
    select: (m) => m.serviceStatus == ServiceStatus.online ? 1.0 : 0.0,
  );
}

Widget _buildAnimatedValue(
  num? value, {
  String suffix = '',
  int decimalDigits = 0,
}) {
  if (value == null) return const Text('—');
  return AnimatedNumberText(
    value: value,
    suffix: suffix,
    decimalDigits: decimalDigits,
  );
}

ServiceStatus _resolveCombinedStatus(
  ServiceStatus? passbolt,
  ServiceStatus? chkmonitor,
) {
  const priority = {
    ServiceStatus.online: 0,
    ServiceStatus.warning: 1,
    ServiceStatus.degraded: 2,
    ServiceStatus.offline: 3,
  };

  final statuses = [passbolt, chkmonitor].whereType<ServiceStatus>().toList();
  if (statuses.isEmpty) return ServiceStatus.warning;
  statuses.sort((a, b) => priority[b]!.compareTo(priority[a]!));
  return statuses.first;
}
