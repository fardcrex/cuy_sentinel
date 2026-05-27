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

  factory Metric.fromDynamic(dynamic data) =>
      Metric.fromJson(Map<String, dynamic>.from(data as Map));

  factory Metric.fromJson(Map<String, dynamic> json) => Metric(
    id: json['id'] as String,
    serviceId: json['service_id'] as String,
    cpuUsagePercent: _toDouble(json['cpu_usage_percent']),
    ramUsageMb: _toInt(json['ram_usage_mb']),
    ramTotalMb: _toInt(json['ram_total_mb']),
    diskUsagePercent: _toDouble(json['disk_usage_percent']),
    bandwidthInMb: _toDouble(json['bandwidth_in_mb']),
    bandwidthOutMb: _toDouble(json['bandwidth_out_mb']),
    uptimeSeconds: _toInt(json['uptime_seconds']),
    serviceStatus: ServiceStatus.fromString(
      json['service_status'] as String? ?? 'offline',
    ),
    snmpLatencyMs: _toInt(json['snmp_latency_ms']),
    snmpLossPercent: _toDouble(json['snmp_loss_percent']),
    collectedAt: DateTime.parse(json['collected_at'] as String),
  );

  // PostgreSQL NUMERIC/DECIMAL fields arrive as String from Node.js to avoid
  // JS floating-point precision loss.
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt();
    return null;
  }

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
