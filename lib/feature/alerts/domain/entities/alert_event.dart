import 'alert_severity.dart';

/// A fired alert derived from a metric crossing a threshold.
/// Computed by the Go collector or by a Supabase function.
class AlertEvent {
  const AlertEvent({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.metricName,
    required this.currentValue,
    required this.thresholdValue,
    required this.severity,
    required this.triggeredAt,
    this.resolved = false,
    this.resolvedAt,
  });

  final String id;
  final String serviceId;
  final String serviceName;

  /// Human-readable metric name: 'Uso de memoria (RAM)', 'CPU', etc.
  final String metricName;

  final double currentValue;
  final double thresholdValue;
  final AlertSeverity severity;
  final DateTime triggeredAt;
  final bool resolved;
  final DateTime? resolvedAt;

  factory AlertEvent.fromDynamic(dynamic data) =>
      AlertEvent.fromJson(Map<String, dynamic>.from(data as Map));

  factory AlertEvent.fromJson(Map<String, dynamic> json) => AlertEvent(
    id: json['id'] as String,
    serviceId: json['service_id'] as String,
    serviceName: json['service_name'] as String,
    metricName: json['metric_name'] as String,
    currentValue: (json['current_value'] as num).toDouble(),
    thresholdValue: (json['threshold_value'] as num).toDouble(),
    severity: AlertSeverity.fromString(json['severity'] as String),
    triggeredAt: DateTime.parse(json['triggered_at'] as String).toLocal(),
    resolved: (json['resolved'] as bool?) ?? false,
    resolvedAt: json['resolved_at'] != null
        ? DateTime.parse(json['resolved_at'] as String).toLocal()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_id': serviceId,
    'service_name': serviceName,
    'metric_name': metricName,
    'current_value': currentValue,
    'threshold_value': thresholdValue,
    'severity': severity.toJson(),
    'triggered_at': triggeredAt.toIso8601String(),
    'resolved': resolved,
    'resolved_at': resolvedAt?.toIso8601String(),
  };
}
