import 'alert_severity.dart';

/// Defines the threshold a metric must exceed to fire an alert.
/// Stored as configuration (could be a table in Fase 2 or a local config file).
class AlertThreshold {
  const AlertThreshold({
    required this.id,
    required this.serviceId,
    required this.metricName,
    required this.thresholdValue,
    required this.severity,
    this.enabled = true,
  });

  final String id;

  /// References monitored_services.id. Null = applies to all services.
  final String? serviceId;

  /// Column name in metrics table: 'cpu_usage_percent', 'ram_usage_mb',
  /// 'disk_usage_percent', 'bandwidth_in_mb', 'bandwidth_out_mb',
  /// 'snmp_latency_ms'.
  final String metricName;

  final double thresholdValue;
  final AlertSeverity severity;
  final bool enabled;

  factory AlertThreshold.fromDynamic(dynamic data) =>
      AlertThreshold.fromJson(Map<String, dynamic>.from(data as Map));

  factory AlertThreshold.fromJson(Map<String, dynamic> json) => AlertThreshold(
    id: json['id'] as String,
    serviceId: json['service_id'] as String?,
    metricName: json['metric_name'] as String,
    thresholdValue: (json['threshold_value'] as num).toDouble(),
    severity: AlertSeverity.fromString(json['severity'] as String),
    enabled: (json['enabled'] as bool?) ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_id': serviceId,
    'metric_name': metricName,
    'threshold_value': thresholdValue,
    'severity': severity.toJson(),
    'enabled': enabled,
  };
}
