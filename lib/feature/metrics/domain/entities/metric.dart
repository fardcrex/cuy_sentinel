class Metric {
  const Metric({
    required this.id,
    required this.serviceId,
    this.ramUsageMb,
    this.diskUsagePercent,
    this.bandwidthInMb,
    this.bandwidthOutMb,
    required this.serviceStatus,
    required this.collectedAt,
  });

  final int id;
  final int serviceId;
  final double? ramUsageMb;
  final double? diskUsagePercent;
  final double? bandwidthInMb;
  final double? bandwidthOutMb;
  final bool serviceStatus;
  final DateTime collectedAt;

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      id: json['id'] as int,
      serviceId: json['service_id'] as int,
      ramUsageMb: (json['ram_usage_mb'] as num?)?.toDouble(),
      diskUsagePercent: (json['disk_usage_percent'] as num?)?.toDouble(),
      bandwidthInMb: (json['bandwidth_in_mb'] as num?)?.toDouble(),
      bandwidthOutMb: (json['bandwidth_out_mb'] as num?)?.toDouble(),
      serviceStatus: json['service_status'] as bool,
      collectedAt: DateTime.parse(json['collected_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_id': serviceId,
    'ram_usage_mb': ramUsageMb,
    'disk_usage_percent': diskUsagePercent,
    'bandwidth_in_mb': bandwidthInMb,
    'bandwidth_out_mb': bandwidthOutMb,
    'service_status': serviceStatus,
    'collected_at': collectedAt.toIso8601String(),
  };
}
