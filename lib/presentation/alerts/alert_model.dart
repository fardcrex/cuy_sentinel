import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/alerts/domain/entities/alert_event.dart';
import '../../feature/alerts/domain/entities/alert_severity.dart' as ds;
import '../../feature/alerts/domain/entities/alert_threshold.dart';
import '../widgets/alert_threshold_tile.dart';
import '../widgets/incident_record_tile.dart';
import 'cubit/alerts_state.dart';

// ── private helpers ───────────────────────────────────────────────────────────

AlertSeverity _mapSeverity(ds.AlertSeverity s) => switch (s) {
      ds.AlertSeverity.nuclear => AlertSeverity.nuclear,
      ds.AlertSeverity.critical => AlertSeverity.critical,
      ds.AlertSeverity.warning => AlertSeverity.warning,
      ds.AlertSeverity.info => AlertSeverity.info,
    };

Color _severityColor(ds.AlertSeverity s) => switch (s) {
      ds.AlertSeverity.nuclear => const Color(0xFFFF0040),
      ds.AlertSeverity.critical => AppColors.danger,
      ds.AlertSeverity.warning => AppColors.warning,
      ds.AlertSeverity.info => AppColors.secondary,
    };

String _formatValue(String metricName, double value) {
  final lower = metricName.toLowerCase();
  if (lower.contains('ram') || lower.contains('memoria')) {
    return '${value.toStringAsFixed(0)} MB';
  }
  if (lower.contains('latencia') || lower.contains('latency')) {
    return '${value.toStringAsFixed(0)} ms';
  }
  if (lower.contains('bandwidth') || lower.contains('ancho') ||
      lower.contains('bw')) {
    return '${value.toStringAsFixed(0)} Mbps';
  }
  return '${value.toStringAsFixed(1)}%';
}

String _formatRelative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  return 'Hace ${diff.inDays} días';
}

String _formatDate(DateTime dt) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${months[dt.month - 1]} $h:$m';
}

String _formatDuration(Duration d) {
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  if (d.inHours < 24) {
    final mins = d.inMinutes.remainder(60);
    return mins > 0 ? '${d.inHours} h $mins min' : '${d.inHours} h';
  }
  return '${d.inDays} días';
}

String _thresholdLabel(String metricName) => switch (metricName) {
      'cpu_usage_percent' => 'CPU',
      'ram_usage_mb' => 'RAM',
      'disk_usage_percent' => 'Disco',
      'bandwidth_in_mb' || 'bandwidth_out_mb' => 'BW',
      'snmp_latency_ms' => 'Latencia',
      _ => metricName,
    };

String _thresholdValue(AlertThreshold t) => switch (t.metricName) {
      'cpu_usage_percent' || 'disk_usage_percent' =>
        '> ${t.thresholdValue.toStringAsFixed(0)}%',
      'ram_usage_mb' => '> ${t.thresholdValue.toStringAsFixed(0)} MB',
      'bandwidth_in_mb' || 'bandwidth_out_mb' =>
        '> ${t.thresholdValue.toStringAsFixed(0)} Mbps',
      'snmp_latency_ms' => '> ${t.thresholdValue.toStringAsFixed(0)} ms',
      _ => '> ${t.thresholdValue}',
    };

// ── models ────────────────────────────────────────────────────────────────────

/// UI representation of an active [AlertEvent] — feeds [AlertThresholdTile].
class AlertEventModel {
  AlertEventModel({
    required this.service,
    required this.metric,
    required this.currentValue,
    required this.threshold,
    required this.severity,
    required this.timestamp,
  });

  final String service;
  final String metric;
  final String currentValue;
  final String threshold;
  final AlertSeverity severity;
  final String timestamp;
}

/// UI representation of a historical [AlertEvent] — feeds [IncidentRecordTile].
class IncidentModel {
  IncidentModel({
    required this.service,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.cause,
  });

  final String service;
  final IncidentType type;
  final String startTime;
  final String endTime;
  final String duration;
  final String cause;
}

/// UI representation of an [AlertThreshold] — feeds the aside config rows.
class AlertThresholdModel {
  AlertThresholdModel({
    required this.metric,
    required this.threshold,
    required this.color,
  });

  final String metric;
  final String threshold;
  final Color color;
}

// ── extensions ────────────────────────────────────────────────────────────────

extension AlertEventModelX on AlertEvent {
  AlertEventModel toAlertModel() => AlertEventModel(
        service: serviceName,
        metric: metricName,
        currentValue: _formatValue(metricName, currentValue),
        threshold: _formatValue(metricName, thresholdValue),
        severity: _mapSeverity(severity),
        timestamp: _formatRelative(triggeredAt),
      );

  IncidentModel toIncidentModel() {
    final isResolved = resolved && resolvedAt != null;
    final cause = isResolved
        ? '$metricName volvió a niveles normales'
        : '$metricName superó umbral (${_formatValue(metricName, thresholdValue)})';
    return IncidentModel(
      service: serviceName,
      type: isResolved ? IncidentType.recovered : IncidentType.down,
      startTime: _formatDate(triggeredAt),
      endTime: isResolved ? _formatDate(resolvedAt!) : 'Activo',
      duration: isResolved
          ? _formatDuration(resolvedAt!.difference(triggeredAt))
          : _formatDuration(DateTime.now().difference(triggeredAt)),
      cause: cause,
    );
  }
}

extension AlertThresholdModelX on AlertThreshold {
  AlertThresholdModel toModel() => AlertThresholdModel(
        metric: _thresholdLabel(metricName),
        threshold: _thresholdValue(this),
        color: _severityColor(severity),
      );
}

/// UI-ready labels for the three summary badges in the header.
class AlertsSummaryModel {
  AlertsSummaryModel({
    required this.criticalLabel,
    required this.warningLabel,
    required this.closedTodayLabel,
  });

  final String criticalLabel;
  final String warningLabel;
  final String closedTodayLabel;
}

extension AlertsSummaryModelX on AlertsLoaded {
  AlertsSummaryModel toSummaryModel() {
    final now = DateTime.now();
    final closedToday = history.where((a) {
      if (!a.resolved || a.resolvedAt == null) return false;
      final r = a.resolvedAt!;
      return r.year == now.year && r.month == now.month && r.day == now.day;
    }).length;

    return AlertsSummaryModel(
      criticalLabel: '$criticalCount crítica${criticalCount == 1 ? '' : 's'}',
      warningLabel: '$warningCount advertencia${warningCount == 1 ? '' : 's'}',
      closedTodayLabel: '$closedToday cerradas hoy',
    );
  }
}
