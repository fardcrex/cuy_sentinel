import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/alerts/domain/entities/alert_severity.dart';
import '../../feature/metrics/domain/entities/metric.dart';
import '../../feature/monitoring/domain/entities/service_status.dart';
import '../metrics/metric_model.dart';
import '../widgets/animated_number_text.dart';
import 'cubit/dashboard_state.dart';

/// Bucketing simple para dashboard: para cada bucket, si no hay valor exacto,
/// toma el último valor anterior dentro de una tolerancia (lookback).
/// Si tampoco hay, deja null (gap). No promedia.
List<double?> _statusPoints(
  List<dynamic> metrics,
  dynamic Function(dynamic) status, {
  required DateTime from,
  required DateTime to,
  required Duration bucketSize,
  Duration? lookbackTolerance,
}) {
  final sorted = [...metrics]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
  final tol = lookbackTolerance ?? bucketSize * 1.5;
  final buckets = <double?>[];
  for (var i = 0; i < 10; i++) {
    final start = from.add(bucketSize * i);
    final end = (i == 9) ? to : start.add(bucketSize);
    // Buscar el valor más reciente en el bucket
    final inBucket = sorted
        .where(
          (m) => !m.collectedAt.isBefore(start) && m.collectedAt.isBefore(end),
        )
        .toList();
    double? val;
    if (inBucket.isNotEmpty) {
      val = status(inBucket.last) == ServiceStatus.online ? 1.0 : 0.0;
    } else {
      // Fallback: buscar el último valor anterior dentro de la tolerancia
      final fallback = sorted
          .where(
            (m) =>
                m.collectedAt.isBefore(start) &&
                m.collectedAt.isAfter(start.subtract(tol)),
          )
          .toList();
      if (fallback.isNotEmpty) {
        val = status(fallback.last) == ServiceStatus.online ? 1.0 : 0.0;
      } else {
        val = null; // gap
      }
    }
    buckets.add(val);
  }
  return buckets;
}

// ── model ─────────────────────────────────────────────────────────────────────

class DashboardStatCardModel {
  DashboardStatCardModel({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    required this.sparkPoints,
  });

  final String title;
  final Widget value;
  final Widget caption;
  final IconData icon;
  final Color color;
  final List<double> sparkPoints;
}

// ── extension ─────────────────────────────────────────────────────────────────

