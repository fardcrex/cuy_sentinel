import '../../../monitoring/domain/entities/service_status.dart';

class Metric {
  const Metric({
    required this.id,
    required this.serviceId,
    this.cpuUsagePercent,
    this.ramUsageMb,
    this.ramTotalMb,
    this.diskUsagePercent,
    this.bandwidthInMb,
    this.bandwidthOutMb,
    this.uptimeSeconds,
    required this.serviceStatus,
    this.snmpLatencyMs,
    this.snmpLossPercent,
    required this.collectedAt,
  });

  final String id;
  final String serviceId;

  // Resources
  final double? cpuUsagePercent;
  final int? ramUsageMb;
  final int? ramTotalMb;
  final double? diskUsagePercent;

  // Network
  final double? bandwidthInMb;
  final double? bandwidthOutMb;

  // Availability
  final int? uptimeSeconds;
  final ServiceStatus serviceStatus;

  // SNMP metadata
  final int? snmpLatencyMs;
  final double? snmpLossPercent;

  final DateTime collectedAt;

  double? get ramUsagePercent {
    if (ramUsageMb == null || ramTotalMb == null || ramTotalMb == 0) return null;
    return ramUsageMb! / ramTotalMb! * 100;
  }

  factory Metric.fromJson(Map<String, dynamic> json) => Metric(
    id: json['id'] as String,
    serviceId: json['service_id'] as String,
    cpuUsagePercent: (json['cpu_usage_percent'] as num?)?.toDouble(),
    ramUsageMb: json['ram_usage_mb'] as int?,
    ramTotalMb: json['ram_total_mb'] as int?,
    diskUsagePercent: (json['disk_usage_percent'] as num?)?.toDouble(),
    bandwidthInMb: (json['bandwidth_in_mb'] as num?)?.toDouble(),
    bandwidthOutMb: (json['bandwidth_out_mb'] as num?)?.toDouble(),
    uptimeSeconds: json['uptime_seconds'] as int?,
    serviceStatus: ServiceStatus.fromString(
      json['service_status'] as String? ?? 'offline',
    ),
    snmpLatencyMs: json['snmp_latency_ms'] as int?,
    snmpLossPercent: (json['snmp_loss_percent'] as num?)?.toDouble(),
    collectedAt: DateTime.parse(json['collected_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_id': serviceId,
    'cpu_usage_percent': cpuUsagePercent,
    'ram_usage_mb': ramUsageMb,
    'ram_total_mb': ramTotalMb,
    'disk_usage_percent': diskUsagePercent,
    'bandwidth_in_mb': bandwidthInMb,
    'bandwidth_out_mb': bandwidthOutMb,
    'uptime_seconds': uptimeSeconds,
    'service_status': serviceStatus.toJson(),
    'snmp_latency_ms': snmpLatencyMs,
    'snmp_loss_percent': snmpLossPercent,
    'collected_at': collectedAt.toIso8601String(),
  };
}