extension DashboardLoadedModelX on DashboardLoaded {
  List<DashboardStatCardModel> toStatCards() {
    final pb = passboltMetrics.lastOrNull;
    final ck = chkmonitorMetrics.lastOrNull;

    final pbOnline = pb?.serviceStatus == ServiceStatus.online;
    final ckOnline = ck?.serviceStatus == ServiceStatus.online;
    final onlineCount = (pbOnline ? 1 : 0) + (ckOnline ? 1 : 0);

    final allMetrics = [...passboltMetrics, ...chkmonitorMetrics];
    final uptimePercent = allMetrics.isEmpty
        ? 0.0
        : allMetrics
                  .where((m) => m.serviceStatus == ServiceStatus.online)
                  .length /
              allMetrics.length *
              100;

    final criticalCount = activeAlerts
        .where((a) => a.severity == AlertSeverity.critical)
        .length;
    final warningCount = activeAlerts
        .where((a) => a.severity == AlertSeverity.warning)
        .length;
    final alertColor = criticalCount > 0
        ? AppColors.critical
        : AppColors.warning;

    final totalMetrics = passboltMetrics.length + chkmonitorMetrics.length;

    // Bucketing para sparklines (10 buckets, intervalo igualado al rango de datos)
    final now = DateTime.now();
    final minTime = [...passboltMetrics, ...chkmonitorMetrics]
        .map((m) => m.collectedAt)
        .fold<DateTime?>(
          null,
          (prev, t) => prev == null || t.isBefore(prev) ? t : prev,
        );
    final from = minTime ?? now.subtract(const Duration(minutes: 50));
    final to = now;
    final bucketSize = Duration(
      milliseconds: ((to.difference(from).inMilliseconds) / 10).ceil(),
    );
    final lookback = bucketSize * 1.5;

    return [
      DashboardStatCardModel(
        title: 'Servicios activos',
        value: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedNumberText(value: onlineCount),
            const Text(' / 2'),
          ],
        ),
        caption: const Text('Passbolt · ChkMonitor'),
        icon: Icons.cloud_done_rounded,
        color: AppColors.primary,
        sparkPoints: _statusPoints(
          passboltMetrics,
          (m) => m.serviceStatus,
          from: from,
          to: to,
          bucketSize: bucketSize,
          lookbackTolerance: lookback,
        ).map((v) => v ?? 0.0).toList(),
      ),
      DashboardStatCardModel(
        title: 'Uptime promedio',
        value: AnimatedNumberText(
          value: uptimePercent,
          decimalDigits: 1,
          suffix: '%',
        ),
        caption: Wrap(
          spacing: 3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Últimas'),
            AnimatedNumberText(value: allMetrics.length),
            const Text('lecturas'),
          ],
        ),
        icon: Icons.shield_outlined,
        color: AppColors.primaryBright,
        sparkPoints: _statusPoints(
          chkmonitorMetrics,
          (m) => m.serviceStatus,
          from: from,
          to: to,
          bucketSize: bucketSize,
          lookbackTolerance: lookback,
        ).map((v) => v ?? 0.0).toList(),
      ),
      DashboardStatCardModel(
        title: 'Alertas activas',
        value: AnimatedNumberText(value: activeAlerts.length),
        caption: Wrap(
          spacing: 3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AnimatedNumberText(value: criticalCount),
            const Text('crítica ·'),
            AnimatedNumberText(value: warningCount),
            const Text('advertencia'),
          ],
        ),
        icon: Icons.notifications_active_rounded,
        color: alertColor,
        sparkPoints: List.generate(
          10,
          (i) => (activeAlerts.length * (i + 1) / 10).clamp(0.0, 1.0),
        ),
      ),
      DashboardStatCardModel(
        title: 'Métricas recolectadas',
        value: AnimatedNumberText(value: totalMetrics, groupThousands: true),
        caption: const Text('Intervalo: 5 min'),
        icon: Icons.analytics_outlined,
        color: AppColors.secondary,
        sparkPoints: List.generate(10, (i) => 0.3 + i * 0.05),
      ),
    ];
  }

  List<MetricsBucket> get bandwidthInBuckets =>
      _bwBuckets(passboltMetrics, chkmonitorMetrics, (m) => m.bandwidthInMb);

  List<MetricsBucket> get bandwidthOutBuckets =>
      _bwBuckets(passboltMetrics, chkmonitorMetrics, (m) => m.bandwidthOutMb);
}

List<MetricsBucket> _bwBuckets(
  List<Metric> passboltMetrics,
  List<Metric> chkmonitorMetrics,
  double? Function(Metric) select,
) {
  final to = DateTime.now();
  final all = [...passboltMetrics, ...chkmonitorMetrics];
  final from = all.isEmpty
      ? to.subtract(const Duration(hours: 1))
      : all.map((m) => m.collectedAt).reduce((a, b) => a.isBefore(b) ? a : b);
  final spanMs = to.difference(from).inMilliseconds;
  final bs = spanMs <= 0
      ? const Duration(minutes: 5)
      : Duration(milliseconds: (spanMs / 12).ceil());
  final tol = Duration(milliseconds: (bs.inMilliseconds * 1.5).round());
  return bucketizeLatest(
    passboltAsc: passboltMetrics,
    chkmonitorAsc: chkmonitorMetrics,
    from: from,
    to: to,
    bucketSize: bs,
    lookbackTolerance: tol,
    select: select,
  );
}
